#let note(body) = block(
  fill: blue.lighten(70%),
  stroke: (left: 3pt + blue),
  inset: (x: 12pt, y: 8pt),
  radius: 3pt,
  width: 100%,
)[*Note:* #body]


= Per-Donor Security Processes <per-donor-security>

This chapter is focused on all the security processes around the user type Donor, @roles-and-permissions. These processes span the whole donor lifecycle, from protection of the data concerning the donor by a Submitter, through the consent and activation flow, to authentication and the DEK (Data Encryption Key) deletion and reconstruction mechanisms.

== Donor Creation and DEK Generation <dek-donor-generation>

When a new donor is registered, a DEK (Data Encryption Key) is generated. This key is unique to the donor and is used to encrypt all biometric data associated with them.

The DEK is designed so that deleting it will render all 
biometric data linked to the Donor unrecoverable. This is a 
very important workflow to guarantee a privacy-by-deletion 
design. If the donor wants to delete their key, they have the possibility to do it, and it will render all biometric data unreadable by other users.

=== Entry point

The entry point for the generation of the donor's DEK is `POST /submission/do_new`. This is triggered after the Submitter has sent the form to register the new Donor. This is only accessible for the users with `@utils.decorator.submission_has_access`, @roles-and-permissions.

The form provides two inputs:
- `email`, this is the donor's plaintext email
- `upload_nickname`, this is the donor's nickname chosen by the Submitter.

=== Step 1, checking for duplicate

Before any creation, the code check whether the hash of the email is already present in the database. To be more precise from the SQL query, it will check if, among the submissions done by the current Submitter, one has the same email hash.

#note[This duplicate check only queries submissions belonging to the current Submitter and not across all submissions. This could be improved easily.]

#figure(
    ```python
    sql = "SELECT id, email_hash FROM submissions WHERE submitter_id = %s"
    ...
    if utils.hash.pbkdf2( email ).verify( case[ "email_hash" ] ):
    # Return error that email is used for another submission
    ```,
    caption: [Duplicate check (`views/submission/__init__.py`, ln 329)]
)

=== Step 2, creating the donor user

In this step, the Donor is created with the status pending. The `email` and the upload nickname are both encrypted with AES-256, @submission-data-protection. Then an Id is retrieved via a sequence found in the database.

A new user is inserted within the `users` table with the format `donor_<id>`. The username, the email hash as well as the type of user (Donor) are persisted in the database.

#figure(
    ```python
        userid = config.db.query_fetchone( "SELECT nextval( 'username_donor_seq' ) as id" )[ "id" ]
        username = "donor_{}".format( userid )
        sql = utils.sql.sql_insert_generate( "users", [ "username", "email", "type" ], "id" )
    ```,
    caption: [Creation of a new user of type Donor (`views/submission/__init__.py`, ln 353-356)]
)

=== Step 3, generating the DEK

After creating a user of type Donor, the DEK is generated calling the `utils.encryption.dek_generate()` function.
This function can take up to 4 arguments:
- `email`, the email of the donor
- `email_hash`, the hash of the donor's email
    - Either `email` or `email_hash` must be present in the kwargs
- `username`, the username of the donor (required)
- `salt`, the salt used for key generation (optional)

The function will create a key derived from the username and the email hash using pbkdf2.

#figure(
    ```python
        dek = hash.pbkdf2( 
            "{}:{}".format( username, email, ),
            dek_salt,
            iterations = config.DEK_NB_ITERATIONS,
            hash_name = "sha512"
        ).hash( True )
    ```,
    caption: [DEK generation (`utils/encryption.py`, ln 184-189)]
)

Then the function creates a check object that is an AES-256 Ciphertext using the DEK as replacement for the usual password parameter. This object can be used later on if the user chooses to recrete their DEK after a soft-delete, // @dek-sof-delete. TODO

#figure(
  ```python
    check = {
        "value": "ok",
        "time": int( time.time() * 1000 ),
        "random": rand.random_data( config.DEK_CHECK_SALT_LENGTH )
    }
    check = json.dumps( check )
    check = aes.do_encrypt( check, dek )
  ```,
  caption: [Creation of the check object (`utils/encryption.py`, ln 191-197)]
)

The function returns a tuple of 3 variables:
- `dek_salt`, the salt used for generating the DEK.
- `dek`, the generated DEK.
- `check`, the json object encrypted using the DEK.

=== Step 4, persisting the DEK

After the creation of the DEK, it is stored within the `donor_dek` table. Here's a list of the different fields that
are persisted:

- `donor_name`, this is the username created previously `donor_<id>`
- `salt`, this is the `dek_salt` returned by the dek generating function
- `dek`, the generated DEK
- `dek_check`, the check object encrypted with AES-256 using the DEK
- `iterations`, the number of iterations used to create the DEK
- `algo`, the algo used for generating the DEK, here always pbkdf2
- `hash`, the structure of the hash used, here always sha512

