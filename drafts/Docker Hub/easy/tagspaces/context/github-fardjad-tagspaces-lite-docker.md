# fardjad/tagspaces-lite-docker (draft's image source; Dockerfile at 495b180)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/fardjad/tagspaces-lite-docker/495b1805d716d826fdd70ddc558df4a700b364be/Dockerfile (fetched 2026-11-26)
- https://github.com/fardjad/tagspaces-lite-docker (linked from Docker Hub; README not fetched)

## What it is
Docker packaging of the TagSpaces Lite web build. Automatically built images (Docker Hub text).

## Install/build steps
Dockerfile (495b180):
- Stage 1: `FROM debian:latest AS builder`; `apt-get install -y unzip`; `COPY tagspaces-web.zip .`; `RUN unzip tagspaces-web.zip`.
- Stage 2: `FROM nginxinc/nginx-unprivileged:stable`; `USER root`; `RUN rm -rf /usr/share/nginx/html`; `COPY --from=builder web /usr/share/nginx/html`; `USER nginx`; `EXPOSE 8080`.
- No CMD, ENTRYPOINT, VOLUME or ENV.
- Note: the zip is named `tagspaces-web.zip` (a local file); the upstream release asset name is `tagspaces-web-<version>.zip`, so the source of the zip is not in this file.

## Runtime deps
nginx (unprivileged image). Static files only.

## Ports
8080 (EXPOSE).

## Volumes/paths
Web root `/usr/share/nginx/html`.

## User/UID & permissions
Runs as `nginx` (unprivileged base).

## Version/release info
No version in the file. The draft's tag 6.0.2 is a Docker Hub tag (chart).

## Gotchas
- Archived status (plan.md says "archived by its author") is not stated on the fetched pages. Unverified.

## Contradictions with plan.md
- Consistent with plan.md section 1 (unzip, `web/` copied to the nginx web root, `EXPOSE 8080`).
