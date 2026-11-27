# miniflux/v2 packaging/docker/alpine/Dockerfile (main)

## Source URL(s) + date
- https://raw.githubusercontent.com/miniflux/v2/main/packaging/docker/alpine/Dockerfile
- Fetched 2026-11-26. Plan's pinned blob `2.3.5/packaging/docker/alpine/Dockerfile` not fetched; main used.

## Build steps
- Build stage: `docker.io/library/golang:alpine3.23`; `apk add --no-cache build-base git make`; `ADD . /go/src/app`; `WORKDIR /go/src/app`; `RUN make miniflux`.
- Runtime stage: `docker.io/library/alpine:3.24`.
- Labels: title Miniflux, licenses Apache-2.0, source https://github.com/miniflux/v2, docs https://miniflux.app/docs/.
- `EXPOSE 8080`; `ENV LISTEN_ADDR=0.0.0.0:8080`.
- `apk --no-cache add ca-certificates tzdata`.
- `COPY --from=build /go/src/app/miniflux /usr/bin/miniflux`.
- `USER 65534` (nobody, non-root).
- `CMD ["/usr/bin/miniflux"]` (no ENTRYPOINT).

## Runtime deps
- alpine:3.24 with ca-certificates, tzdata.

## Entrypoint/flags
- CMD `/usr/bin/miniflux`. Healthcheck mode per docs: `/usr/bin/miniflux -healthcheck auto`.

## Ports
- 8080/tcp (EXPOSE; LISTEN_ADDR 0.0.0.0:8080).

## User/UID
- 65534.

## Gotchas
- Build uses `make miniflux` (Makefile target in repo); version is not passed as a build ARG in this file.
- Build stage (alpine3.23) and runtime stage (alpine:3.24) differ by design.
