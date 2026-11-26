# ihexxa/quickshare (GitHub)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/ihexxa/quickshare (repo; README via https://raw.githubusercontent.com/ihexxa/quickshare/master/README.md)
- https://github.com/ihexxa/quickshare/blob/f8216ab/Dockerfile (fetched as raw at commit f8216ab)
- https://github.com/ihexxa/quickshare/releases/tag/v0.11.4 (release page, asset list did not render)
- Not fetched (contain ${ or are binary downloads, see README.md): https://raw.githubusercontent.com/ihexxa/quickshare/v${VERSION#v}/LICENSE, releases/download zips.

## What it is
"A succinct file sharing server". Browser-based upload/download, no client app needed. Go backend with embedded web frontend (Node/yarn build). Features: resumable downloads, download limits, adding files from local storage.

## Install/build steps and build deps (upstream Dockerfile, commit f8216ab)
```
FROM node:lts AS build-fe
ADD . /quickshare
WORKDIR /quickshare
RUN yarn run build:fe

FROM golang:1.24 AS build-be
COPY --from=build-fe /quickshare /quickshare
WORKDIR /quickshare
RUN /quickshare/scripts/build_exec.sh

FROM debian:stable-slim
RUN groupadd -g 8686 quickshare
RUN useradd quickshare -u 8686 -g 8686 -m -s /bin/bash
RUN usermod -a -G quickshare root
COPY --from=build-be /quickshare/dist/quickshare /quickshare
ADD configs/demo.yml /quickshare
RUN mkdir -p /quickshare/root
RUN chgrp -R quickshare /quickshare
RUN chmod -R 0770 /quickshare
CMD ["/quickshare/start", "-c", "/quickshare/demo.yml"]
```
- Build stages: node:lts (frontend, `yarn run build:fe`), golang:1.24 (`scripts/build_exec.sh`), final debian:stable-slim.
- No ARG, ENV, EXPOSE, VOLUME, USER, HEALTHCHECK or ENTRYPOINT in this Dockerfile.
- Note: the paths are inconsistent. `COPY ... /quickshare/dist/quickshare /quickshare` writes the binary to the path `/quickshare`, but then `ADD configs/demo.yml /quickshare`, `RUN mkdir -p /quickshare/root`, and CMD `/quickshare/start -c /quickshare/demo.yml` all treat `/quickshare` as a directory. `/quickshare/start` does not exist as written. Upstream quirk, unverified at runtime.

## Runtime deps
- Release zip binary is a dynamic glibc build (plan.md: needs GLIBC_2.34 or lower). Frontend is embedded in the binary (plan.md, not re-verified).

## Binaries/entrypoint/CLI flags
- Binary: `quickshare`. Config: `-c <file>` (YAML). Demo config in image: `configs/demo.yml`.

## Env vars (from README and Docker Hub example)
| Name | Example | Purpose |
| --- | --- | --- |
| DEFAULTADMIN | qs (README), admin (TrueCharts) | initial admin username |
| DEFAULTADMINPWD | 1234 | initial admin password |

Per plan.md (from source, not re-verified here): `TOKENSECRET`, `PORT` also read by the app.

## Ports
- 8686 (Docker Hub example `-p :8686:8686`, README and Dockerfile group/user 8686). Plan.md confirms `server.port: 8686`. The draft's 3000 is wrong.

## Volumes/paths and persistent data
- `/quickshare/root` (file storage root). Docker Hub example mounts host `./quickshare/root` there.
- Per plan.md: database path is relative to fs.root (`db.dbPath`, sqlite).

## Config files and formats
- YAML via `-c`. Keys mentioned upstream: `fs.root`, `fs.publicPath`, `db.dbPath`, `server.host`, `server.port`, `users.*`. Other docs at `./docs/CONFIG_en-us.md` (not fetched).

## User/UID & permissions
- Dockerfile: group and user `quickshare` uid/gid 8686; root user added to group quickshare; `/quickshare` chmod 0770 and chgrp quickshare. Runs with CMD as root (no USER line).

## Healthcheck/readiness
- None documented.

## Version/release info and asset naming
- Latest release v0.11.4 (tag v0.11.4, released 30 Jan, marked Latest, commit 284d5d8). Release page reports 9 assets; names did not render.
- Asset naming (README examples, older release): `quickshare_0.0.8_linux_x86_64.zip`, `quickshare_0.0.8_macos_x86_64.zip`.
- Current naming per draft/plan: `quickshare_linux_amd64.zip`, `quickshare_linux_arm64.zip` at `https://github.com/ihexxa/quickshare/releases/download/v<VERSION>/...` (not downloaded here; plan.md has sha256 digests).
- Release notes: Spanish language support (PR #261), tar 7.5.6 to 7.5.7 (PR #262).

## Arch support
- README examples only show x86_64. Release naming in current release includes linux amd64 and arm64 per draft/plan.

## Gotchas
- README default login `qs`/`1234` in examples; change after first login (FAQ at `./docs/FAQ_en-us.md`).
- Launch prints `quickshare starts @ [URL]`.
