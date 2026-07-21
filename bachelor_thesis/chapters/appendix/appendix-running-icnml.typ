#import "../../macros.typ": note

= Running ICNML : configuration details <appendix-running-icnml>

The concrete configuration behind the two ways of running ICNML (@running-icnml).

== The development stack, versus the original repository

The local `docker compose` stack differs from the original repository's compose file in the following ways, each a small change that lets a fresh checkout come up with a working, seeded database.

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left, left),
    table.header[Setting][Before][After][Reason],
    [Database image], [`postgres:11`], [`postgres:14`], [PostgreSQL 11 does not support a directive used in the SQL dump files.],
    [Database env], [password only], [+ `POSTGRES_USER`, `POSTGRES_DB`], [Creates the `icnml` role and database automatically on first boot.],
    [Init SQL], [schema only], [numbered `install/` scripts], [The numbered files carry the seed lookup data as well as the schema.],
    [Health check], [none], [`pg_isready`], [Holds the web container back until PostgreSQL is ready.],
    [Web server], [`dev.py` (Flask dev server)], [`runner.py` (gevent)], [Runs the same production server locally, via the image default.],
    [Web env], [none], [`PYTHONUNBUFFERED`, `ICNML_SSL=0`], [Makes logs appear immediately and serves plain HTTP for local access.],
    [Startup order], [container started], [`service_healthy`], [Waits for PostgreSQL to be ready, not merely launched.],
  ),
  caption: [Changes from the original compose file that make the local stack self-contained.],
)

Two supporting files were added to the repository. A new `30-cnm_tables.sql` reconstructs the CNM tables (`cnm_annotation`, `cnm_assignment`, `cnm_candidate`, and others) that were missing from every numbered install script. A new `create_admin.py` bootstraps the first administrator account, reproducing the client-side and server-side password hashing (@appendix-authentication) so the stored credential is compatible with the normal login form.

== Turning the stack production-faithful

The production-faithful mirror runs the same application in `PROD` mode on a machine with its own domain name. The changes from the development stack are the following.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Change][Why],
    [`ENVTYPE` set to `PROD` (from `DEV`)], [`DEV` skipped the entire two-factor block and disabled secure cookies. `PROD` enables TOTP and passkeys.],
    [`DOMAIN` and `RPID` set to the box's own domain], [In non-`DEV` mode these were hardcoded to the production domain. `config.py` was changed to read them from the environment, with the production values kept as defaults so production is unaffected. This gives the mirror its own passkey identity.],
    [`ICNML_SSL=0` override dropped, published on `443`], [The container serves HTTPS itself. `PROD` marks cookies `Secure`, so a plain-HTTP instance would loop on login, and the browser origin must be the real HTTPS domain for passkeys to bind.],
    [`postgres:14` kept], [Production runs 11.22, but a seed script uses a directive that crashes PostgreSQL 11 on initialisation. Version 14 restores an 11.22 dump without trouble.],
  ),
  caption: [The changes that take the local stack to a production-faithful deployment on another machine.],
)

#note[Two operational points. Passkeys registered against the production domain are dead on a differently-named mirror and must be re-registered after the first login, whereas TOTP secrets are not domain-bound and keep working once data is restored. Restoring the full production database also requires repointing the database storage volume to a disk with room for it, as the dataset is far larger than a typical root filesystem.]
