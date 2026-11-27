# lldap CI Dockerfile.ci.debian (pinned commit)

## Source URL(s) + date
- https://raw.githubusercontent.com/lldap/lldap/48a0a8d961f32bd8e3263b202053ce49a6c94781/.github/workflows/Dockerfile.ci.debian
- Fetched 2026-11-26. This is a CI helper Dockerfile, not the published image Dockerfile.

## What it is
Layer on top of `localhost:5000/lldap/lldap:debian-base` (CI-local registry image) that installs `gosu` 1.17 and copies `docker-entrypoint.sh`.

## Install/build steps
- `ENV GOSU_VERSION=1.17`.
- Installs wget, ca-certificates, gnupg; downloads `gosu-<arch>` and its `.asc` from github.com/tianon/gosu releases.
- Verifies signature with key `B42F6819007F00F88E364FD4036A9C25BF357DD4` (keyserver loop), removes gnupg-only packages after.
- `chmod +x /usr/local/bin/gosu`; checks `gosu --version` and `gosu nobody true`.
- `COPY --chown=$USER:$USER docker-entrypoint.sh /docker-entrypoint.sh`.

## Entrypoint/flags
- Entrypoint script is `/docker-entrypoint.sh` (script content not in this file).

## Gotchas
- Uses `$USER` in COPY but the shown file does not set USER in the fetched portion (fetch truncated at the COPY line; the rest of the file was not seen).
- gosu is used for privilege drop in the entrypoint, which implies the upstream image starts as root and drops; check against the chart's `runAsUser: 0`-less config before assuming rootless.
