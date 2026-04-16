#import "../macros.typ": note

= Authentication, roles and permissions

This chapter documents both the authentication processes mechanisms as well as authorisation processes within ICNML. 

== Authentication processes

This section covers the authentication processes, more precisely the session structure, the multi-step login flow, second-factor authentication (TOTP and WebAuthn) and the credential management (setup ,reset, key lifecycle).

=== Session Structure

All session variables is stored server-side in Redis. Sessions are not permanent and are refreshed on every request.

#figure(
  ```python
  SESSION_TYPE = "redis"
  SESSION_PERMANENT = False
  SESSION_REFRESH_EACH_REQUEST = True
  PERMANENT_SESSION_LIFETIME = 2 * 60 * 60
  ```,
  caption: [Session configuration (`config.py`, ln 37-41)]
)

In production, the session cookie is created with `Secure` and `SameSite=Strict` flags. In development mode these flags are absent and the cookie is transmitted over HTTP. 

#figure(
  ```python
  if envtype.upper() != "DEV":
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = "Strict"
    domain = "https://icnml.unil.ch"
    RP_ID = "icnml.unil.ch"
  ```,
  caption: [Secure session configuration in production environment (`config.py`, ln 99-103)]
)

The `SECRET_KEY` used to sign the session cookie is read from the `SECRET_KEY` environment variable. 
If the variable is not set, a random value of 20 characters is generated at startup using the non-cryptographic `random` module.

#note[This seems like an easy fix as one would just need to replace the `random` library by the `secret` library]

On successful login, the session is explicitly persisted in Redis with a synchronous `SAVE` command.

#figure(
  ```python
  config.redis_db[ "sessions" ].execute_command( "save" )
  ```,
  caption: [Redis persistence after login confirmed (`views/login/__init__.py`, ln 339)]
)

==== Session Fields set at Login

After a complete and successful login, the session contains:

- `logged -> True`, checked by all control decorators.
- `username`, the user's login name
- `user_id`, the primary key from the table `users`
- `account_type`, the numeric type identifier for the role
- `account_type_name`, the string role name
- `password`, a session-scoped PBKDF2 hash of the submitted password, but the function says AES256 ? // TODO besoin d'éclaicissements

#figure(
  ```python
  session[ "password" ] = utils.hash.pbkdf2( form_password, "AES256", config.PASSWORD_NB_ITERATIONS ).hash()
  ```,
  caption: [Creation of the PBKDF2 hash with AES256 mention as salt ? (`views/login/__init__.py`, ln 221)]
)

#note[This is an example of how obscure the cryptography is within the application to me. As the `__init__` function from the class pbkdf2 has as signature: 
```python
  def __init__( self, word, salt = None, iterations = 20000, hash_name = "sha512" ):
```]



== Roles and permissions <roles-and-permissions>

The application ICNML follows a role-based access control (RBAC) model.
Every authenticated user has one and only one role. The different roles possible
within the application are stored in the `account_type` sql table. It's reflected
on login in the Redis session object. A series of decorator are used to manage the
authorisation of each route.

This chapter describes each role: how they are created, what routes and database
operations are allowed.

=== Account types

There are 6 account types in the `01-account_type.sql` file.
A flag `can_singin` exists for each account type. There is a type and it shoud be called `can_signin`. It filters the types for which a user can request a user account
via the `GET /signin` public form.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (center + horizon, left, center, left),
      table.header[*ID*][*Name*][*Can request account*][*Short description*],
      [1], [Administrator], [No],  [Full privileged access; manages the platform.],
      [2], [Donor],         [No],  [Subject whose biometric data is collected, created by a Submitter.],
      [3], [Submitter],     [Yes], [Registers donors.],
      [4], [Trainer],       [Yes], [Uses mark data to train fingerprint examiners.],
      [5], [AFIS],          [Yes], [Works with Automated Fingerprint Identification System targets and candidate matches.],
      [6], [Selection],     [Yes], [Selection user, does not seem to have specific logic.],
    ),
    caption: [Account types table]
)

=== Authentication and Session Model

