= Development environment setup

This chapter focuses on how to deploy a development environment in several steps. The ressources are not all available 
yet, there's a need to confirm whether or not the libraries used by the web application can be made open-source. 

== Context

ICNML is a legacy Python 2.7 Flask application originally hosted on a remote x86-64 Linux server. Its libraries (`WSQ`, `MDmisc`, `NIST`, `PMlib`) were git submodules, but their remote repositories are no longer accessible. They were manually copied from the server.

The container registry `cr.unil.ch` has a TLS certificate that does not cover the registry subdomain, making direct image pulls fail. The base image must be obtained by other means.

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
    caption: [Table of containers in `docker-compose` file]
)

As the base image is currently corrupted, the image `python:2.7-slim-buster` is used to replace it. The Dockerfile on the git repository uses `debian:11` but this image does not have Python 2 which is essential for the libraries used. 

== Prerequisites

+ Docker engine >= 4.x
+ Git
+ Access to the repository of this bachelor thesis

== Step 1 

Download the repository for creating the development environment created for this thesis here // TODO put the link

```sh
git clone https...
```

== Step 2

The project root contains an `env` file that is passed to the `web` container. You need to set the correct values so that the TOTP is not enforced. 

Create or edit `dev_icnml/env`:

```
ENVTYPE=DEV
```

== Step 3

From the `dev_icnml` directory, start the containers: 

```sh
docker compose up
```

Check all three containers are running.

== Step 4

Access the application by opening your browser at:

```
http://localhost
```

Log in with the admin credentials:

- Username: admin
- Password: admin

== Known limitations

- Not all the tables are created. The `cnm_*` tables are nowhere to be found yet. 
- WSQ binaries do not work on ARM64 system. a platform flag needs to exist for it to work.
- Dependencies version unpinned in the requirements file of the libraries.


== Current state

=== Images

The current Gitlab project called ICNML does not have all the dependencies for the application. In deed, the libraries MDmisc, NIST, WSQ, PiAnoS and PMlib are submodules, but the url for each of them returns a 404. 

The container registry `cr.unil.ch` is a domain that is not present in the TLS certificate and thus it's not possible to pull the images from them without changing the `daemon.json` file from docker to:

```json
"insecure-registries": [
    "cr.unil.ch"
  ]
```

Then the images stored on this container registry were created using the first version of Docker // TODO check which one
and cannot be used with the current version (4.43.1). The problem came from the containerd setting that had to be turned off 
to pull the image. Then, the image pulled seemed to be corrupt as the error returned was:

```bash
docker pull esc-md-git.unil.ch/icnml/docker/web
Using default tag: latest
Error response from daemon: error parsing HTTP 404 response body: unexpected end of JSON input: ""
```

=== Server

The quickest way to resolve this was 