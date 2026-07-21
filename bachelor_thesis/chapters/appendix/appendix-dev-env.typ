= Development Environment : obstacles and resolutions <appendix-dev-env>

The obstacles encountered while getting the legacy Python 2.7 environment to run at all, before the migration that resolved their common root cause (@python3-migration). Almost nothing about the original environment was reproducible as-is, this is the full account of what had to be cleared, and how.

== 1. Container-registry TLS certificate mismatch

The Let's Encrypt certificate on the GitLab instance covers `bunny.unil.ch` but not `cr.unil.ch`, so any `docker pull cr.unil.ch/icnml/...` fails with a TLS verification error. Adding `cr.unil.ch` to Docker's `insecure-registries` was tried but did not fully help, because of the manifest issue below.

== 2. Docker manifest v1 no longer supported

The base image was pushed with the old manifest format, rejected since containerd v2.0. Rebuilding it as v2 would have needed the original build environment, which was unavailable. Disabling containerd produced an `unexpected end of JSON input` error instead.

== 3. `docker save` failure on the server

Exporting the server image failed:

```
Error response from daemon: open
/var/lib/docker/overlay2/.../merged/var/www/library/NIST/NIST/XML/__init__.py:
no such file or directory
```

The image's overlay filesystem was corrupt or incomplete. The workaround was to export a running container rather than the stored image.

== 4. No usable base image, exported a live container

Since the image could neither be pulled nor saved, the only path was to connect to the production server, find a healthy container, and `docker export` it. The archive was loaded locally and retagged `cr.unil.ch/icnml/base:latest`. This is a stopgap, not a solution, the next developer should be able to build from a Dockerfile, so bypassing the base image became the chosen direction.

== 5. Python 2.7 end-of-life, broken package sources

The `apt` sources in `python:2.7-slim-buster` point to URLs that no longer serve packages. The `sources.list` had to be redirected to Debian's EOL archive URLs before any `apt-get install` could succeed.

== 6. `.pth` file targeting the wrong Python directory

The Dockerfile registered the custom libraries via a `.pth` file:

```dockerfile
RUN find /library -maxdepth 1 -mindepth 1 \
    > /usr/local/lib/python2.7/dist-packages/mdedonno.pth
```

`dist-packages` is Debian's directory for the system Python, but the official image compiles Python from source and uses `site-packages`. Python never read the file, so every import of `MDmisc`, `NIST`, `WSQ` and `PMlib` failed with `ImportError`. The fix was to target `site-packages`.

== 7. WSQ binaries compiled only for x86-64

The `WSQ` library ships pre-compiled `cwsq`/`dwsq` binaries that only run on `linux/amd64`. On Apple Silicon they cannot execute natively, and the Dockerfile's `RUN python doctester.py` step silently failed, aborting the build. Setting `platform: linux/amd64` in the compose file to emulate x86-64 resolves it.

== 8. Missing CNM database tables

The numbered SQL install scripts contained no DDL for the CNM tables (`cnm_annotation`, `cnm_assignment`, and others). They were absent from every migration file, and production-schema access was hard to obtain. A new `30-cnm_tables.sql` was reconstructed from the source code and the production DDL.

== 9. WebAuthn `LocalhostNotAllowed`

Even in `DEV` mode, registering a passkey in the browser returns a `LocalhostNotAllowed` error from the WebAuthn API. New accounts therefore cannot be validated through the UI and must be inserted directly into the database.
