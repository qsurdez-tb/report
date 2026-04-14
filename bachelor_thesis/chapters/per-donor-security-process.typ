= Per-Donor Security Processes <per-donor-security>

This chapter is focused on all the security processes around the user type Donor, @roles-and-permissions. These processes span the whole donor lifecycle, from protection of the data concerning the donor by a Submitter, through the consent and activation flow, to authentication and the DEK (Data Encryption Key) deletion and reconstruction mechanisms.

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

== Donor Creation and DEK Generation

When a new donor is registered, a DEK (Data Encryption Key) is generated. This key is unique to the donor and is used to encrypt all biometric data associated with them.

The DEK is designed so that deleting it will render all 
biometric data linked to the Donor unrecoverable. This is a 
very important workflow to guarantee a privacy-by-deletion 
design. If the donor wants to delete their key, they have the possibility to do it, and it will render all biometric data unreadable by other users.

=== Steps

==== Entry point

The entry point for the generation of the donor's DEK is 