It then returns a response with error false and the donor uuid.

#figure(
    image("../assets/DEK-generation.png", height: 60%),
    caption: [DEK Generation Schema]
)

== Submission Data Protection <submission-data-protection>

When a new donor is registered, two pieces of identifying information are submitted by the Submitter: the donor's email address and an optional nickname. Both are sensitive and receive different treatments before being stored.

=== Two Storage Formats for Donor's Email

The donor's email is stored in two formats with two different purposes.

#figure(
    ```python
    email_aes  = utils.encryption.do_encrypt_user_session( email )
    email_hash = utils.hash.pbkdf2( email, iterations = config.EMAIL_NB_ITERATIONS ).hash()
    ```,
    caption: [Different treamtment of the donor email at submission (`views/submission/__init__.py`, ln 344-345)]
)

`email_aes` is an AES-256 ciphertext created with the 
Submitter's password, stored in the session object. It is 
stored in `submission.email_aes` and allows the submitter to 
display the email back in the interface without the server 
needing the plaintext.

`email_hash` is a `PBKDF` hash with a random salt and 
`EMAIL_NB_ITERATIONS` (50'000) iterations.
The same hash value is stored in two places: `submissions.
email_hash` and `users.email` as the identity of the donor 
account in the `users` table. The plaintext email is not 
persisted.

=== Nickname encryption

The submission nickname provided by the Submitter is encrypted 
with the same mechanism as the Submitter's password with AES 
as`email_aes` before being stored in `submissions.nickname`.

#figure(
    ```python
    upload_nickname = utils.encryption.do_encrypt_user_session( upload_nickname )
    ```,
    caption: [Nickname encryption at submission (`views/submission/__init__.py`, ln 348)]
)

Because both fields use the submitter's password as the key, 
they can only be decrypted during an authenticated session of 
that submitter.

== Consent Form flow

The content form PDF is encrypted via a mechanism involving an asymmetric GPG key.

=== Step 1, QR Code Verification

Before the file is stored, each page of the PDF is scanned searching for a QR code containing the exact string `"ICNML CONSENT FORM"`. The result is stored as a boolean in `cf.has_qrcode`.

#figure(
  ```python
  for d in decoded:
    if d.data == "ICNML CONSENT FORM":
        qrcode_checked = True
  ```,
  caption: [QR code verification during consent form upload (`views/submission/__init__.py`, ln 212-213) ]
)

=== Step 2, Donor Activation Email

Once the QR code is detected, the donor receivesan email containing a unique activation URL. The URL is computed as the SHA-512 hash of the email hash stored in `users.email`.

#figure(
    ```python
    url_hash = hashlib.sha512( email_db ).hexdigest()
    url = url_for( "newuser.config_new_user_donor", h = url_hash )
    ```,
    caption: [Activation URL token generation (`views/submission/__init__.py`, ln 188 + ln 227)]
)

The activation route (`GET /config/donor/<h>`) iterates all Donor accounts without a password set, computes `sha512(email)` for each, and matches against `h`. On a match, the donor's `user_id` is stored in the session and the account setup page is served.

=== Step 3, GPG Encryption and Storage

The consent form is then encrypted with a GPG public key identified by a hardcoded key Id configured in `config.gpg_key`. A separate email hash is derived for the consent form table using `CF_NB_ITERATIONS`.

#figure(
    ```python
    file_data = config.gpg.encrypt( file_data, *config.gpg_key )
    file_data = str( file_data )
    file_data = base64.b64encode( file_data )

    email_hash = utils.hash.pbkdf2( email, iterations = config.CF_NB_ITERATIONS ).hash()

    sql = utils.sql.sql_insert_generate( "cf", [ "uuid", "data", "email", "has_qrcode" ] )
    ```,
    caption: [GPG encryption and storage of the consent form (`views/submission/__init__.py`)]
)

#note[The file data is stored in a `varchar` in the database. Thus it needs to be converted to base64. This bloats the data by about 30% @base64. It's an issue that could easily be fixed.]

Only after the GPG encryption and database insertion succeed is the upload considered complete. The consent form is only uploaded once. The `submissions.consent_form` flag is set to `true` and further file upload for the donor become available.

== Donor Account Activation 

=== Entry Point

The donor account activation is handled by the route `POST /do/config/donor`. It is reached via the link in the activation email. The session must already contain the `email_hash` and `user_id` set by the previous `GET /config/donor/<h>` route.

=== Password Setup

The password comes from the browser and is already hashed with the client-side first step:

#figure(
  ```javascript
  password = await generateKey( password, "icnml_" + username, 20000 );
  ```,
  caption: [Encryption of the password Client-Side (`login/templates/login/users/config.html`, ln 109)]
)

