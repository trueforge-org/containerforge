# ich777/docker-vintage-story (Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-vintage-story/master/Dockerfile (github blob variant same) (fetched 2026-11-27)

## What it is
- Upstream source for `ghcr.io/ich777/vintagestory`. Server is fetched by `/opt/scripts/start.sh` at runtime (scripts not fetched).

## Build
- `FROM ich777/mono-baseimage` (base image ref, not fetched).
- RUN: `wget` Microsoft package repo `https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb`, `dpkg -i`, then apt install `--no-install-recommends curl screen jq dotnet-runtime-10.0`; removes apt lists and the deb.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.

## Runtime deps
- dotnet-runtime 10.0 (Microsoft Debian 13 repo), curl, screen, jq.

## Entrypoint/flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.

## Env vars
| Var | Default |
| --- | --- |
| DATA_DIR | /vintagestory |
| VS_CHANNEL | stable |
| STATIC_V | "" |
| GAME_PARAMS | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | vintagestory |

## Volumes/paths
- `/vintagestory` (DATA_DIR), created and chowned to `vintagestory`.

## User/UID
- `useradd -d /vintagestory -s /bin/bash vintagestory`; UID/GID env default 99/100.

## Ports
- None exposed in Dockerfile (game port 42420 per server config).

## Gotchas
- Dockerfile uses Microsoft Debian 13 repo for dotnet, not Ubuntu packages (plan links packages.ubuntu.com resolute dotnet-runtime-10.0).
- `ulimit -n 2048` in a RUN step only.
- Upstream `ENV VS_CHANNEL="stable"` (channel name, not digest).
