= Developer guide : running and deploying ICNML <appendix-dev-guide>

This appendix reproduces the developer guide kept in the `icnml-dev` repository (`README.md`), the single reference a new contributor needs to run and deploy the migrated platform. It runs on Python 3.11 (migrated from the original 2.7) and is fully containerised with Docker Compose. The stack is four services.

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(220) } else { white },
  align: (left, left, left),
  table.header[Service][Image / build][Role],
  [`web`],     [`web/` (gevent WSGI)], [The Flask application, served on port 5000 in-container],
  [`db`],      [`postgres:14`],        [PostgreSQL, auto-initialised from `web/app/sql/install/` on first boot],
  [`redis`],   [`redis/` (redis:6)],   [Sessions, cache, TOTP, rate-limiting, share links],
  [`openlqm`], [`openlqm/`],           [Image-quality metric server (HTTP, port 8500)],
)

*Requirements.* Docker and Docker Compose. On Apple Silicon everything is pinned to `linux/amd64` (the WSQ and LQM binaries are x86-64), so builds run under emulation. This works but is slower.

There are two compose files, one per scenario.

- `docker-compose.local.yml` for *local development* (plain HTTP, dev mode).
- `docker-compose.yml` for a *production-shaped* deployment (HTTPS, production cookies).

== Running the development version

Development mode disables 2FA enforcement, sends emails to the console instead of SMTP, serves plain HTTP, and uses portable named Docker volumes.

```bash
git clone https://github.com/qsurdez-tb/icnml-dev.git
cd icnml-dev

# Build and start the full stack
docker compose -f docker-compose.local.yml up --build

# In another terminal, create the first admin (run once, after the DB initialises)
docker compose -f docker-compose.local.yml exec web python /app/create_admin.py
```

Open `http://localhost:8080`.

- The `db` container runs the numbered SQL scripts in `web/app/sql/install/` only on an empty data volume. To re-seed from scratch, wipe the volume with `docker compose -f docker-compose.local.yml down -v`.
- `create_admin.py` prompts interactively, or accepts `--username --email --password` for scripted use.

== Deploying the production version

`docker-compose.yml` runs the app the way production expects, gevent serving HTTPS on 5000, secure and strict session cookies, and production WebAuthn settings. Before deploying on a host, a few machine-specific and security-sensitive settings must be adjusted.

=== Fix the machine-specific paths

The committed file has host paths from the original server. Change them.

```yaml
db:
  volumes:
    # replace the absolute host path with a named volume (or your own path)
    - icnml-pgdata:/var/lib/postgresql/data
    - ./web/app/sql/install:/docker-entrypoint-initdb.d:ro

# add at the bottom:
volumes:
  redis-data:
  icnml-pgdata:
```

=== Provide real configuration

Set these through the `env` file (already referenced by the compose file) or the service's `environment` block. Defaults live in `web/app/config.py`.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(220) } else { white },
  align: (left, left),
  table.header[Variable][Why it matters in production],
  [`SECRET_KEY`], [Must be set and stable. It defaults to a random value regenerated on every boot, which invalidates all sessions on restart. Generate once and keep it secret.],
  [`ENVTYPE`], [Leave unset (or non-`DEV`) for production, which enables `Secure` and `SameSite=Strict` cookies and SMTP email.],
  [`DOMAIN`], [Public HTTPS origin, for example `https://icnml.example.org`. Used for links and the WebAuthn origin.],
  [`RPID`], [WebAuthn Relying-Party ID, the registrable domain (for example `icnml.example.org`). Admin login breaks if this does not match `DOMAIN`.],
  [`DB_URL`], [Only if an external PostgreSQL is used. Defaults to the internal `db` service.],
  [`SMTP_SERVER`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_SENDER`], [Required for password-reset and new-user emails.],
  [`OPENLQM_URL`], [`http://openlqm:8500` (already set in the compose file).],
  [`WATERMARK_AES_KEY`, `WATERMARK_SCHEME_KEY`], [Watermarking secrets (see the current `env` file for the format).],
)

=== TLS

The web container's entrypoint generates a self-signed certificate and serves HTTPS on 5000. Two options.

- *Reverse proxy (recommended).* Terminate TLS at nginx, Traefik or Caddy in front, keep `BEHIND_PROXY=True` (the default), and change the `web` port publish from `127.0.0.1:5000:5000` to whatever the proxy expects.
- *Real certificate in-container.* Mount `cert.pem` and `key.pem` and point `CERTIFICATE_ROOT_PATH` at their directory (`ICNML_SSL=1`, the default). Use `ICNML_SSL=0` only when TLS is handled entirely upstream.

The GPG keys the app imports at startup are already committed under `web/keys/`.

=== Build, start, bootstrap

```bash
docker compose up --build -d
docker compose exec web python /app/create_admin.py
```

== Testing the vendored libraries

`docker-compose.test.yml` runs the Python 3.11 doctest harness for the De Donno libraries (NIST, MDmisc, WSQ).

```bash
docker compose -f docker-compose.test.yml run --rm nist-tests
```

There is no application-level test suite or linter in this repository.

== Changes from the original repository

=== `docker-compose.yml`

#table(
  columns: (auto, 1fr, 1fr, 2fr),
  stroke: 0.5pt,
  fill: (col, row) => if row == 0 { luma(220) } else { white },
  align: (left, left, left, left),
  table.header[Setting][Before][After][Reason],
  [`db.image`], [`postgres:11`], [`postgres:14`], [pg11 does not support `default_table_access_method` used in the SQL dump files],
  [`db.environment`], [`POSTGRES_PASSWORD` only], [+ `POSTGRES_USER`, `POSTGRES_DB`], [Creates the `icnml` role and database automatically on first boot],
  [`db` init SQL], [`./db/icnml_ddl.sql` (schema only)], [`./web/app/sql/install/` (schema + seed)], [The numbered install files include lookup-table data],
  [`db.healthcheck`], [none], [`pg_isready -U icnml -d icnml`], [Prevents the web container from starting before PostgreSQL is ready],
  [`web.entrypoint`], [`python2 dev.py`], [removed (Dockerfile default)], [The Dockerfile's `entrypoint.sh` runs `runner.py` (gevent), the correct server],
  [`web.working_dir`], [`/app`], [removed], [Redundant, already set in the Dockerfile],
  [`web.depends_on`], [container started], [`db: service_healthy`], [Waits for PostgreSQL to be ready, not just the container],
)

=== `web/app/sql/install/30-cnm_tables.sql` (new file)

The numbered install files (`01`–`29`) were missing all CNM-related tables. This file adds `cnm_annotation`, `cnm_assignment`, `cnm_assignment_type`, `cnm_candidate`, `cnm_candidate_filetype`, `cnm_data_type`, `cnm_folder`, `cnm_result`, `cnm_result_quality`, `cnm_result_targettype`, `fingers_same`, and `tenprint_cards`.

=== `web/app/create_admin.py` (new file)

Bootstrap script to create the first Administrator account, bypassing the normal registration flow. It replicates the client-side hash (`pbkdf2(password, "icnml_<username>", 20000)`) and the server-side second hash so the stored password is compatible with the login form.
