# Upstream web frontend Dockerfile (TomBursch/kitchenowl @ v0.8.1, kitchenowl/Dockerfile)

## Source URL(s) + date
- https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/kitchenowl/Dockerfile (2026-11-26)
- Not fetched (same content): https://github.com/TomBursch/kitchenowl/blob/v0.8.1/kitchenowl/Dockerfile

## Builder (`FROM --platform=$BUILDPLATFORM debian:latest AS builder`)
- apt: git wget curl zip unzip apt-transport-https ca-certificates gnupg python3 libstdc++6 libglu1-mesa.
- `git clone https://github.com/flutter/flutter.git -b stable /usr/local/src/flutter`; `flutter config --enable-web`, `--no-analytics`, `flutter upgrade`, `flutter doctor -v`.
- COPY `.metadata l10n.yaml pubspec.yaml pubspec.lock lib web assets fonts` -> `/usr/local/src/app`.
- `flutter packages get`; `flutter build web --release --no-web-resources-cdn`.

## Runner (`FROM nginx/nginx-unprivileged:stable-alpine`)
- `USER root`; `apk add --no-cache bash`; dirs `/var/www/web/kitchenowl`, `/etc/nginx/templates`; chown nginx.
- COPY build/web -> `/var/www/web/kitchenowl`.
- COPY `docker-entrypoint-custom.sh` -> `/docker-entrypoint.d/01-kitchenowl-customization.sh`.
- COPY `default.conf.template` -> `/etc/nginx/templates/`.
- `USER nginx`.
- `HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/ || exit 1`.
- `ENV BACK_URL='back:5000'`.
- `EXPOSE 80`.

## Env vars
| Name | Default |
| --- | --- |
| BACK_URL | `back:5000` |

## Ports
- 80.

## User/UID
- `nginx` (nginx-unprivileged image user).

## Gotchas
- Flutter stable cloned at build time (no pinned Flutter version in Dockerfile).
- Prebuilt release bundle `kitchenowl_Web.tar.gz` exists on GitHub release v0.8.1 (see plan.md); not used by this Dockerfile.
