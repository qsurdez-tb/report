#let note(body) = block(
  fill: blue.lighten(70%),
  stroke: (left: 3pt + blue),
  inset: (x: 12pt, y: 8pt),
  radius: 3pt,
  width: 100%,
)[*Note:* #body]


= Per-Donor Security Processes <per-donor-security>

This chapter is focused on all the security processes around the user type Donor, @roles-and-permissions. These processes span the whole donor lifecycle, from protection of the data concerning the donor by a Submitter, through the consent and activation flow, to authentication and the DEK (Data Encryption Key) deletion and reconstruction mechanisms.

== Donor Creation and DEK Generation

When a new donor is registered, a DEK (Data Encryption Key) is generated. This key is unique to the donor and is used to encrypt all biometric data associated with them.

The DEK is designed so that deleting it will render all 
biometric data linked to the Donor unrecoverable. This is a 
very important workflow to guarantee a privacy-by-deletion 
design. If the donor wants to delete their key, they have the possibility to do it, and it will render all biometric data unreadable by other users.

=== Steps

==== Entry point

The entry point for the generation of the donor's DEK is `POST /submission/do_new`. This is triggered after the Submitter has sent the form to register the new Donor. This is only accessible for the users with `@utils.decorator.submission_has_access`, @roles-and-permissions.

The form provides two inputs:
- `email`, this is the donor's plaintext email
- `upload_nickname`, this is the donor's nickname chosen by the Submitter.

==== Step 1, checking for duplicate

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

==== Step 2, creating the donor user

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

==== Step 3, generating the DEK

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

==== Step 4, persisting the DEK

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