// TODO analyses the auth process!
The authentication is handled by the `/login` route. It expects the user to complete a form and then it will recall the
`POST /do/login` endpoint for each attribute (username, password, TOTP or WebAuthn passkey). Then, these are the
keys that are written in Redis.

#figure(
    ```python
        session[ "account_type" ]
        session[ "account_type_name" ]
        session[ "logged" ]
        session[ "username" ]
        session[ "user_id" ]
    ```,
    caption: [Keys written in Redis' session]
)

=== Access-Control decorators

Most of the authorisation logic lies in the decorators file. This is done via the use of `functools` package to 
make decorator out of functions.

==== `@login_required`

The first decorator is the one that requires the user to be logged in. 
It checks that the `session["logged"]` key is set to `True`. Any unauthenticated.


==== `@admin_required`

This decorator checks wether the `account_type_name` key in the session is set to Administrator.
It also checks wether or not the user is logged in with the same logic as the `login_required` decorator.

If the the account type name is not Administrator, it will redirect to login.

==== `@submission_has_access`

This decorator will check wether the user has access to the current submission.

- If the user is an Administrator, then they can access the submission
- If the user is a Submitter, the submission needs to be theirs (this needs clarification, I don't understand it yet)
- All other roles are redirected to the login page

==== `@trainer_has_access`

This decorator checks wether the user has access to the trainer specific endpoints.

- If the user is an Administrator, then they can access it
- If the user is a Trainer and is logged then they can access it
- All other roles are redirected to the login page.

=== Role descriptions

==== Administrator (type 1)

*Creation*: Accounts must be created directly in the database or by a process not documented as of yet.

*Home page redirect*: `GET /admin/submission/list`

*Scope*: The Administrator has unrestricted access to the entire application. Every decorator 
allows Administrators. Dedicated `/admin/*` routes are only usable by them.

*Capabilities*:

- *New user management*: can validate pending sign in requests via `GET /validate_signin`
- *Submission overview*: can view all submissions via `GET /admin/submission/list`
- *AFIS management*: creates targets (`POST /admin/target/<submission_id>/<pc>/new`),
  deletes targets or candidate matches, updates assigned AFIS users, and
  batch-assigns targets (`POST /admin/afis/batch_assign/do`)
- *Full-resolution images:* downloads uncompressed originals via
  `GET /image/file/<id>/full_resolution`.
- *PiAnoS integration:* synchronises all users and segments to the external
  PiAnoS system via `GET /pianos_api/add_user/all` and
  `GET /pianos_api/add_segments/all`.
- *Mark deletion (admin context):* `POST /admin/<submission_id>/mark/<m_id>/delete`.
- *UUID inspection:* retrieves the raw database table for any UUID via
  `GET /uuid/get_table/<uuid>`.


==== Donor (type 2)

*Creation:* Created by a Submitter via `POST /submission/do_new`. No self-registration.

*Home page redirect:* `GET /user/myprofile/dek`

*Scope:* Donors manage only their own cryptographic key (DEK) and view their
own biometric data. They cannot interact with the submission or AFIS workflows.

*Permitted operations:*

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[*Route*][*Purpose*],
    [`GET  /user/myprofile/dek`],      [View DEK profile page.],
    [`GET  /user/myprofile/tenprint`], [View own tenprint cards.],
    [`GET  /user/myprofile/marks`],    [View own mark images.],
    [`POST /dek/reconstruct`],         [Re-derive the DEK from the donor's e-mail (requires re-authentication).],
    [`GET  /dek/delete`],              [Soft-delete the DEK (`donor_dek.dek` set to `NULL`; reversible).],
    [`GET  /dek/fulldelete`],          [Permanently delete the DEK row (right-to-erasure; irreversible).],
  ),
  caption: [Routes of interest for Donor role]

)

==== Submitter (type 3)

*Creation:* Self-registration via `GET /signin` / `POST /do/signin` followed
by e-mail confirmation and administrator approval.

*Home page redirect:* `GET /submission/list`

*Scope:* Submitters manage the complete lifecycle of their own submissions.

