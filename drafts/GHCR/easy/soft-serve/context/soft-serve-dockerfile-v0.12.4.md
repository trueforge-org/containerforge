# soft-serve upstream Dockerfile (v0.12.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/charmbracelet/soft-serve/v0.12.4/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Build/base
- `FROM alpine:latest` (no ARG, no build stage)
- RUN `apk update && apk add --update git bash openssh && rm -rf /var/cache/apk/*`
- COPY `soft` → `/usr/local/bin/soft`

## Runtime
- ENV `SOFT_SERVE_DATA_PATH=/soft-serve`, `SOFT_SERVE_INITIAL_ADMIN_KEYS=""`, `CI=1`
- WORKDIR `/soft-serve`; VOLUME `/soft-serve`
- EXPOSE 23231/tcp (SSH), 23232/tcp (HTTP), 23233/tcp (stats), 9418/tcp (git)
- ENTRYPOINT `["/usr/local/bin/soft", "serve"]`; no CMD
- No USER, no user/group creation (runs as root), no HEALTHCHECK.
