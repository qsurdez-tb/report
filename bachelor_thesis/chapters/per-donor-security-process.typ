#import "../macros.typ": note, concept

= Per-Donor Security Processes <per-donor-security>

#concept[
  The Donor is the person whose fingerprints ICNML stores (@roles-and-permissions). This chapter is about how that person's data is protected across their whole life in the system. From the moment a Submitter registers them, through consent and account activation, to the operation that matters most for privacy, the donor's ability to make all of their biometric data permanently unrecoverable. That power rests on a single per-donor key, the Data Encryption Key (DEK). The supporting code is collected in @appendix-per-donor.
]

== The idea: one key per donor

Every donor has one key, the DEK, and every piece of their biometric data, marks and tenprints alike, is encrypted with it. Destroying the DEK makes the data unreadable to everyone. There is one caveat to keep in mind throughout this chapter, the DEK table is itself backed up (@backup-security), so a destroyed key still lives in any backup taken in the last 30 days. A deletion therefore becomes fully irreversible only once those backups have aged out.

This is privacy by deletion, and for a biometric library it is the mechanism that makes a meaningful right to erasure possible. A donor who withdraws consent does not have to trust that every copy of their prints, in the database, was found and deleted. Removing the one key that unlocks them is enough. The rest of this chapter follows the DEK from creation to that final erasure.

== Creating a donor and their key <dek-donor-generation>

A donor is never self-registered. A Submitter creates them through the registration form (`POST /submission/do_new`), supplying the donor's e-mail address and an optional nickname. Before anything is created, ICNML checks that the e-mail is not already registered, though only among the current submitter's own submissions, so the same donor could in principle be registered twice by two different submitters.

#figure(
    image("../assets/DEK-generation.png", height: 62%),
    caption: [Deriving and storing a donor's DEK at registration.]
)


The donor account is then created in a pending state with an automatically generated username of the form `donor_<id>`. The plaintext e-mail is never stored. What goes into the account's identity field is a hash of the e-mail. In this sense the e-mail hash is the donor's identifier inside ICNML.

The DEK is then derived and stored. It is computed from two things tied to the donor, their username and a hash of their e-mail:

$ "DEK" = "PBKDF2"( "username" : "email_hash", "salt", 500\'000 "iterations" ) $

#note[The code names the relevant parameter `email`, but it hashes the address internally before use (@apx-dek-creation). The value actually mixed into the DEK is the e-mail hash, not the address. The parameter name is misleading and is one of the small readability traps in the codebase.]

Alongside the DEK, the system stores a small check object. The word "ok" encrypted with the DEK. It is never needed to read data, but it lets ICNML later confirm that a recomputed DEK is the right one, by decrypting the check and seeing whether "ok" comes back. The DEK, its salt, and this check are saved in the `donor_dek` table. // TODO verify with code ? 


== Protecting the donor's e-mail and nickname

The donor's e-mail is deliberately stored in two different forms, because two different needs pull in opposite directions.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Form][How it is made][What it is for],
    [E-mail hash], [PBKDF2 of the e-mail with a random salt (50 000 iterations)], [The donor's stable identifier, used to look accounts up. Cannot be reversed to the address.],
    [Encrypted e-mail], [AES ciphertext with the submitter's session key], [Lets the submitter see the address back in the interface, without the server keeping the plaintext.],
  ),
  caption: [The two stored forms of a donor's e-mail and why both exist.]
)

The phrase "the submitter's session key" deserves unpacking, because the same idea reappears for the nickname. When a submitter logs in, a key derived from their client-side hashed password is held in their session (the session `password` field from @roles-and-permissions). ICNML encrypts the reversible e-mail form and the nickname with that key. These fields can only be decrypted while that particular submitter is logged in. No one else, not another submitter, not the server on its own, can turn them back into readable text.

== The consent form

A donor's consent form (a PDF) is handled with a different tool again, asymmetric GPG encryption. When the submitter uploads it, ICNML first scans each page for a QR code carrying the exact text `ICNML CONSENT FORM`, a simple check that the right document was uploaded. It then encrypts the file with a GPG public key belonging to the ICNML installation itself, and stores the result.

#figure(
    image("../assets/submitter-consent-form.drawio.png", width: 50%),
    caption: [Consent-form verification, encryption, and storage.]
)

The choice of an asymmetric key is what matters here. Encrypting with the institution's public key means the consent form can be written by the running application but only read back by whoever holds the matching private key, the institution's operators, kept off the server. Consent forms therefore sit encrypted at rest, out of reach of the web application in normal operation.

#note[Two rough edges: the GPG key is identified by a single hardcoded key id in the configuration, and the encrypted file is stored base64-encoded in a text column, which inflates it by about 30% @base64. Both are easy to improve.]

== Activating the donor account

Only once the consent form is in place does the donor set their own password. They receive an e-mail with an activation link whose token is derived from their stored e-mail hash. Following it lets them choose a password, which, as everywhere in ICNML, is hashed once in the browser and a second time on the server before storage (@apx-dek-lifecycle). From this point the donor can log in and exercise control over their own key.

#figure(
    image("../assets/donor-activation.drawio.png", width: 78%),
    caption: [Donor account activation and password setup.]
)

