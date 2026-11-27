# thde rtorrent_exporter Dockerfile (commit e79ce427)

## Source URL(s) + date
- https://raw.githubusercontent.com/thde/rtorrent_exporter/e79ce427fd812cb1e9d1b0e3be0a9180f8e69cca/Dockerfile (fetched 2026-11-27)
- Blob URL in list is the same file (not fetched separately)

## Build
- Builder: `cgr.dev/chainguard/go:latest`; WORKDIR /usr/local/src/rtorrent_exporter; `go mod download -x`; `CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -trimpath -o /usr/local/bin/rtorrent_exporter`
- Final: `cgr.dev/chainguard/static:latest`; copies binary

## Runtime
- `EXPOSE 9135`
- `ENTRYPOINT [ "/usr/local/bin/rtorrent_exporter" ]`, `CMD [ "" ]`
- No USER, no HEALTHCHECK in Dockerfile

## Gotchas
- Built for linux/amd64 only (GOARCH hard-coded).
