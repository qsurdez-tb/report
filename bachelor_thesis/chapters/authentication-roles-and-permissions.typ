#import "../macros.typ": note, concept

= Authentication, Roles and Permissions

#concept[
  Every action in ICNML turns on two questions: who are you? and what are you allowed to do? The first is authentication, proving your identity when you log in. The second is authorisation, the set of things your kind of account may do once you are in. This chapter answers both, starting with the kinds of user ICNML serves and what each may do, then how a user proves who they are at login. The supporting code and the exhaustive route lists are collected in @appendix-authentication so the discussion here stays on the concepts and the design choices.
]

== Who uses ICNML: roles and permissions <roles-and-permissions>

ICNML controls access with a role-based model which means that every authenticated user holds exactly one role, and the role, not the individual, decides what is permitted. The available roles are stored in the `account_type` database table (@db-arch) and copied into the user's session at login. A set of small gatekeeper functions (decorators, described at the end of this section) then checks the role on every protected page.

@roles-actors maps each role to the real-world participant it represents and to their part in the biometric-data workflow.

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Role][Real-world participant][Part in the workflow],
    [Administrator], [Platform operator], [Oversees the whole platform, validates new accounts, manages AFIS work.],
    [Submitter], [Researcher collecting data], [Registers donors and uploads their biometric data.],
    [Donor], [Person whose prints are stored], [Owns and can erase their own biometric data (via their key).],
    [Trainer], [Fingerprint-examiner instructor], [Draws on the mark library to build training exercises.],
    [AFIS], [Identification specialist], [Works fingerprint-identification targets and candidate matches.],
    [Selection], [(reserved)], [Defined in the database but not yet wired to any dedicated function.],
  ),
  caption: [The six ICNML roles as forensic-workflow participants.]
)<roles-actors>

Two properties of this table are worth stating. First, the Donor is not a person who logs in to browse. They exist so that the biometric subject retains control of their own data, the ability to erase it, a point developed in the per-donor security chapter. Second, the Selection role is defined in the sign-up flow and the database but has no dedicated pages. A Selection user can currently reach only the pages guarded by the weakest "just be logged in" check.

=== What each role does

Administrator (type 1). Created directly in the database (there is no self-service path). An administrator passes every gatekeeper check and additionally reaches the `/admin/` pages: approving sign-up requests, viewing all submissions, managing AFIS targets, downloading uncompressed originals, and inspecting raw records by UUID. The full capability list is in @auth-routes.

Submitter (type 3). Self-registers, then is confirmed by e-mail and approved by an administrator. A submitter manages the full life cycle of their own submissions: creating a donor, uploading files, annotating tenprints and marks, and browsing their data. Ownership is enforced on every submission page, so one submitter can never touch another's data. Routes in @auth-routes.

Donor (type 2). Created by a submitter, never self-registered. A donor's pages are narrow and centre on their cryptographic key, the Data Encryption Key (DEK) that makes their biometric data readable. Routes in @auth-routes.

Trainer (type 4). Self-registers and is approved like a submitter. A trainer has read-only access to the mark library to build examiner-training exercises. They create no submissions and manage no donors. Routes in @auth-routes.

AFIS (type 5). Self-registers and is approved like a submitter. AFIS users carry out fingerprint identification: they receive candidate-match assignments, upload and annotate search results, and record comparison decisions. This is a substantial part of the application. Its routes are listed in @auth-routes.

Selection (type 6). Self-registers and is approved, but reaches no dedicated function, as noted above.

=== How the rules are enforced

Authorisation is applied by wrapping each protected page in a gatekeeper function. Four are used throughout: `@login_required` (any logged-in user), `@admin_required` (administrators only), `@submission_has_access` (administrators, or the submitter who owns that submission), and `@trainer_has_access` (administrators or trainers). Each rejects unauthorised requests back to the login page, and the ownership checks compare the record's owner against the session user so that holding a role is not enough, the record must also be yours if you're not an administrator.

== Proving identity: the login flow

Logging in to ICNML is not a single password check but a short sequence of steps. Because two of those steps involve a second factor, an independent proof of identity beyond the password, it helps to name the two the platform uses before walking through the flow.

/ TOTP (Time-based One-Time Password) : the six-digit code, refreshed every thirty seconds, shown by an authenticator app on a phone. Entering the current code proves the user holds the enrolled device. ICNML requires TOTP as the second factor for ordinary accounts.
/ WebAuthn / FIDO2 : a physical security key (a small USB device) that proves its identity to ICNML cryptographically. It resists phishing because the key answers only to the genuine physical device. ICNML offers it as the strong second factor for administrators.

=== The shape of a login

A complete login follows one of two sequences. The ordinary path is password, then TOTP. If the user has enrolled a security key, the path is password, then security key. Only after the second factor succeeds is the session marked as logged in. @login-flow-fig shows the password-and-TOTP path, which is the common case.

#figure(
  image("../assets/login-flow.drawio.png"),
  caption: [The login flow: rate-limit check, password verification, then the mandatory second factor before the session is granted. TODO simplify the login-flow figure]
)<login-flow-fig>

The steps below run in order on repeated calls to the single login endpoint. The server remembers which step is next in the session.