#note[The function generateKey is defined in the file `app/function.js`. It would be interesting to explain it so to be sure it's understood how the password is encrypted on the Client-Side.]

The server performs the second hash before storage, adding a new random salt:

#figure(
    ```python
    password = utils.hash.pbkdf2( 
      password, 
      utils.rand.random_data( config.PASSWORD_SALT_LENGTH ), 
      config.PASSWORD_NB_ITERATIONS )
      .hash()
    ...
    config.db.query( "UPDATE users SET password = %s WHERE username = %s", ( password, username, ) )
    ```,
    caption: [Server-side second hash and storage (`views/newuser/__init__.py`)]
)

Before accepting the operation, the server verifies that the `email_hash` present in the session matches the one in the url as well as the `user_id` matches the one retrieved from the database using the username (`donor_<id>`).

== DEK Lifecycle

After the DEK has been generated, the donor created and their password setup, the donor has control over the DEK through three operations: soft deletion, full deletion and reconstruction.

=== Soft Deletion

The route `GET /dek/delete` deletes only the `dek` column in `donor_dek`, leaving the `salt` and `dek_check` intact.

#figure(
    ```python
    sql = "UPDATE donor_dek SET dek = NULL WHERE donor_name = %s"
    config.db.query( sql, ( username, ) )
    ```,
    caption: [DEK soft-delete (`views/donor/__init__.py`, ln 92-93)]
)

This allows a user to withdraw their data from the application. The submitter's view of the submission is unchanged. Files appear to exist, but image content is no longer decryptable by the server. The DEK can still be reconstructed by the donor or the submitter.

=== Full Deletion

The route `GET /dek/fulldelete` removes the `dek`, `salt` and `dek_check` columns in three separate `UPDATE` statements.

#figure(
  ```python
  sql = "UPDATE donor_dek SET dek = NULL WHERE donor_name = %s"
  config.db.query( sql, ( username, ) )
  sql = "UPDATE donor_dek SET salt = NULL WHERE donor_name = %s"
  config.db.query( sql, ( username, ) )
  sql = "UPDATE donor_dek SET dek_check = NULL WHERE donor_name = %s"
  config.db.query( sql, ( username, ) )
  ```,
  caption: [DEK full delete (`views/donor/__init__.py`, ln 119-124)]
)

Without the salt, the DEK formula

```
DEK = PBKDF2( username + ":" + email_hash, salt, 500 000 )
```

cannot be evaluated by anyone. All encrypted biometric data becomes permanently unreadable. This is the donor's right-to-erasure operation. 

#note[Quid of the backups ?]

=== DEK Reconstruction by the Donor

The route `POST /dek/reconstruct` allows the donor to restore their DEK after a soft deletion. The donor prodived their email hashed client-side with the fixed salt `"icnml_user_DEK"`. 

The server fetches the stored `salt` and `dek_check`, recomputes the DEK, and validates it by decrypting `dek_check` and asserting `{"value": "ok"}` in the result.

#figure(
    ```python
    _, dek, _ = utils.encryption.dek_generate(
        username = username, email_hash = email_hash, salt = user[ "salt" ]
    )
    check = utils.aes.do_decrypt( user[ "dek_check" ], dek )
    check = json.loads( check )

    if check[ "value" ] != "ok":
        raise Exception( "DEK check error" )

    sql = "UPDATE donor_dek SET dek = %s WHERE id = %s AND donor_name = %s"
    config.db.query( sql, ( dek, user[ "id" ], username, ) )
    ```,
    caption: [DEK reconstruction and verification by the donor (`views/donor/__init__.py`, ln 45-55)]
)

If the `dek_check` verification fails, the DEK is not written to the database and an error is returned.

=== DEK Session Reconstruction by the Submitter or Administrator

When the DEK column is empty but the `salt` is still present, the submitter or admin can access encrypted files for the duration of their session. This path is triggered automatically in `utils.encryption.get_dek_from_submissionid` when the database lookup returns no value.

the submitter's session or admin's session must contain the AES-encrypted email `email_aes` for the submission. The code decrypts it using the session id, recomputes the DEK, verifies it against `dek_check`, and stores the result in the session under `session["dek_{submission_id}"]`.

#figure(
    ```python
    email = do_decrypt_user_session( user[ "email" ] )
    _, dek, _ = dek_generate( username = username, email = email, salt = dek_salt )

    to_check = aes.do_decrypt( user[ "dek_check" ], dek )
    to_check = json.loads( to_check )

    if to_check[ "value" ] == "ok":
        session[ "dek_{}".format( submission_id ) ] = dek
        return True
    ```,
    caption: [Session-scoped DEK reconstruction for the submitter (`utils/encryption.py`, ln 139-146)]
)

The reconstructed DEK is never written back to `donor_dek`. It exists only in the server-side session for the duration of the submitter's or admin's login.
