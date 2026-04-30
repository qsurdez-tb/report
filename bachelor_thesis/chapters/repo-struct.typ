= Repository structure <repo-struct>

This chapter focus on the repositories structure as well as their interaction with one another. It is used as a backbone
to understand the dependencies of the directories as well as how they're linked together through the CICD. 

== List of directories <list-directories>

- afis_assignments
- base
- cdn
- docker
- documents
- fingerprintexperts_assessment
- config/production
- tools
- web

== Description <repo-struct-description>

=== Repo afis_assignemnts <repo-afis-ass>

This repository contains one R file. This file is name `TrialSortingScript` and relies on a csv file that is not present.
This seems to be filtering out some data from labs. This seems to be outside the scope of this thesis. It may be removed
in the future.

=== Repo base <repo-base>

This repository contains on Dockerfile as well as a gitlab cicd file and a license. The Dockerfile is a minimal debian install.
It updates, upgrades and installs `gettext-base`. It then removes the `/var/lib/apt/lists/*`.

The cicd, when run, uses Kaniko to build the Docker image and pushes it to Gitlab's container registry with two tags. 
The commit SHA and latest. It has only seen 7 commits and the last one dates from 2022.

There are two images in the container repository of this repo:
- base/cache
- base

=== Repo cdn <repo-cdn>

This repo hosts all the js and css that is considered as libraries for the web application. Here's an exhaustive lists of
what is present within the repo:
- chosen
- aes
- pbkdf2
- dropzone
- jquery
- loadingcss
- md5.min
- rangeslider.min
- toastr.min
- base64
- moment.min
- otplib-browser
- sha512
- underscore-min

=== Repo docker <repo-docker>

This repo has the description "ICNML application builder process". From the README, we can understand that the docker 
repo has submodules. After testing, today it cannot reach them. This repository is mainly focused on the CICD pipeline.

From the timestamps of the last commit on the web repository and this one, it seems there's an automation in place to 
keep this repository updated with the web one. 

The README emphasizes that this is not for development and then gives info on how to setup a development environment 
with the submodules. It is not clear what the responsability or scope of this repository is. 

We can see that the web repository is a submodule of this one.

There are 3 images in the container repository of this repo:
- docker/web/cache
- docker/redis
- docker/web

=== Repo documents <repo-doc>

There is only one pdf file within this repository. It is a donor consent form. 

=== Repo fingerprintexperts_assessment <repo-fingerprint>

This repo contains the results from tests on ICNML images with fingerprint experts. It's out of scope. It may be deleted later on.


=== Repo config/production <repo-prod>

This repo seems to be a part of an automated process. The timestamps of the last commits correspon to the ones on 
the web repository. 

=== Repo scripts <repo-scripts>

This repo hosts scripts used database management. There is one for creating the backup, one for cleaning the backups, one
to duplicate the database and one for combining gpg keys.

=== Repo tools <repo-tools>

This repo contains scripts in python to migrate data and convert it. It relies on submodules that are not accesible today.

=== Repo web <repo-web>

This repo is where the web application code is hosted. It has the cdn repo as submodule, however I also see some 
dependencies on MDmisc and NIST libraries. There is a flask application, sql schema for a database. There are also 
a lot of utils files related to encryption, so I think this is where I will spend most of my time after creating 
a dev environment.

== Outdated libraries

The analysis of the `requirements.txt` file from the web repository showed several critically outdated libraries. Each one carrying security vulnerabilities that can affect the application.

#figure(
  table(
      columns: (auto, auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (center + horizon, left, center, left),
      table.header[Library][Risk],
      [`pycrypto==2.6.1`], [Last updated 11 years ago. Has two known CVEs: CVE-2018-6594 (High), CVE-2013-7459 (Critical). The library is abandoned and should be removed as it's not used in the app.],
      [`cryptography==3.3.2`], [Old version with multiple known CVEs: CVE-2026-26007 (High), CVE-2023-50782 (High), among others. The newest version has no known vulnerabilities.],
      [`pillow==6.2.2`], [Old version with known CVEs: CVE-2021-28675 (High), CVE-2021-25289 (High), among others. The newest version has no known vulnerabilities.],
      [`python2.7`], [Reached end-of-life in January 2020 and no longer receives security patches. Known CVEs remain pending: CVE-2023-24329 (Medium), CVE-2022-48560 (Medium)]
    ),
    caption: [Most critical dependencies of the app, rating of CVEs from @cve-site]
)

The main culprit here is that the codebase runs on Python2.7. This will constrain all dependencies to use old versions, which are potentially vulnerable. New versions of most packages have dropped Python2 support. This makes it difficult to simply upgrade one or two libraries.

A good solution would be to upgrade the codebase to Python3.9+, which would allow up-to-date, free of CVEs, versions of affected libraries. 

== Schema <repo-struct-schema>

#figure(
  image("../assets/repo_dependencies.png", width: 80%),
  caption: [
    Repositories dependencies
  ],
)
