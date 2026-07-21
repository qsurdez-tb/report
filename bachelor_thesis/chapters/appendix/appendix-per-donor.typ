= Per-donor security : implementation details <appendix-per-donor>

Code excerpts supporting the per-donor security chapter (@per-donor-security). The chapter body keeps the concepts and the schemas. The implementation detail is collected here.

== Donor and DEK creation <apx-dek-creation>

#figure(
    ```python
    sql = "SELECT id, email_hash FROM submissions WHERE submitter_id = %s"
    ...
    if utils.hash.pbkdf2( email ).verify( case[ "email_hash" ] ):
    # return error that the email is already used for another submission
    ```,
    caption: [Duplicate check, restricted to the current submitter's own submissions (`views/submission/__init__.py`, ln 329).]
)

#figure(
    ```python
    userid = config.db.query_fetchone( "SELECT nextval( 'username_donor_seq' ) as id" )[ "id" ]
    username = "donor_{}".format( userid )
    sql = utils.sql.sql_insert_generate( "users", [ "username", "email", "type" ], "id" )
    data = ( username, email_hash, 2 )
    ```,
    caption: [Donor account creation. Note that `users.email` stores the email _hash_, not the address (`views/submission/__init__.py`, ln 353-356).]
)

#figure(
    ```python
    # dek_generate(email=...) hashes the address internally before deriving the DEK:
    if "email" in kwargs:
        email = hash.pbkdf2( kwargs["email"], "icnml_user_DEK" ).hash( True )   # -> email_hash
    elif "email_hash" in kwargs:
        email = kwargs["email_hash"]
    dek = hash.pbkdf2( "{}:{}".format( username, email ), dek_salt,
                       iterations = config.DEK_NB_ITERATIONS, hash_name = "sha512" ).hash( True )
    ```,
    caption: [DEK derivation. The parameter is named `email` but holds the email _hash_ by the time the DEK is computed (`utils/encryption.py`, ln 170-189).]
)

#figure(
  ```python
  check = { "value": "ok", "time": int( time.time() * 1000 ),
            "random": rand.random_data( config.DEK_CHECK_SALT_LENGTH ) }
  check = aes.do_encrypt( json.dumps( check ), dek )
  ```,
  caption: [The check object: an "ok" marker encrypted with the DEK, later used to confirm a recomputed DEK is correct (`utils/encryption.py`, ln 191-197).]
)

== Email, nickname and consent form <apx-email-consent>

#figure(
    ```python
    email_aes  = utils.encryption.do_encrypt_user_session( email )
    email_hash = utils.hash.pbkdf2( email, iterations = config.EMAIL_NB_ITERATIONS ).hash()
    upload_nickname = utils.encryption.do_encrypt_user_session( upload_nickname )
    ```,
    caption: [The two email formats plus the nickname. `do_encrypt_user_session` encrypts with `session["password"]` (`views/submission/__init__.py`, ln 344-348).]
)

#figure(
  ```python
  def do_decrypt_user_session( data ):
      return aes.do_decrypt( data, session[ "password" ] )   # the session password-derived key
  ```,
  caption: [Session-scoped encryption keys on the submitter's password hash (`utils/encryption.py`, ln 216).]
)

#figure(
  ```python
  for d in decoded:
    if d.data == "ICNML CONSENT FORM":
        qrcode_checked = True
  ```,
  caption: [Consent-form QR verification (`views/submission/__init__.py`, ln 212-213).]
)

#figure(
    ```python
    file_data = config.gpg.encrypt( file_data, *config.gpg_key )   # config.gpg_key = ("FB15B70D1507B18B",)
    file_data = base64.b64encode( str( file_data ) )
    email_hash = utils.hash.pbkdf2( email, iterations = config.CF_NB_ITERATIONS ).hash()
    sql = utils.sql.sql_insert_generate( "cf", [ "uuid", "data", "email", "has_qrcode" ] )
    ```,
    caption: [Consent form encrypted with the hardcoded institutional GPG public key, then base64-encoded for a `varchar` column (`views/submission/__init__.py`).]
)

== Activation and DEK lifecycle <apx-dek-lifecycle>

#figure(
    ```python
    url_hash = hashlib.sha512( email_db ).hexdigest()
    url = url_for( "newuser.config_new_user_donor", h = url_hash )
    ```,
    caption: [Activation-URL token: SHA-512 of the stored email hash (`views/submission/__init__.py`, ln 188, 227).]
)

#figure(
    ```python
    password = utils.hash.pbkdf2( password,                       # already client-hashed
                                  utils.rand.random_data( config.PASSWORD_SALT_LENGTH ),
                                  config.PASSWORD_NB_ITERATIONS ).hash()
    config.db.query( "UPDATE users SET password = %s WHERE username = %s", ( password, username ) )
    ```,
    caption: [Donor password setup: server-side second hash before storage (`views/newuser/__init__.py`).]
)

#figure(
    ```python
    sql = "UPDATE donor_dek SET dek = NULL WHERE donor_name = %s"                       # soft delete
    # full delete additionally NULLs salt and dek_check:
    sql = "UPDATE donor_dek SET salt = NULL WHERE donor_name = %s"
    sql = "UPDATE donor_dek SET dek_check = NULL WHERE donor_name = %s"
    ```,
    caption: [Soft delete removes only the DEK. Full delete also removes the salt and check, making the DEK unrecomputable (`views/donor/__init__.py`, ln 92-124).]
)

#figure(
    ```python
    _, dek, _ = utils.encryption.dek_generate(
        username = username, email_hash = email_hash, salt = user[ "salt" ] )
    check = json.loads( utils.aes.do_decrypt( user[ "dek_check" ], dek ) )
    if check[ "value" ] != "ok":
        raise Exception( "DEK check error" )
    config.db.query( "UPDATE donor_dek SET dek = %s WHERE id = %s AND donor_name = %s",
                     ( dek, user[ "id" ], username ) )
    ```,
    caption: [Donor DEK reconstruction: recompute from the client-supplied email hash, verify against the check, restore (`views/donor/__init__.py`, ln 45-55).]
)

#figure(
    ```python
    email = do_decrypt_user_session( user[ "email" ] )
    _, dek, _ = dek_generate( username = username, email = email, salt = dek_salt )
    if json.loads( aes.do_decrypt( user[ "dek_check" ], dek ) )[ "value" ] == "ok":
        session[ "dek_{}".format( submission_id ) ] = dek   # session only, never written back
    ```,
    caption: [Session-scoped DEK reconstruction by the submitter or administrator (`utils/encryption.py`, ln 139-146).]
)
