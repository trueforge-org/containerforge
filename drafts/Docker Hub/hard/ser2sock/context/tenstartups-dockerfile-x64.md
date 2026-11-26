# tenstartups/ser2sock Dockerfile.x64

Source URL(s): https://github.com/tenstartups/ser2sock/blob/9553300/Dockerfile.x64 (raw: raw.githubusercontent.com/tenstartups/ser2sock/9553300/Dockerfile.x64), fetched 2026-11-26.

## What it is
- Serial-to-TCP server image (ser2sock), built from source inside the Dockerfile.

## Base / build
- `FROM alpine:latest` (unpinned)
- apk: `build-base git libressl-dev` (installed then `rm -rf /var/cache/apk/*`; build tools NOT removed afterwards)
- Build: `git clone https://github.com/nutechsoftware/ser2sock.git` (HEAD, unpinned) in /tmp, `./configure && make`, `cp ser2sock /usr/local/bin/`, `cp -R etc/ser2sock /etc/`, then removes /tmp/ser2sock
- Note: no `autoreconf` step in Dockerfile (upstream README lists `autoreconf -f -i` before configure; clone may ship configure already, unverified).

## ENV
| Name | Default |
| --- | --- |
| PAGER | more |
| LISTENER_PORT | 10000 |
| BAUD_RATE | 9600 |
| TERM | xterm-color |

## Entrypoint / ports
- `COPY entrypoint.sh /docker-entrypoint`; `ENTRYPOINT ["/docker-entrypoint"]`
- `EXPOSE ${LISTENER_PORT}`

## Other
- LABEL maintainer = individual name/email (not copied here).
- Runs as root (no USER line).
