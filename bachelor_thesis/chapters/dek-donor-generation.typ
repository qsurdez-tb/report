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
has sent the form to register the new *Donor*.

This is only accessible for the users with *Administrator* or *Submitter* role.

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





