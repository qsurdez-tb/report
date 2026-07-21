#import "../macros.typ": note, concept

= Running ICNML: Development and Production <running-icnml>

#concept[
  Once the migration to Python 3.11 (@python3-migration) was done, ICNML could be run again, and it can be run in two quite different ways. A lightweight development stack brings the whole application up on a laptop with a single command, so that code can be worked on quickly. A production-faithful deployment runs the same application with its full security posture switched on, the two-factor authentication and hardware passkeys that the development stack deliberately disables. The switch between the two modes is, in essence, one environment variable. Understanding what that variable flips, and why the production mode needs a real domain name, is the key to running ICNML correctly. The detailed configuration changes are in @appendix-running-icnml.
]

== The local development stack

For day-to-day work on the code, ICNML runs as a plain `docker compose` stack, brought up from the `icnml-dev` repository.

+ Clone the repository and run `docker compose up`. Three containers start, the Flask application, a PostgreSQL database, and Redis.
+ Create the first administrator with the bootstrap script, `docker compose exec web python /app/create_admin.py`, which inserts an admin account directly and bypasses the normal registration flow.
+ Open `http://localhost` and log in.

The stack is arranged so that a fresh checkout comes up with a usable database and no manual setup. The database container creates the `icnml` role and database on first boot, and loads the numbered install scripts, which carry both the schema and the seed lookup data, including the reconstructed CNM tables that the original scripts were missing (@appendix-dev-env). A health check holds the web container back until PostgreSQL is actually ready. The exact differences from the original repository's compose file are listed in @appendix-running-icnml.

== The switch that matters: `ENVTYPE`

The single most important setting when running ICNML is the `ENVTYPE` environment variable, because it decides whether the application's authentication security mechanisms are on or off.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Aspect][`ENVTYPE=DEV`][`ENVTYPE=PROD`],
    [Two-factor (TOTP + passkey)], [skipped entirely], [enforced],
    [Session cookies], [plain], [marked `Secure`, so only sent over HTTPS],
    [Transport], [plain HTTP on `localhost`], [HTTPS on a real domain],
    [Intended use], [local development], [production and production-faithful testing],
  ),
  caption: [What `ENVTYPE` flips. The development stack runs in `DEV` so a developer can log in over plain HTTP without a second factor. Anything user-facing must run in `PROD`.],
)

The convenience of `DEV` mode is also its danger. It exists only so that a developer can reach the application on `localhost` without a second factor and without HTTPS. It must never be used for a deployment that real users touch, because it disables precisely the protections the rest of this thesis is about. A production or staging instance runs in `PROD`, and `PROD` mode has a hard requirement that `DEV` mode hides.

== Why production needs a real domain

In `PROD` mode the passkey (WebAuthn) authentication is active, and WebAuthn cannot run on `localhost`. This is not an ICNML limitation but a deliberate property of the standard. A passkey is cryptographically bound to the origin, the exact domain name, it was registered under, so that a credential created for one site can never be replayed against another. The browser enforces this, and it refuses to create or use a passkey on `localhost` at all, returning a `LocalhostNotAllowed` error (@appendix-dev-env). Secure cookies compound the requirement, since `PROD` marks them `Secure`, they are only sent over HTTPS, so an instance served over plain HTTP would loop endlessly on the login page.

The consequence is concrete. Testing the migrated application with its real security stack cannot be done on a laptop alone, it needs a machine reachable under a genuine domain name, over HTTPS. For this thesis a dedicated dev-mirror box was used, served over TLS under its own domain, with the application told through two environment variables (`DOMAIN` and `RPID`) to bind its passkeys to that name rather than to the production domain. This is the environment in which the migrated WebAuthn code (@python3-migration) was actually validated, a step the local stack structurally cannot perform.

Two practical points follow from the origin binding. Passkeys registered against the production domain do not work on a differently-named mirror and must be re-registered there, whereas TOTP secrets are not tied to a domain and keep working after a database restore. The full set of configuration changes that turn the local stack into a production-faithful one is in @appendix-running-icnml.

== Relationship to the original production deployment

Previous production was the automated Swarm pipeline described earlier (@deployment), which is currently inert. The single-box `docker compose` deployment described here is not a rebuild of that pipeline, it is a demonstration that the migrated application runs correctly, with its full security posture, on a machine other than the original server. It's also a proof that the Swarm pipeline was not necessary to run the service as intended and is a starting point for further deployment development. As such it is the practical foundation for re-establishing a real production deployment around the Python 3.11 stack, which, together with the migration itself, is the natural continuation of this work.

== Assessment

The headline result is simple. After the migration, ICNML runs again, both as a convenient local development stack and as a production-faithful deployment with two-factor authentication and passkeys genuinely working. The `ENVTYPE` switch makes the difference between the two explicit rather than hidden, which is the right shape for a security-sensitive application.
