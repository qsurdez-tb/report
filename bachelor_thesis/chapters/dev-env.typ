= Development environment setup

This chapter focuses on how to deploy a development environment for ICNML. Following these steps will give you a running instance of the application with its three services (web, database, cache) on your machine.

== Context

ICNML is a legacy Python 2.7 Flask application originally hosted on a remote x86-64 Linux server. Its dependencies (`WSQ`, `MDmisc`, `NIST`, `PMlib`) were originally git submodules, but their remote repositories are no longer accessible. They were recovered by copying them from the production server. The original Docker base image (`cr.unil.ch/icnml/base:latest`) is also inaccessible due to a TLS misconfiguration on the container registry and image format incompatibility with current Docker versions. Thus, the development envirionment uses `python:2.7-slim-buster` as a replacement base image.

The stack runs three Docker containers:

#figure(
   table(
      columns: (auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Service*][*Image*][*Role*],
      [`web`],       [`cr.unil.ch/icnml/base:latest`],            [Python 2.7 Flask application],
      [`db`], [`postgres:11`],            [PostgreSQL database],
      [`redis`], [`redis:6`],            [Redis cache],
    ),
    caption: [Containers in `docker-compose` file]
)

== Prerequisites

+ Docker engine >= 4.x
+ Git
+ Access to the `icnml-dev` private repository


== Step 1, Clone the repository

```sh
git clone https://github.com/qsurdez-tb/icnml-dev.git
cd icnml-dev
```

== Step 2, Configure the envirionment file

The `web` container reads an `env` file at the project root. This file controls application behaviour. At minimum, set `ENVTYPE` to `DEV` to disable TOTP enforcement:

```
ENVTYPE=DEV
```

Create or edit `icnml-dev/env` with the above content before starting the containers.

#block[
  *Note*: this is not a `.env` file but indeed a `env` file.
]

== Step 3, Copy the GPG keys

The application requires GPG keys to be present in the `web/keys` directory. Copy the keys (Are they created by the dev? Are they given? We shall see in the future... Cause only the public key was present on the server) // TODO check that relatively quickly ^^

```sh
cp -r ./config/keys ./web
```

== Step 4, Start the containers

From the `dev_icnml` directory, start all three services: 

```sh
docker compose up
```

Check all three containers are running.

#block[
  *ARM64 note:* The `WSQ` library contains binaries compiled only for `linux/amd64`. On ARM64 hosts, the `web`service must be force to run under emulation. The provided `docker-compose` file already sets `platform: linux/amd64` on the `web` service for this reason.
]

== Step 5, Create the admin account

Run the script on the `web` service to create an admin account with:

```sh
docker compose exec web python2 /app/create_admin.py
```

This will prompt a minimalist CLI to create an admin acccount with the credentials provided by the user.

== Step 6, Access the application


Open your browser at: 

```
http://localhost
```

Log in with the admin credentials created from the previous steps.

== Current Known limitations

#figure(
  table(
      columns: (auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left),
      table.header[*Feature*][*Why*],
      [New user registration], [The admin must sign the validation with a registered passkey. There is no way to skip this test and currently it's a LocalhostNotAllowed error when trying to create it. New accounts must be insterted directly in the DB.],
      [TOTP setup], [Reachable only after the new user validation by the admin, thus this is not working.],
      [Password reset], [Sends an email via SMTP. No mail server is running in this environment, the email is not delivered.],
      [PiAnoS integration], [The feature is disabled],
      [GPG file encryption], [Still inspecting that and if needed added to this how-to dev setup]
    ),
    caption: [Features not available in development environment]
)

== Explanation of struggles 

=== 1. Container registry TLS certificate mismatch

The Let's Encrypt certificate on the Gitlab instance covers `bunny.unil.ch` but not `cr.unil.ch`. Any `docker pull cr.unil.ch/icnml/...` call
fails with a TLS verification error. Adding `cr.unil.ch`to Docker's `insecure-registries` in `daemon.json` was attempted as a workaround but did not fully resolve the problem because of the manifest format issue below.

=== 2. Docker manifest v1 format no longer supported

The base image was originally built and pushed with the old manifest format. Since containerd v2.0, this format is rejected.

Rebuilding the image with a v2 would have required access to the original build envionment, which was unavailable. Disabling containerd was trie but produces an `unexcpected end of JSON input` error instead.

=== 3. `docker save` failure on server

Attempting to export the server image with `docker save` failed: 

```
Error response from daemon: open
/var/lib/docker/overlay2/.../merged/var/www/library/NIST/NIST/XML/__init__.py:
no such file or directory
```

The overlay filesystem of the image on the server was corrupt or incomplete, making a direct save impossible. The workaround was to export a running container instead of the stored image

=== 4. No usable base image, had to export a live container

Because the image could neither be pulled from the registry nor saved from the daemon, the only viable path was to connect to the production server, find a healthy container, and export it with `docker export`. The resulting archive was then loaded locally and retagged as `cr.unil.ch/icnml/base:latest`. However, this wasn't a solution, as the next developer should be able to build from a Dockerfile or a docker compose file. Trying to bypass the base image was the path chosen from now on.

=== 5. Python 2.7 end-of-life, broken package

Python 2.7 reached end of life in January 2020. The `apt` sources in `python:2.7-slim-buster` point to repositories that no longer server packages at their original URLs. The `sources.list` file had to be redirected to Debian's EOL archive URLs before any `apt-get install` call could succeed.

=== 6. `.pth` file targeting the wrong Python directory

The Dockerfile added custom libraries to Python's module search path by writing a `.pth` file:

```dockerfile
RUN find /library -maxdepth 1 -mindepth 1 \
    > /usr/local/lib/python2.7/dist-packages/mdedonno.pth
```

`dist-packages` is a Debian convetion for the system-installed Python. The official `python:2.7-slim-buster` image compiles Python from source and uses `site-packages`. Python never read the file, causing every import of `Mdmisc`, `NIST`, `WSQ` and `PMlib` to fail with `ImportError: No module named MDmisc`. The fix was to target `site-packages` instead.

=== 7. WSQ binaries compiled only for x86-64

The `WSQ` library ships pre-compiled binaries (`cwsq`, `dwsq`) that only run on `linux/amd64`. On Apple Silicon (ARM64) these cannot execute natively. The Dockerfile's `RUN python doctester.py` step runs `WSQ` doctests, which silently failed on ARM64, causing the build to abort. The setting `platform` in the docker compose file is a solution to emulate the a x86-64 environment.

=== 8. Missing CNM database tables

The numbered SQL install scripts did not include DDL for any of the CNM-related tables: `cnm_annotation`, `cnm_assignment`, and others. These tables were absent from all migration files, and direct access to the production schema was difficult to obtain. A new file `30-cnm_tables.sql` had to be created by reconstructing from the source code and the DDL from the production database.

=== 9. WebAuthn `LocalhostNotAllowed` on localhost

Even in `DEV` mode, attempting to register a new passkey through the browser produced a `LocahostNotAllowed` error from the WebAuthn API. New user accounts cannot be validated through the normal UI and must be inserted directly into the database.

