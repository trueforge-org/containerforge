# Gotenberg Dockerfile (build/Dockerfile @ da5d11a1bc50a46afe29e23fed471fa6ed3cf05e)

Source URL: https://github.com/gotenberg/gotenberg/blob/da5d11a1bc50a46afe29e23fed471fa6ed3cf05e/build/Dockerfile (fetched via raw.githubusercontent.com)

## Build args
| Arg | Default |
| --- | --- |
| GOLANG_VERSION | 1.27.4 |
| LOK_VERSION | v0.0.7 |
| GOTENBERG_VERSION | snapshot |
| TIMEZONE | UTC |
| GOTENBERG_USER_GID | 1001 |
| GOTENBERG_USER_UID | 1001 |
| APT_SNAPSHOT | "" (cache buster) |

## Stages
- lok-binary-stage: debian:13-slim; install.sh from lok GitHub releases into /home
- gotenberg-binary-stage: golang:$GOLANG_VERSION; CGO_ENABLED=0; builds gotenberg, gotenberg-chromium, gotenberg-libreoffice
- base-image-stage: debian:13-slim; common-stage builds on it
- Targets: gotenberg (full), gotenberg-chromium, gotenberg-libreoffice; cloudrun and aws-lambda variants of each

## Common stage
- User/group gotenberg 1001:1001, bash shell, home /home/gotenberg; also member of root group; home g=u (OpenShift arbitrary UID)
- apt: upgrade; ca-certificates, tini, curl, fonts (carlito, caladea, liberation, liberation2, dejavu, noto-cjk, noto-color-emoji, noto-core, urw-base35)
- COPY build/fonts.conf -> /etc/fonts/conf.d/100-gotenberg.conf; build/capture-version.sh -> /opt/gotenberg/capture-version.sh
- ENV: TZ=$TIMEZONE, LANG=C.UTF-8, LC_ALL=C.UTF-8, GOTENBERG_VERSIONS_DIR_PATH=/opt/gotenberg/versions, OTEL_TRACES/METRICS/LOGS_EXPORTER=none

## Variant differences
| | full | chromium | libreoffice |
| --- | --- | --- | --- |
| Chromium (apt) | yes | yes | no |
| LibreOffice | yes | no | yes |
| lok -> /usr/bin/lok | yes | no | yes |
- LibreOffice: trixie-backports; ~50 hyphen-* dicts; libreoffice writer/calc/impress/draw/math
- Chromium: build/chromium-hyphen-data -> /opt/gotenberg/chromium-hyphen-data; build/chromium-policies -> /etc/chromium/policies/managed
- Chromium ENV: CHROMIUM_BIN_PATH=/usr/bin/chromium, CHROMIUM_HYPHEN_DATA_DIR_PATH=/opt/gotenberg/chromium-hyphen-data
- LibreOffice ENV: LIBREOFFICE_BIN_PATH=/usr/lib/libreoffice/program/soffice.bin, LOK_BIN_PATH=/usr/bin/lok

## Runtime (all final targets)
- USER gotenberg; WORKDIR /home/gotenberg; EXPOSE 3000
- ENTRYPOINT ["/usr/bin/tini","--"]; CMD ["gotenberg"]

## Cloud Run variants
- ENV: API_PORT_FROM_ENV=PORT, WEBHOOK_ENABLE_SYNC_MODE=true, GOTENBERG_BUILD_DEBUG_DATA=false, LOG_STD_ENABLE_GCP_FIELDS=true
- CHROMIUM_AUTO_START=true / LIBREOFFICE_AUTO_START=true per variant

## AWS Lambda variants
- Copies /lambda-adapter from public.ecr.aws/awsguru/aws-lambda-adapter:1.1.0 to /opt/extensions/lambda-adapter
- ENV: AWS_LWA_PORT=3000, AWS_LWA_READINESS_CHECK_PATH=/health, AWS_LWA_INVOKE_MODE=buffered, API_PORT_FROM_ENV=AWS_LWA_PORT

## Not present
- No HEALTHCHECK, no VOLUME.

## Gotchas
- Gotenberg is a separate service; paperless talks to it over HTTP (port 3000).
