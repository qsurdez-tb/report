= Authentication — implementation details <appendix-authentication>

This appendix holds the code excerpts and the full per-role route inventory that the authentication chapter (@roles-and-permissions) refers to. The chapter body keeps the concepts and the decisions; the reference material lives here.

== Login and session code excerpts <auth-code>

#figure(
  ```python
  SESSION_TYPE = "redis"
  SESSION_PERMANENT = False
  SESSION_REFRESH_EACH_REQUEST = True
  PERMANENT_SESSION_LIFETIME = 2 * 60 * 60   # 2 hours
  ```,
  caption: [Session configuration (`config.py`, ln 39-43).]
)

#figure(
  ```python
  if envtype.upper() != "DEV":
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = "Strict"
    domain = "https://icnml.unil.ch"
    RP_ID = "icnml.unil.ch"
  ```,
  caption: [Production-only cookie hardening and WebAuthn relying-party id (`config.py`, ln 99-103).]
)

#figure(
  ```python
  session[ "password" ] = utils.hash.pbkdf2( form_password, "AES256", config.PASSWORD_NB_ITERATIONS ).hash()
  ```,
  caption: [The session `password` field: a PBKDF2 hash of the submitted (already client-hashed) password, keyed with the hardcoded salt `"AES256"` (`views/login/__init__.py`, ln 221).]
)

#figure(
  ```python
  session.clear()
  session[ "process" ] = "login"
  session[ "need_to_check" ] = [ "password" ]
  session[ "logged" ] = False
  ```,
  caption: [Session initialisation before login (`views/login/__init__.py`, ln 59-63).]
)

#figure(
  ```python
  def rate_limit_to_seconds( nb ):
        return pow( config.login_rate_limiting_base, max( nb, config.login_rate_limiting_limit ) )
  ```,
  caption: [Exponential rate-limit delay; base 2, floor 5 (`views/login/__init__.py`, ln 113-114).]
)

#figure(
  ```js
  password = await generateKey( password, "icnml_" + username, 20000 );
  password = password.substring( 0, 128 );
  password = "pbkdf2$sha512$icnml_" + username + "$20000$" + password;
  ```,
  caption: [Client-side password pre-hashing in the browser (`views/login/templates/login.html`, ln 82-84).]
)

#figure(
  ```python
  if form_password == None or not utils.hash.pbkdf2( form_password ).verify( user[ "password" ] ):
      current_app.logger.error( "Password not validated" )
      trigger_rate_limit()
      session_clear_and_prepare()
      return jsonify( { "error": False, "logged": False, } )
  ```,
  caption: [Password verification, embedded inside an `or not` condition (`views/login/__init__.py`, ln 177-187).]
)

#figure(
  ```python
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
  caption: [Password-parameter auto-upgrade: re-hash on login when stored parameters differ (`views/login/__init__.py`, ln 206-215).]
)

#figure(
  ```python
  totp_db = pyotp.TOTP( user[ "totp" ] )
  totp_user = request.form.get( "totp", None )
  if not totp_db.verify( totp_user, valid_window = config.TOTP_VALIDWINDOW ):
      ...
  ```,
  caption: [TOTP verification, allowing a $plus.minus 5$ time-step window (`views/login/__init__.py`, ln 263-276).]
)

#figure(
  ```python
  if totp_save_serverside in [ True, "true" ]:
    hra = hashlib.sha512( request.headers.environ[ "REMOTE_ADDR" ] ).hexdigest()
    key = "{}_{}".format( session[ "username" ], hra )
    config.redis_dbs[ "totp" ].set( key, "ok", ex = 30 * 24 * 3600 )
  ```,
  caption: [Device-trust record keyed on username and hashed client IP; its presence skips the TOTP step for 30 days (`views/login/__init__.py`, ln 309-314).]
)

#figure(
  ```python
    make_credential_options = webauthn.WebAuthnMakeCredentialOptions(
        challenge, config.rp_name, config.RP_ID, ukey, username, username, None )
    registration_dict = make_credential_options.registration_dict
    registration_dict[ "authenticatorSelection" ] = {
        "authenticatorAttachment": "cross-platform",
        "requireResidentKey": False,
        "userVerification": "discouraged"
    }
  ```,
  caption: [WebAuthn registration options, restricted to portable ("cross-platform") hardware keys (`views/login/__init__.py`, ln 409-429).]
)

== Full per-role route inventory <auth-routes>

=== Administrator capabilities

- New-user management: validate pending sign-in requests (`GET /validate_signin`).
- Submission overview: view all submissions (`GET /admin/submission/list`).
- AFIS management: create targets (`POST /admin/target/<submission_id>/<pc>/new`), delete targets or candidate matches, update assigned AFIS users, batch-assign targets (`POST /admin/afis/batch_assign/do`).
- Full-resolution images: download uncompressed originals (`GET /image/file/<id>/full_resolution`).
- PiAnoS integration: synchronise users and segments to the external PiAnoS system (`GET /pianos_api/add_user/all`, `GET /pianos_api/add_segments/all`; not working in production).
- Mark deletion in admin context (`POST /admin/<submission_id>/mark/<m_id>/delete`).
- UUID inspection: retrieve the raw database table for any UUID (`GET /uuid/get_table/<uuid>`).

=== Submitter routes (own submissions only)

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Action][Routes],
    [Create donor + submission], [`POST /submission/do_new` — creates `users`, `donor_dek`, and `submissions` rows.],
    [Upload files],              [`POST /upload`, `/submission/<id>/add_files`, `/submission/<id>/add_marks`, `/submission/<id>/consent_form`.],
    [Annotate tenprints],        [Set template, quality, segment coordinates, and general pattern on tenprint cards.],
    [Annotate marks],            [Set PFSP, delete marks.],
    [Manage submission],         [Set nickname, set GP, delete submission, view targets.],
    [Browse own data],           [`GET /submission/list`, tenprint list, mark list, segment views.],
  ),
  caption: [Routes of interest for the Submitter role. `@submission_has_access` returns HTTP 403 when the `submission_id` was not created by the current submitter.]
)

=== Trainer routes

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Route][Purpose],
    [`GET  /marks/search`],           [Search and filter marks for training.],
    [`GET  /marks/exercise/<id>`],    [View a training exercise.],
    [`GET  /marks/folder/<id>`],      [Browse an exercise folder.],
    [`POST /exercises/add_tenprint`], [Associate a tenprint card with an exercise.],
  ),
  caption: [Routes of interest for the Trainer role (read-only access to the library).]
)

=== AFIS routes

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Route][Purpose],
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
  caption: [Routes of interest for the AFIS role.]
)