*Permitted operations (own submissions only):*

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[*Action*][*Routes*],
    [Create donor + submission], [`POST /submission/do_new` — creates `users`, `donor_dek`, and `submissions` rows.],
    [Upload files],              [`POST /upload`, `/submission/<id>/add_files`, `/submission/<id>/add_marks`, `/submission/<id>/consent_form`.],
    [Annotate tenprints],        [Set template, quality, segment coordinates, and general pattern on tenprint cards.],
    [Annotate marks],            [Set PFSP?, and delete marks.],
    [Manage submission],         [Set nickname, set GP, delete submission, view targets.],
    [Browse own data],           [`GET /submission/list`, tenprint list, mark list, segment views.],
  ),
  caption: [Routes of interest for Submitters role]

)
// TODO check what PFSP is with mandate

*Ownership enforcement:* `@submission_has_access` issues HTTP 403 if the
`submission_id` in the URL was not created by the current submitter.

==== Trainer (type 4)

*Creation:* Self-registration via `GET /signin` (Needs a confirmation from admin).

*Home page redirect:* `GET /marks/search`

*Scope:* Trainers consume mark and tenprint data for examiner-training
exercises. Their access is read-oriented; they do not create submissions or
manage donors.

*Permitted operations:*

#figure(
table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(220) } else { white },
  align: (left, left),
  table.header[*Route*][*Purpose*],
  [`GET  /marks/search`],              [Search and filter marks for training.],
  [`GET  /marks/exercise/<id>`],       [View a training exercise.],
  [`GET  /marks/folder/<id>`],         [Browse an exercise folder.],
  [`POST /exercises/add_tenprint`],    [Associate a tenprint card with an exercise.],
),
caption: [Routes of interest for Trainer role]

)

==== AFIS (type 5)

*Creation:* Self-registration via `GET /signin` (Needs a confirmation from admin).

*Home page redirect:* `GET /afis/list/targets`

*Scope:* AFIS users work on fingerprint identification targets: they receive
candidate match assignments, upload and annotate search results, and set
comparison decisions. This seems like a big part of the application.

*Permitted operations:*

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[*Route*][*Purpose*],
    [`GET  /afis/list/targets`],                              [List assigned AFIS targets.],
    [`GET  /afis/incidental/donors/list`],                    [List incidental donors.],
    [`GET  /afis/incidental/donor/<uuid>/list`],              [Browse a specific incidental donor's data.],
    [`GET  /afis/<uuid>`],                                    [View an AFIS target.],
    [`GET  /afis/<uuid>/download{,/mark,_exercise}`],         [Download target data, mark, or exercise package.],
    [`GET  /afis/<uuid>/upload/list`],                        [List uploaded result files.],
    [`GET  /afis/<uuid>/upload/new/<type>`],                  [Initiate a result file upload.],
    [`GET  /afis/<target>/<cnm>`],                            [View a candidate match.],
    [`POST /afis/<target>/<cnm>/set_pfsp`],                   [Record the PFSP decision for a candidate match.],
    [`POST /afis/<target>/<cnm>/upload`],                     [Upload a candidate match result file.],
    [`POST /afis/<target>/<cnm>/update_field`],               [Update a field on a candidate match.],
    [`GET  /afis/<cnm>/<file>/<fpc>/autodetect`],             [Auto-detect minutiae from a mark file.],
    [`GET  /afis/<cnm>/<file>/autodetect/tiff`],              [Auto-detect from a TIFF file.],
    [`GET  /afis/<cnm>/<file>/<fpc>/res`],                    [Retrieve image resolution metadata.],
    [`GET  /image/cnm_candidate/screenshot/<file>/preview`],  [Preview a candidate screenshot.],
  ),
  caption: [Routes of interest for AFIS role]

)
==== Selection (type 6)

*Creation:* Self-registration via `GET /signin` (Needs a confirmation from admin).

*Home page redirect:* Default (`/`) — no specialised redirect is defined in
`views/base/__init__.py` for this role.

*Scope:* The Selection role is defined in the database and the registration
flow but has no dedicated routes or decorators at this time. A Selection user
can log in and reach any route guarded only by `@login_required` (shared
utilities, UUID search, image preview, donor views, etc.), but cannot access submission,
AFIS, trainer, or admin-specific routes.
