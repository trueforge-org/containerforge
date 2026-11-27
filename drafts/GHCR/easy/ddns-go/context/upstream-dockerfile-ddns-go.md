# Upstream Dockerfile: ddns-go

Source URL(s):
- https://raw.githubusercontent.com/jeessy2/ddns-go/9d83c48bfa8a4cac6c6f58a00dedb49e9f848623/Dockerfile (fetched 2026-11-27)

## What it is
- Upstream's own image build, pinned to commit 9d83c48. Binary is copied in, not compiled here.

## Build steps
```
FROM alpine
LABEL name=ddns-go
LABEL url=https://github.com/jeessy2/ddns-go
RUN apk add --no-cache curl grep
WORKDIR /app
COPY ddns-go /app/
COPY zoneinfo /usr/share/zoneinfo
ENV TZ=Asia/Shanghai
EXPOSE 9876
ENTRYPOINT ["/app/ddns-go"]
CMD ["-l", ":9876", "-f", "300"]
```

## Runtime deps
- Alpine base (musl). Packages: `curl`, `grep`.

## Entrypoint/flags
- ENTRYPOINT `/app/ddns-go`, CMD `-l :9876 -f 300` (listen address, update interval in seconds).
- Upstream README flags: `-s install|uninstall` (service), `-noweb` (no web UI), `-c <config path>`, `-f <seconds>`, `-cacheTimes`, `-resetPassword <pw>`.

## Env vars
| Name | Value | Note |
| --- | --- | --- |
| TZ | Asia/Shanghai | upstream default, override per container |

## Ports
- 9876/tcp (EXPOSE).

## Volumes/paths
- Working dir `/app`. Zoneinfo copied to `/usr/share/zoneinfo`.
- Config: upstream README mounts host dir at `/root` (hidden config file in home).

## User/UID
- No USER line: runs as root.

## Version/asset naming
- Binary is released as `ddns-go_<ver>_linux_<arch>.tar.gz` (see GitHub release file).

## Gotchas
- Alpine (musl) image; Dockerfile itself is not glibc-based.
- `TZ` default is Asia/Shanghai.
