# linuxserver/docker-endlessh Dockerfile (master)

## Source URL(s) + date
- https://raw.githubusercontent.com/linuxserver/docker-endlessh/master/Dockerfile (fetched 2026-11-27)
- Duplicate in urls.txt: github blob at commit a8ff0136bdf6498ea00988c71ca70afa4d49a10e (not fetched separately; plan cites it).

## Base / stages
- Single stage: `FROM ghcr.io/linuxserver/baseimage-alpine:3.18`. Syntax `docker/dockerfile:1`.
- ARG `BUILD_DATE`, `VERSION`, `ENDLESSH_RELEASE`. LABEL `build_version`, maintainer aptalca.

## Build
- apk `--virtual=build-dependencies` `build-base`; removed with `apk del --purge build-dependencies`. No apt.
- If `ENDLESSH_RELEASE` unset: latest master commit SHA (first 8 chars) from `https://api.github.com/repos/skeeto/endlessh/commits/master` via jq.
- Source: `https://github.com/skeeto/endlessh/archive/${ENDLESSH_RELEASE}.tar.gz` -> `/tmp/endlessh.tar.gz`, extracted to `/app/endlessh` (`--strip-components=1`).
- `cd /app/endlessh && make`. Cleanup: `$HOME/.cache`, `/tmp/*`.

## Runtime
- COPY `/root` -> `/`.
- EXPOSE 2222.
- No WORKDIR, ENV, USER, VOLUME, ENTRYPOINT, CMD, HEALTHCHECK.

## Gotchas
- Release built from tarball of a git ref, not a release asset. Tag pin is `ENDLESSH_RELEASE`.
