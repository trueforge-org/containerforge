# Upstream README (Docker section): ddns-go

Source URL(s):
- https://raw.githubusercontent.com/jeessy2/ddns-go/master/README.md (fetched 2026-11-27, grep of Docker and CLI lines only; README is in Chinese)

## Docker usage (upstream)
- Run with host network (recommended on Linux x86/arm):
  `docker run -d --name ddns-go --restart=always --net=host -v /opt/ddns-go:/root ghcr.io/jeessy2/ddns-go`
- Port-mapped alternative: `-p 9876:9876 -v /opt/ddns-go:/root`.
- Web UI at `http://<host>:9876` for initial setup.
- Reset password: `docker exec ddns-go ./ddns-go -resetPassword <pw>`, then restart.
- Custom flags example: `-l :9877 -f 600`.
- Upstream also publishes `jeessy/ddns-go` on Docker Hub (badge link).
- Synology/Windows/Mac: bridged Docker, use the same network as host or port 9876.

## CLI flags (from README)
- `-s install` / `-s uninstall`: service mode.
- `-noweb`: do not start web service.
- `-c <path>`: config file path.
- `-f <sec>`: update interval. `-cacheTimes <n>`.
- `-resetPassword <pw>`.

## Gotchas
- Config is a hidden file under the mounted `/root` directory.
- `--net=host` recommended; bridge mode needs port 9876.
