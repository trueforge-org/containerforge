# TrueCharts chart: shoko-server

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shoko-server/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shoko-server/values.yaml (fetched 2026-11-27)

## What it is
- Chart v16.0.0, appVersion 5.3.3. Category media (keywords Tools-Utilities).
- "Anime cataloging program designed to automate the cataloging of your collection."
- Sources: ghcr.io/shokoanime/server, github ShokoAnime/ShokoServer.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- `ghcr.io/shokoanime/server`, tag `v5.3.3@sha256:b841f8249c9edfba102e4072e2b2a3eae4179e5dd553f29e11b9898a44f1e836`, pullPolicy IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8111 | 8111 | http |

## Persistence
| name | mountPath |
| --- | --- |
| appdata | /home/shoko/.shoko/ |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Env set by chart
- none in values.yaml (no workload env block).

## Upstream Dockerfile (ShokoServer v5.3.3)
Source URL: https://raw.githubusercontent.com/ShokoAnime/ShokoServer/v5.3.3/Dockerfile (fetched 2026-11-27)
- Build stage `mcr.microsoft.com/dotnet/sdk:8.0`: `dotnet build -c=Release -r linux-x64 -f net8.0 -o=/usr/src/app/build/ Shoko.CLI/Shoko.CLI.csproj` with version/channel/commit/tag/date build args.
- Runtime `mcr.microsoft.com/dotnet/aspnet:8.0`.
- ENV PUID=1000, PGID=100, LANG/LC_CTYPE/LC_ALL=C.UTF-8.
- apt: gnupg curl; mediaarea.net debian repo key (converted to /usr/share/keyrings/mediainfo.gpg) and source line for suite `bookworm`; then apt: apt-utils gosu jq unzip mediainfo librhash-dev.
- Copies build output to /usr/src/app/build; COPY dockerentry.sh -> /dockerentry.sh.
- Web UI: downloads Shoko-WebUI release zip into /usr/src/app/build/webui. If build channel is `stable` uses `releases/latest` asset[0]; otherwise `releases` list[0] asset[0]. Unzips and removes zip.
- VOLUME /home/shoko/.shoko/
- HEALTHCHECK --start-period=5m: `curl http://localhost:8111/api/v3/Init/Status`
- EXPOSE 8111
- ENTRYPOINT `["/bin/bash", "/dockerentry.sh"]`

## Entrypoint (upstream dockerentry.sh, v5.3.3)
- Env: PUID (default 1000), PGID (default 100), UMASK (optional), SHOKO_HOME (default /home/shoko/.shoko/Shoko.CLI).
- PUID 0 -> user root; PGID 0 -> group root; PGID 100 -> group users. Otherwise group `shokogroup` and user `shoko` are created/updated (useradd -N -o).
- If PUID=0 and SHOKO_HOME is default: exits with error (custom SHOKO_HOME required).
- Creates SHOKO_HOME if default path; exits if a custom SHOKO_HOME is missing.
- chown -R PUID:PGID /home/shoko/ when SHOKO_HOME owner differs; chown -R on /usr/src/app/build/.
- Exits with error if /root/.shoko exists (old install detected).
- Sets umask from UMASK if set.
- Final: `exec gosu $USER:$GROUP /usr/src/app/build/Shoko.CLI`

## Runtime deps
- .NET 8 aspnet runtime, mediainfo, librhash, gosu, jq, unzip, curl.

## Volumes/paths
- /home/shoko/.shoko/ (chart appdata); default SHOKO_HOME /home/shoko/.shoko/Shoko.CLI; app binaries /usr/src/app/build.

## User/UID
- Default shoko user with PUID=1000 / PGID=100 (users group). Chart runs container as root, but entrypoint drops to shoko unless PUID=0.

## Version/asset naming
- Git tags `vX.Y.Z`; chart pins v5.3.3.
- Web UI assets from ShokoAnime/Shoko-WebUI GitHub releases (asset[0] zip).
- Latest release tag (GitHub redirect): v5.3.3. api releases/latest returned 403 (rate limit).

## License
- MIT (LICENSE raw v5.3.3).

## Gotchas
- Upstream image default PGID 100 (users group); if PUID=0 an explicit SHOKO_HOME is required.
- Dockerfile downloads the web UI at build time from GitHub (not pinned unless channel differs).
- dot.net/v1/dotnet-install.sh (plan URL) is not referenced by this Dockerfile (not fetched).
