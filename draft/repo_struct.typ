== Repository structure

This file will focus on the structure of the repositories and how they interact with one another. 

=== List of directories

- afis_assignments
- base
- cdn
- docker
- documents
- fingerprintexperts_assessment
- config/production
- tools
- web

=== Description

==== Repo afis_assignemnts

This repository contains one R file. This file is name `TrialSortingScript` and relies on a csv file that is not present.
This seems to be filtering out some data from labs. This seems to be outside the scope of this thesis. It may be removed
in the future.

==== Repo base

This repository contains on Dockerfile as well as a gitlab cicd file and a license. The Dockerfile is a minimal debian install.
It updates, upgrades and installs `gettext-base`. It then removes the `/var/lib/apt/lists/*`.

The cicd, when run, uses Kaniko to build the Docker image and pushes it to Gitlab's container registry with two tags. 
The commit SHA and latest. It has only seen 7 commits and the last one dates from 2022.

There are two images in the container repository of this repo:
- base/cache
- base

==== Repo cdn

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

==== Repo docker

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

==== Repo documents

There is only one pdf file within this repository. It is a donor consent form. 

==== Repo fingerprintexperts_assessment

This repo contains the results from tests on ICNML images with fingerprint experts. It's out of scope. It may be deleted later on.


==== Repo config/production

This repo seems to be a part of an automated process. The timestamps of the last commits correspon to the ones on 
the web repository. 

==== Repo scripts

This repo hosts scripts used database management. There is one for creating the backup, one for cleaning the backups, one
to duplicate the database and one for combining gpg keys.

==== Repo tools

This repo contains scripts in python to migrate data and convert it. It relies on submodules that are not accesible today.

==== Repo web

This repo is where the web application code is hosted. It has the cdn repo as submodule, however I also see some 
dependencies on MDmisc and NIST libraries. There is a flask application, sql schema for a database. There are also 
a lot of utils files related to encryption, so I think this is where I will spend most of my time after creating 
a dev environment. 