# Upstream image: ich777/docker-redm-server (Dockerfile)

Source URL: https://raw.githubusercontent.com/ich777/docker-redm-server/master/Dockerfile (fetched 2026-11-27, branch master, not pinned)

## Build
- `FROM ich777/debian-baseimage`. Label source: https://github.com/ich777/docker-redm-server
- apt install `xz-utils unzip screen` (no-install-recommends); rm apt lists.
- gotty: `wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz`, extracted to /usr/bin/ (amd64 only, no checksum step).
- `mkdir /serverdata`, `mkdir /serverdata/serverfiles`; `useradd -d $SERVER_DIR -s /bin/bash redm`; chown; `ulimit -n 2048`.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.

## Entrypoint / flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`; no CMD. No USER instruction (runs as root). No EXPOSE. No VOLUME.
- start.sh contents NOT fetched.

## Env vars (image defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_CONFIG | "" |
| SRV_ADR | https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/ |
| MANUAL_UPDATES | "" |
| ENABLE_WEBCONSOLE | true |
| GOTTY_PARAMS | -w --title-format RedM |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| SERVER_KEY | template |
| START_VARS | "" |
| DATA_PERM | 770 |
| USER | redm |

## Ports
- None declared in Dockerfile.

## Volumes/paths
- /serverdata (DATA_DIR), /serverdata/serverfiles (SERVER_DIR).

## Gotchas
- Runtime artifact is fetched from SRV_ADR by upstream scripts (not inspected).
- gotty web console is part of the image; its port is not declared here.
