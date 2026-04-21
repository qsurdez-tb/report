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

==== Session Fields set at Login <session-fields-set>

After a complete and successful login, the session contains:

- `logged -> True`, checked by all control decorators.
- `username`, the user's login name
- `user_id`, the primary key from the table `users`
- `account_type`, the numeric type identifier for the role
- `account_type_name`, the string role name
- `password`, a session-scoped PBKDF2 hash of the submitted password, but the salt is harcoded as the string `"AES256"`

#figure(
  ```python
  session[ "password" ] = utils.hash.pbkdf2( form_password, "AES256", config.PASSWORD_NB_ITERATIONS ).hash()
  ```,
  caption: [Creation of the PBKDF2 hash with AES256 mention as salt (`views/login/__init__.py`, ln 221)]
)

#note[This is an example of how obscure the cryptography is within the application. As the `__init__` function from the class pbkdf2 has as signature: 
```python
  def __init__( self, word, salt = None, iterations = 20000, hash_name = "sha512" ):
```
This means that the string `"AES256"` is a hardcoded salt for creating a pbkdf2 hash and this is not good practice.
]

=== Login Flow

==== Entry Point

The login endpoint is `POST /do/login`. It is called once per authentication step. Which step to execute is determined by the first element of `session["need_to_check"]`. The session is initialised by `GET /login` which also resets any in-progress login state.

#figure(
  ```python
  session.clear()
  session[ "process" ] = "login"
  session[ "need_to_check" ] = [ "password" ]
  session[ "logged" ] = False
  ```,
  caption: [Session initialissation before login (`views/login/__init__.py`, ln 59-63)]
)

The usual sequence for an account with TOTP is: `password` -> `totp` -> logged. There is also another sequence for when a security key is activated for the user: `password` -> `securitykey` -> logged. With this sequence, the form will call the `webauthn_begin_assertion` function instead of the login one.

#note[I haven't been able to test the path with the security key on the development server or the production one. There's quite a lot of code linked to it but nothing very critical, I may leave it on the side after a talk with my supervisor.]

==== Step 1, Rate Limiting

Rate limiting is computed before any credential checks on every call to `POST /do/login`. It will first get the `REMOTE_ADDR` from the request headers and then create the `16` supernet from the remote address, this will be the key for the value in the Redis `rate_limit` database. Then the rate limit is applied with this function:

#figure(
  ```py
  def rate_limit_to_seconds( nb ):
        return pow( config.login_rate_limiting_base, max( nb, config.login_rate_limiting_limit ) )
  ```,
  caption: [Exponential formula for rate limiting (`views/login/__init__.py`, ln 113-114)]
)

The default configuration sets the `login_rate_limiting_base` setting to 2 and `login_rate_limiting_limit` to 5. The counter is incremented on both wrong password and unknown username. This means that the rate limiting mechanism does not reveal whether a username exists.

==== Step 2, Password Verification

The password is hashed in the browser first before transmission:

#figure(
  ```py
  password = await generateKey( password, "icnml_" + username, 20000 );
  password = password.substring( 0, 128 );
  password = "pbkdf2$sha512$icnml_" + username + "$20000$" + password;
  ```,
  caption: [Client-Side password hashing (`views/login/templates/login.html`, ln 82-84)]
)

#note[It would be interesting to make a dedicated chapter to how the `generateKey` function is implemented in `app/function.js` and how the `window.crypto` is used.]

The server then check whether the username exists in the `users` table and if not, it uses `pbkdf2.verify()` on a fake hash and a fake stored hash to prevent agains time-based side channel attack before sending back an errror. Then the server checks if the password sent is existing or if the password is verified with `pbkdf2.verify()`:

#figure(
  ```py
  if form_password == None or not utils.hash.pbkdf2( form_password ).verify( user[ "password" ] ):
      current_app.logger.error( "Password not validated" )
      
      trigger_rate_limit()
      
      session_clear_and_prepare()
      
      return jsonify( {
          "error": False,
          "logged": False,
      } ) 
  ```,
  caption: [Password verification (`views/login/__init__.py`, ln 177-187)]
)

#note[This is not very easily readable that that's where the verification is done as it's a `or not` condition which makes things not very obvious at first reading.]

==== Step 3, Active Account Check

After match that is successful, the `users.active` field is checked. Inactive accounts are rejected with message directing the user to contact the administrator. The rate limit is not incremented for inactive accounts since the password was correct.

==== Step 4, Password Paramter Auto-Upgrade

If the stored password hash was produced with a different iternation count or salt length than the current configuration, the password is re-hashed with the current parameters. 

#figure(
  ```py
  _, _, salt, iterations, _ = user[ "password" ].split( "$" )
  iterations = int( iterations )

  if iterations != config.PASSWORD_NB_ITERATIONS or len( salt ) != config.PASSWORD_SALT_LENGTH:
      new_password = utils.hash.pbkdf2(
          form_password,
          utils.rand.random_data( config.PASSWORD_SALT_LENGTH ),
          config.PASSWORD_NB_ITERATIONS
      ).hash()
      config.db.query( "UPDATE users SET password = %s WHERE id = %s",
                        ( new_password, user[ "id" ] ) )
  ```,
  caption: [Password hash auto-updates at login (`views/login/__init__.py`, ln 206-215)]
)

==== Step 5, Session hashed password

As discussed in @session-fields-set, the password from the client-side, which was hashed on the browser of the client, is also as data to create a PBKDF2 hash with the fixed salt `AES256`. The hash created is only stored in the session.

==== Step 6, TOTP Verification

The TOTP secret is stored in `users.totp`. It is loaded into a `pyotp.TOTP` object and the code given by the user is verified within a time window interval which is the equivalent of about 150 seconds. The setting to set this time window is the config as `TOTP_VALIDWINDOW = 5`. 

#figure(
  ```py
  totp_db = pyotp.TOTP( user[ "totp" ] )
  totp_user = request.form.get( "totp", None )
  totp_save_serverside = request.form.get( "save", False )

  ...
  
  if not totp_db.verify( totp_user, valid_window = config.TOTP_VALIDWINDOW ):
  ...
  ```,
  caption: [TOTP verification at login (`views/login/__init__.py`, ln 263-276)]
)

If the verification fails within the window given, the code extends the check up to the settings `TOTP_MAX_VALIDWINDOW` which is set in the config to 1000. If a match is found outside the standard window, the time difference in seconds is returned to the client, but the login is still rejected.

==== Step 7, TOTP Device Trust

After a successful TOTP login, the user can choose to trust the current device for 30 days. The trust record is stored in the Redis `totp` database under a key derived from the username and a hash of the client remote address.

#figure(
  ```py
  if totp_save_serverside in [ True, "true" ]:
    hra = hashlib.sha512( request.headers.environ[ "REMOTE_ADDR" ] ).hexdigest()
    username = session[ "username" ]
    key = "{}_{}".format( username, hra )
    
    config.redis_dbs[ "totp" ].set( key, "ok", ex = 30 * 24 * 3600 )
  ```,
  caption: [TOTP device trust storage (`views/login/__init__.py`, ln 309-314)]
)

On next logins from the same remote address, the presence of the key bypasses the TOTP steps and the TTL is refreshed to another 30 days after a successful password login.

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
