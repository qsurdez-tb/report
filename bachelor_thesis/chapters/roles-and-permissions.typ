= Roles and permissions <roles-and-permissions>

The application ICNML follows a role-based access control (RBAC) model.
Every authenticated user has one and only one role. The different roles possible
within the application are stored in the `account_type` sql table. It's reflected
on login in the Redis session object. A series of decorator are used to manage the
authorisation of each route.

The document describes each role: how they are created, what routes and database
operations are allowed, what is explicitely denied.

== Account types

There are 6 account types in the `01-account_type.sql` file.
A flag `can_singin` exists for each account type. It filters the types for which a user can request a user account
via the `GET /signin` public form.


#figure(
    table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (center + horizon, left, center, left),
      table.header[*ID*][*Name*][*Can request account*][*Short description*],
      [1], [Administrator], [No],  [Full privileged access; manages the platform.],
      [2], [Donor],         [No],  [Subject whose biometric data is collected; created by a Submitter.],
      [3], [Submitter],     [Yes], [Registers donors.],
      [4], [Trainer],       [Yes], [Uses mark data to train fingerprint examiners.],
      [5], [AFIS],          [Yes], [Works with Automated Fingerprint Identification System targets and candidate matches.],
      [6], [Selection],     [Yes], [Selection user, not clear yet what it's useful for.],
    )
)

== Authentication and Session Model

The authentication is handled by the `/login` route. It expects the user to complete a form and then it will call the
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

== Access-Control decorators

Most of the authorisation logic lies in the decorators file. This is done via the use of `functools` package to 
make decorator out of functions.

=== `@login_required`

The first decorator is the one that requires the user to be logged in. 
It checks that the `session["logged"]` key is set to `True`. Any unauthenticated
request is redirected to the login url. This is the baseline access control.


=== `@admin_required`

This decorator checks wether the `account_type_name` key in the session is set to Administrator.
It also checks wether or not the user is logged with the same logic as the `login_required` decorator.

If the the account type name is not Administrator, it will redirect to login.

=== `@submission_has_access`

This decorator will check wether the user has access to the current submission.

- If the user is an Administrator, then they can access the submission
- If the user is a Submitter, the submission needs to be theirs (this needs clarification, I don't understand it yet)
- All other roles are redirected to the login page

=== `@trainer_has_access`

This decorator checks wether the `account_type_name` key in the session is set to Administrator.
It also checks if this key is set to Trainer and if the user is logged. 

If the account type name is not Administrator or Trainer, it will redirect to the login page.

== Role descriptions

=== Administrator (type 1)

*Creation*: Accounts must be created directly in the database or by a process not documented.

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


=== Donor (type 2)

*Creation:* Created by a Submitter via `POST /submission/do_new`. No self-registration.

*Home page redirect:* `GET /user/myprofile/dek`

*Scope:* Donors manage only their own cryptographic key (DEK) and view their
own biometric data. They cannot interact with the submission or AFIS workflows.

*Permitted operations:*

#table(
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
)

=== Submitter (type 3)

*Creation:* Self-registration via `GET /signin` / `POST /do/signin` followed
by e-mail confirmation and administrator approval.

*Home page redirect:* `GET /submission/list`

*Scope:* Submitters manage the complete lifecycle of their own submissions,
from donor registration through file upload and metadata annotation. They
cannot access another submitter's data.

*Permitted operations (own submissions only):*

#table(
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
)

// TODO check what PFSP is with mandate

*Ownership enforcement:* `@submission_has_access` issues HTTP 403 if the
`submission_id` in the URL was not created by the current submitter.

== Trainer (type 4)

*Creation:* Self-registration via `GET /signin`.

*Home page redirect:* `GET /marks/search`

*Scope:* Trainers consume mark and tenprint data for examiner-training
exercises. Their access is read-oriented; they do not create submissions or
manage donors.

*Permitted operations:*

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(220) } else { white },
  align: (left, left),
  table.header[*Route*][*Purpose*],
  [`GET  /marks/search`],              [Search and filter marks for training.],
  [`GET  /marks/exercise/<id>`],       [View a training exercise.],
  [`GET  /marks/folder/<id>`],         [Browse an exercise folder.],
  [`POST /exercises/add_tenprint`],    [Associate a tenprint card with an exercise.],
)
