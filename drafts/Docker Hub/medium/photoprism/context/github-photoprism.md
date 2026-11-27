# GitHub: photoprism/photoprism

## Source URL(s) + date
- https://api.github.com/repos/photoprism/photoprism/releases/latest
- https://raw.githubusercontent.com/photoprism/photoprism/master/docker/photoprism/questing/Dockerfile
- Fetched 2026-11-27

## Latest release
- tag `261029-963b58c50`, name "October 29, 2026", published 2026-10-29T22:20:43Z.
- Assets:
  - `photoprism_261029-963b58c50-linux-amd64.tar.gz`
  - `photoprism_261029-963b58c50-linux-arm64.tar.gz`
- Download pattern: `photoprism_${TAG}-linux-${ARCH}.tar.gz`.

## Upstream Dockerfile (docker/photoprism/questing/Dockerfile, master)
### Stages
- build: `FROM photoprism/develop:questing AS build`, `WORKDIR /go/src/github.com/photoprism/photoprism`, `COPY . .`, `make all install DESTDIR=/opt/photoprism`.
- production: `FROM photoprism/develop:questing-slim`, `WORKDIR /photoprism`, `COPY --from=build /opt/photoprism/ /opt/photoprism`.
- Production RUN: writes `/scripts/.env` (DOCKER_ENV=prod, DOCKER_IMG=ce, mode 0444), apt update + dist-upgrade, `yt-dlp -U`, runs `/scripts/cleanup.sh`.
- `/scripts/dist/` copied to `/scripts/` (root, 755).

### Env (production stage)
- DO_NOT_TRACK=true, ORT_DISABLE_TELEMETRY=1, TMPDIR=/tmp, TF_CPP_MIN_LOG_LEVEL=4, TF_ENABLE_ONEDNN_OPTS=1, MALLOC_ARENA_MAX=2, PROG=photoprism.
- Paths: ASSETS=/opt/photoprism/assets, IMPORT=/photoprism/import, ORIGINALS=/photoprism/originals, STORAGE=/photoprism/storage, BACKUP=/photoprism/storage/backups, LOG_FILENAME=/photoprism/storage/photoprism.log, PID_FILENAME=/photoprism/storage/photoprism.pid.
- Network: SITE_URL=http://localhost:2342/, HTTP_HOST=0.0.0.0, HTTP_PORT=2342.
- Database: DRIVER=sqlite, NAME=photoprism, USER=photoprism, SERVER empty.
- Flags: DEBUG/PUBLIC/READONLY/EXPERIMENTAL/DETECT_NSFW=false, UPLOAD_NSFW=true, AUTO_INDEX=300, AUTO_IMPORT=-1, INIT=https, RAW_PRESETS=false, THUMB_UNCACHED=false; DISABLE_{CHOWN,WEBDAV,SETTINGS,BACKUPS,EXIFTOOL,PLACES,TENSORFLOW,FACES}=false.
- ARG: TARGETARCH, TARGETPLATFORM, BUILD_TAG.

### Ports / volumes / user
- `EXPOSE 2342 2443`.
- No VOLUME, USER, ENTRYPOINT or CMD.

## Gotchas
- Variable prefix: fetched Dockerfile summary mixes `PHOTOPRISM_` and bare names; treat `PHOTOPRISM_*` as the documented form (see photoprism-docs.md).
- Upstream runtime tools (ffmpeg, exiftool, libvips) come from the `questing-slim` base, not the release tarball.
- Tags are `YYMMDD-sha` (not semver).
