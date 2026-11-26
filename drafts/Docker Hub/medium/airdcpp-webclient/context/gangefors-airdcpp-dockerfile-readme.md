# gangefors/docker-airdcpp-webclient: Dockerfile and README

## Source URL(s) + date
- https://raw.githubusercontent.com/gangefors/docker-airdcpp-webclient/master/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/gangefors/docker-airdcpp-webclient/master/README.md (fetched 2026-11-26)

## What it is
- Third-party Docker image running AirDC++ Web Client (Linux daemon + web UI).

## Install/build steps (Dockerfile)
- `ARG distro=stable-slim`; `FROM debian:${distro}`
- `ARG dl_url="https://web-builds.airdcpp.net/stable/airdcpp_latest_master_64-bit_portable.tar.gz"`
- apt installDeps: curl, gnupg (purged after). runtimeDeps: ca-certificates, locales, openssl.
- Node.js via `curl -sL https://deb.nodesource.com/setup_24.x | bash -` then `apt-get install nodejs` (for extension support).
- Download: `curl --progress-bar ${dl_url} | tar -xz -C /` (unpinned, no checksum).
- `apt-get purge --autoremove` installDeps; `rm -rf /var/lib/apt/lists/*`
- Locale: `ENV LANG=en_US.UTF-8`, `LANGUAGE=en_US:en`, `LC_ALL=en_US.UTF-8`; locale.gen uncommented; `locale-gen`; `dpkg-reconfigure locales`.
- `mkdir -p /.airdcpp /Downloads /Share`; `chmod a+rwX` on those.
- `ln -sf /.airdcpp /airdcpp-webclient/config`
- favicon symlink: `/airdcpp-webclient/web-resources/favicon.ico` -> `images/favicon.*.ico`
- `COPY .airdcpp/ /.default-config`; `COPY entrypoint.sh /entrypoint.sh`
- `EXPOSE 5600 5601 21248 21249`; `ENTRYPOINT ["/entrypoint.sh"]` (no CMD)

## Entrypoint/flags
- `/entrypoint.sh` (not fetched). README: PUID/PGID handling, `--add-user` argument to the container (`docker run ... gangefors/airdcpp-webclient --add-user`).

## Env vars (README)
| Var | Default | Use |
| --- | --- | --- |
| PUID | (root container: must set) | run user id, must be >= 101 |
| PGID | (root container: must set) | run group id, must be >= 101 |
| UMASK | 0022 | file creation mask |
| DL_DIR | $HOME/Downloads (compose) | host path -> /Downloads |
| SHARE_DIR | $HOME/Share (compose) | host path -> /Share |
| HTTP_PORT | 80 (compose) | published HTTP |
| HTTPS_PORT | 443 (compose) | published HTTPS |
| TCP_PORT | 21248 (compose) | published TCP incoming |
| UDP_PORT | 21248 (compose) | published UDP incoming |
| TLS_PORT | 21249 (compose) | published TLS incoming |

- PUID/PGID only work on `latest` and versions later than 2.11.0 (README).

## Ports
| Port | Use |
| --- | --- |
| 5600 | HTTP web UI |
| 5601 | HTTPS web UI (self-signed by default) |
| 21248 | TCP + UDP incoming (must be published same number) |
| 21249 | TCP TLS incoming (must be published same number) |

- Ports changeable in web UI: Settings > Connectivity > Advanced > Ports.

## Volumes/paths
| Path | Use |
| --- | --- |
| `/.airdcpp` | settings (populated from defaults if empty) |
| `/Downloads` | default download folder (changeable in UI) |
| `/Share` | default share folder; bind mounts underneath auto-added to share |

## User/UID
- Image starts as root; the app runs as PUID/PGID (or `--user $(id -u):$(id -g)`). Podman: run as root, no PUID/PGID.
- Image contains system accounts/groups below 101 (hence PUID >= 101).

## Config files
- Config dir is `/.airdcpp`; symlinked to `/airdcpp-webclient/config`.
- Default admin: `admin` / `password` (README). Add admins: `docker run --rm -it --volumes-from <ctr> ... --add-user` (stop container first).

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Image tags: `latest`, version tags (2.11.x era and later). Upgrade = pull and recreate.

## Arch
- Not stated; download URL is `64-bit_portable` (amd64 only).

## Gotchas
- Download is unpinned (`airdcpp_latest_master_...`); no checksum.
- README compose: PUID default 1000, PGID default 1000, UMASK 0022.
- Container runs as root unless `--user` is used.
