# ich777/docker-lunamultiplayer-ksp Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-lunamultiplayer-ksp/master/Dockerfile · fetched 2026-11-27

## Build
- Base: `ich777/debian-baseimage:bullseye_amd64`
- apt: wget, apt-transport-https; packages.microsoft.com debian 11 repo deb; installs `aspnetcore-runtime-6.0`, `jq`, `unzip`; removes apt-transport-https; autoremove; clears apt lists
- Copies `/scripts/` to `/opt/scripts/`, chmod 770

## Env vars (ENV)
| Var | Default |
| --- | --- |
| DATA_DIR | /lunamultiplayer |
| LMP_V | latest |
| GAME_PARAMS | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | lmp |

## User
- `useradd -d /lunamultiplayer -s /bin/bash lmp`; chown -R lmp on DATA_DIR
- ulimit -n 2048 (run in build step, has no effect on runtime)

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## Gotchas
- Base is Debian bullseye (11) with the .NET 6 ASP.NET runtime.
- Dockerfile does not EXPOSE a port (chart uses UDP 8800).
- start.sh contents not fetched; LMP version handling lives there.
