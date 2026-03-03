#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()


= DEK Donor Generation

When a new donor is registered within the ICNML application, the first cryptographic operation is 
the generation of a *Data Encryption Key* (DEK). This key is unique to the donor and is used to encrypt
all biometric data associated with them.


The DEK is designed to be completely *uncoupled* with the rest of the application so that deleting it will render 
all biometric data within the database unrecoverable. This is a very important workflow to guarantee a kind 
of privacy-by-deletion design. If the user wants to delete their key, they have the possibility to do it, and it 
will render all their biometric data unreadable by other users.


This document describes the complete DEK generation workflow and is used as a stepping stone for future documentation.
This will cover the HTTP routes used, the cryptographic steps, and the object stored in the database to fully understand
the process. 

== Prerequisites and Roles

The donor creation process, by derivation the DEK generation, requires a *Submitter* and the request from the user 
to be a *Donor*. 

== Steps

=== Entry point
 
The entry point for the generation of the donor dek is `POST /submission/do_new`. This is triggered after the *Submitter*
has sent the form to register the new *Donor*. This is only accessible for the users with *Administrator* or *Submitter* role.

The form provides two inputs:
- `email`, this is the donor's plain-text email
- `upload_nickname`, this is the submission nickname


=== Step 1, Duplicate Check

Before any creation, the code checks wether the email is already used within the db. To be more precise from the 
sql query, it will check if, among the submissions done by the *Submitter*, one has the same email hash. 

#figure(
    ```python
    sql = "SELECT id, email_hash FROM submissions WHERE submitter_id = %s"
    ...
    if utils.hash.pbkdf2( email ).verify( case[ "email_hash" ] ):
    # Return error that email is used for another submission
    ```,
    caption: [Code for duplicate check]
)

We can see here that the provided email is hashed and then is verified against the `email_hash` stored in the database.
If a match is found the request is rejected with an error.

=== Step 2, Donor User Creation Account

In this step, the *Donor* is created with the status _pending_. The `email` and the `upload_nickname` are both encrypted
using the aes functions found in `utils/aes.py`. Then an id is retrieved via a sequence found in the database.

A new user is inserted within the table `users` with the format `donor_<id>`. Here is stored the username, the email as
well as the type.

#figure(
    ```python
        userid = config.db.query_fetchone( "SELECT nextval( 'username_donor_seq' ) as id" )[ "id" ]
        username = "donor_{}".format( userid )
        sql = utils.sql.sql_insert_generate( "users", [ "username", "email", "type" ], "id" )
    ```,
    caption: [Creation of a new donor]
)

=== Step 3, DEK Generation

After creating a user of type *Donor*, the DEK is generated calling the `utils.encryption.dek_generate()` function.
This function can take up to 4 arguments:
- `email`, the email of the donor
- `email_hash`, the hash of the donor's email
    - Either `email` or `email_hash` must be present in the kwargs
- `username`, the username of the donor (required)
- `salt`, the salt used for key generation (optional)

The function will hash the username and the email hash given using pbkdf2 to create the dek.

#figure(
    ```python
        dek = hash.pbkdf2( 
            "{}:{}".format( username, email, ),
            dek_salt,
            iterations = config.DEK_NB_ITERATIONS,
            hash_name = "sha512"
        ).hash( True )
    ```,
    caption: [Code for the DEK generation]
)

The `config.DEK_NB_ITERATIONS` is 500'000.

The function creates a check object with a call to `aes.do_encrypt()` with a json as parameters and the dek. It is used
later on if the user chooses to recreate their DEK after a soft-delete. 

The function returns 3 variables:
- `dek_salt`, the salt used for generating the DEK
- `dek`, the generated DEK
- `check`, the encrypted DEK for rebuilding the DEK later on to check against 

=== Step 4, DEK persistance






