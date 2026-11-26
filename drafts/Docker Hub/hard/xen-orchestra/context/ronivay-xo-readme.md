# ronivay/xen-orchestra-docker README

## Source URL(s) + date
- https://raw.githubusercontent.com/ronivay/xen-orchestra-docker/master/README.md (fetched 2026-11-26)

## What it is
- Builds Xen-Orchestra community edition container with all features and plugins.
- "Latest" tag = weekly build from XO `master`. Images also tagged by xo-server version.

## Install/build
- `docker build -t xen-orchestra .` or `docker pull ronivay/xen-orchestra`.
- Test: `docker run -itd -p 80:80 ronivay/xen-orchestra`. Default login `admin@admin.net` / `admin`.

## Run flags (README)
- Recommended: `--stop-timeout 60 --restart unless-stopped --cap-add sys_admin --cap-add dac_read_search --security-opt apparmor:unconfined -p 80:80 -v /path/xo-server:/var/lib/xo-server -v /path/redis:/var/lib/redis`.
- NFS/SMB remotes need `sys_admin` + `dac_read_search` (or `--privileged`); AppArmor needs `apparmor:unconfined`.
- Compose example volumes: `xo-data:/var/lib/xo-server`, `redis-data:/var/lib/redis`, `vddk-lib:/usr/local/lib/vddk`.
- Compose logging: json-file max-size 1M, max-file 2.
- File restore: `/dev/fuse`, `/dev/loop-control`, `/dev/loopN` devices (commented in example).

## Env vars (README "Variables")
| Var | Meaning |
| --- | --- |
| HTTP_PORT | HTTP listen port in container |
| HTTPS_PORT | HTTPS port; if set and no cert paths, self-signed cert generated |
| REDIRECT_TO_HTTPS | true/false; needs HTTPS_PORT; default false |
| CERT_PATH | PEM path inside container; value needs single quotes |
| KEY_PATH | key path inside container; value needs single quotes |

## Config
- Config generated once when config missing. Custom: mount dir to `/etc/xo-server`; edit `config.toml` there. Restart applies.
- Custom CA: mount to `/host-ca.pem`.

## Gotchas
- `--stop-timeout` recommended (default 10s too short).
- Latest tag is a weekly build (not pinned).