/ Rate limiting (before anything else) : Every login attempt is throttled before any credential is examined. The throttle is keyed not on the exact client address but on its surrounding `/16` network block (derived from the client IP, `REMOTE_ADDR`), and the enforced delay grows exponentially once a floor of five attempts is passed (delay $= 2^(max(n, 5))$ seconds). Because the counter increases on both a wrong password and an unknown username, the response does not reveal whether an account exists.

/ Password verification : The password is first hashed inside the browser before it is sent (@auth-code). The intent is that the server never receives the raw password, so a leak of server logs or a broken transport reveals only a hash. The trade-off, worth stating honestly, is that this browser-side hash then behaves as the effective password. On the server, if the username is unknown, ICNML still runs a verification against a dummy stored hash before answering. This deliberate wasted work keeps the response time the same whether or not the account exists, closing a timing side channel that would otherwise leak which usernames are valid. When the account does exist, the submitted hash is checked against the stored one. In the code this check sits inside a compound `or not` condition, which is easy to miss on a first reading.

/ Active-account and parameter checks : A correct password on a deactivated account is refused (without counting against the rate limit, since the password was right). ICNML then checks whether the stored password was hashed with the current security parameters and, if not, transparently re-hashes it with the current ones. This upgrade is possible precisely because the browser re-sends its client-side hash on every login. The server never needs, and never has, the plaintext password to perform it. It always has the hash of the hash stored in the database.

/ Second factor and device trust : The user then supplies the TOTP code, accepted within a small time window to tolerate clock drift. After a successful TOTP login the user may choose to trust the current device for thirty days. ICNML records this under a key derived from the username and a hash of the client IP. On a later login from the same address, that record lets the flow skip the TOTP step, it bypasses the second factor, not the login itself, which still requires the password.

=== Where the session lives, and what the cookie is

Once logged in, the user's state is stored server-side in Redis, not in the browser. The cookie the browser holds contains only an opaque session identifier. The actual session contents never leave the server. That identifier is signed with the application's `SECRET_KEY` so it cannot be tampered with or forged. In production the cookie is additionally marked `Secure` and `SameSite=Strict` and served only over HTTPS. In development those protections are relaxed and the second factor is not enforced, which is what makes local testing practical but partial. A session lasts two hours (`PERMANENT_SESSION_LIFETIME`) and is refreshed on each request.

After a successful login the session holds the username, the user's database id, the numeric and textual role, a `logged` flag, and one more field that deserves explanation: `password`. This is not the plaintext password but a hash of the (already browser-hashed) password, kept for the duration of the session so the server can work with the user's own encrypted data while they are active. Two weaknesses attach to it: keeping any password-derived secret in the session is a risk if the session store is compromised, and the hash is computed with the fixed, hardcoded salt `"AES256"` (@auth-code) rather than a random one, an illustrative example of the ad-hoc cryptography found across the codebase.

=== How a password is stored

No form of the plaintext password is ever stored or even received by the server. The password passes through two hashing stages, summarised in @pw-hash-fig.

#figure(
  table(
    columns: (2fr, 3fr, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Stage][What it computes][Parameters],
    [In the browser], [Hash of the raw password, salted with the username], [PBKDF2-SHA512, 20 000 iterations],
    [On the server], [Hash of the browser hash, salted with a random value], [PBKDF2-SHA512, 50 000 iterations, 20-byte salt],
    [Stored in `users.password`], [`pbkdf2$sha512$<salt>$<iterations>$<hash>`], [—],
  ),
  caption: [The two-stage password hashing. The server only ever sees the browser hash and stores a salted hash of it.]
)<pw-hash-fig>

Storing a hash of a hash means that even a full database leak exposes neither the password nor the value the browser sends. The random per-user salt at the server stage is drawn through `utils.rand`, which, as noted elsewhere in this thesis, uses Python's non-cryptographic `random` module. The same weakness affects the `SECRET_KEY` fallback and the reset tokens.

=== Credential recovery and security keys

Resetting a forgotten TOTP secret or password both follow the same path. The user submits an e-mail, the lookup runs in a background thread so the response time does not reveal whether the address is known, and, on a match, a single-use token with a 24-hour lifetime is e-mailed. The enumeration-prevention intent is sound, but the code offers no rate limiting on these endpoints, so the protection is partial. Security-key (WebAuthn) management, registration, renaming, disabling and deletion, is implemented and scoped so a user can only manage their own keys.

== Assessment

The authentication design has real strengths. The sessions live server-side rather than in the browser, a second factor is mandatory in production, the password is never transmitted or stored in the clear, a constant-time dummy check hides whether a username exists, and every data-bearing route enforces ownership rather than merely a role.

The weaknesses are concentrated and mostly shallow to fix. In order of value we would have replacing the non-cryptographic `random` module with a secure source everywhere it feeds a secret (`SECRET_KEY`, salts, reset tokens). Replacing the hardcoded `"AES256"` salt on the session password with a random one. Narrowing the rate-limit key from a `/16` block to the individual address to stop collateral lockouts. Adding rate limiting to the reset endpoints. Restructuring the code itself as everything currently lives inside `__init__.py` files of thousands of line which makes the codebase hard to maintain. These changes are the residue of a research codebase that favoured functionality over hardening, and each is an isolated, well-defined change.