== The DEK life cycle: withdraw, erase, restore

Once the key exists, the donor (and, in a limited way, their submitter) can move it through the states shown in @dek-lifecycle-fig. Three operations matter.

#figure(
    image("../assets/dek-lifecycle.drawio.png", width: 78%),
    caption: [The DEK life cycle: soft deletion is reversible, full deletion is not.]
)<dek-lifecycle-fig>

/ Soft deletion : (`GET /dek/delete`) clears only the DEK itself, keeping its salt and check object. The donor's data immediately becomes unreadable, but because the salt survives, the key can still be recomputed later. This is a reversible withdrawal. The submission still appears to exist, its images simply cannot be opened for now.

/ Full deletion : (`GET /dek/fulldelete`) removes the DEK, its salt, and the check object. Without the salt, the derivation formula above can no longer be evaluated by anyone, so the DEK can never be reproduced from the live database and the donor's biometric data is permanently unreadable. This is the donor's right-to-erasure operation. As noted at the start of the chapter, though, the erasure is only complete once the backups that still hold a copy of the DEK have expired (@backup-security), a window of up to 30 days.

/ Reconstruction : undoes a soft deletion. The donor supplies a hash of their e-mail (computed in their browser with the fixed salt `icnml_user_DEK`). The server recomputes the DEK from it and the stored salt, checks it against the check object, and, only if "ok" comes back, restores it. A more limited form of this happens automatically for a submitter or administrator. When the DEK is soft-deleted but the salt remains, ICNML can rebuild the key from the encrypted e-mail form for the duration of that user's session only, never writing it back to the database. This is what lets a submitter keep working with a donor who has soft-deleted their key, while still leaving the donor in final control.

== Assessment

The per-donor design is the strongest security idea in ICNML. Encrypting every donor's data under a single, donor-controlled key turns "delete my data" from a vague promise into a concrete cryptographic action, and the check object gives the reconstruction paths a clean way to fail safely. The one wrinkle to close is the backup window described above, until it is addressed, erasure is eventual rather than immediate. Storing only a hash of the e-mail, and binding the reversible fields to the submitter's session, are sound choices.

The weaknesses are, for the most part, not structural. The duplicate-e-mail check should span all submissions, not just the current submitter's. The consent-form GPG key is hardcoded and its payload base64-bloated. The naming inside the key-derivation code (the `email` parameter that is really an e-mail hash) makes an already subtle mechanism harder to audit than it needs to be. The reconstruction paths in particular would benefit from clearer in-code documentation, as they are the part most easily misread.

However, the DEK being stored in the same database as the encrypted images is a single point of failure. Indeed, if an attacker manages to dump the database, they would be able to decrypt all images very easily as the DEK is available to them. The images are stored as base64-bloated characters which makes the database very big, another solution would be to have a dedicated directory on the server where the images are in bytes and can be served by the server for example. 
