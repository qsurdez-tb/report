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