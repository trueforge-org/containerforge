# zilean — implementation plan
> Source: ./draft.md · Target: apps/zilean/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `3.5.0` (GitHub release `v3.5.0`, 2025-04-21; Docker Hub `ipromknight/zilean` tags `3.5.0`, `v3.5.0`, `latest`, `sha-*`). Draft uses the chart's image without a tag. Last commit on `main`: 2025-05-26 (low activity). |
| Renovate | `datasource=github-releases depName=iPromKnight/zilean versioning=semver` (tags are `vX.Y.Z`, so the Dockerfile fetches `v${VERSION}`) |
| License | UNVERIFIED. The repository has no `LICENSE` file at the root (listing checked) and the GitHub API reports no license. Do not guess an SPDX id; ask the maintainer/upstream (open issue) before building. Placeholder: `LicenseRef-Unknown`. |
| Source | https://github.com/iPromKnight/zilean (docs https://ipromknight.github.io/zilean/) |
| Download | Source tarball `https://github.com/iPromKnight/zilean/archive/refs/tags/v${VERSION}.tar.gz`; built with .NET 9 (`net9.0` in `Directory.Build.props`). .NET SDK/runtime not in ContainerForge bases; Ubuntu archive has dotnet 9 only for `questing` (25.10) in the launchpad listing, so availability for 26.04 is UNVERIFIED. |
| Checksum | None published for the source tarball. |
| Upstream Dockerfile | Reviewed. Build: `mcr.microsoft.com/dotnet/sdk:9.0-alpine`, `dotnet restore -a $TARGETARCH`, `dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out` for `src/Zilean.ApiService` and `src/Zilean.Scraper`. Runtime: `mcr.microsoft.com/dotnet/aspnet:9.0-alpine` + alpine 3.18 `python3=~3.11 py3-pip curl icu-libs`; env `DOTNET_RUNNING_IN_CONTAINER=true`, `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false`, `PYTHONUNBUFFERED=1`, `ZILEAN_PYTHON_PYLIB=/usr/lib/libpython3.11.so.1.0`, `ASPNETCORE_URLS=http://+:8181`; `WORKDIR /app`, `VOLUME /app/data`, `pip3 install -r requirements.txt -t /app/python`, `ENTRYPOINT ["./zilean-api"]`. |
| requirements.txt | `loguru==0.7.2`, `rich==13.8.0`, `rank-torrent-name==1.5.3` |
| Port | `8181/tcp` (`ASPNETCORE_URLS=http://+:8181`) |
| Config | Config file `/app/data/settings.json` (code: `ConfigurationFolder="data"`, `settings.json`, `logging.json`, section `Zilean`), then env vars `Zilean__{Section}__{Key}` which take precedence. Keys documented: `Zilean__ApiKey` (generated on first run), `Zilean__FirstRun`, `Zilean__EnableDashboard` (false), `Zilean__Dmm__EnableScraping`/`EnableEndpoint`/`ScrapeSchedule`(`0 * * * *`)/`MinimumReDownloadIntervalMinutes`/`MaxFilteredResults`/`MinimumScoreMatch`, `Zilean__Torznab__EnableEndpoint`, `Zilean__Database__ConnectionString` (PostgreSQL, default `Host=localhost;Database=zilean;Username=postgres;Password=$POSTGRES_PASSWORD;Include Error Detail=true;Timeout=30;CommandTimeout=3600;`), `Zilean__Torrents__*`, `Zilean__Imdb__*`, `Zilean__Ingestion__*`, `Zilean__Parsing__BatchSize`. |
| Data | `/app/data` (settings.json with generated ApiKey, logs). Database is external PostgreSQL. |

## 2. Target layout

```
apps/zilean/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage (draft: .NET from the ubuntu base; Python ingestion via apt). Build stage uses a Microsoft SDK image, as other apps use external build stages for Go (`apps/*` Go builds): `FROM mcr.microsoft.com/dotnet/sdk:9.0@sha256:<resolve and pin the digest at implementation> AS build` (the Debian-based SDK image; digest not looked up yet, UNVERIFIED). The app is published self-contained so no .NET runtime is installed in the final image. Closest sibling: `apps/sonarr` (dotnet app on ubuntu, `libicu-dev` already in base) for the runtime side.

## 4. Dockerfile

1. Stage `build`: `ARG VERSION TARGETARCH`; `ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 NUGET_PACKAGES=/tmp/nuget HOME=/tmp`. Map the arch: `RID=linux-x64` for `amd64`, `linux-arm64` for `arm64`.
   ```
   curl -fsSL "https://github.com/iPromKnight/zilean/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /src --strip-components=1
   cd /src && dotnet restore -r "$RID"
   cd src/Zilean.ApiService && dotnet publish -c Release --no-restore -r "$RID" --self-contained true -o /out
   cd ../Zilean.Scraper && dotnet publish -c Release --no-restore -r "$RID" --self-contained true -o /out
   ```
   (Build with `--platform=$BUILDPLATFORM` and `-r` cross-targeting as upstream does, to avoid QEMU for arm64.) `requirements.txt` is copied from `/src`.
2. Final stage (ubuntu line), `ARG VERSION`, `USER root`:
   - `apt-get install -y --no-install-recommends python3 python3-pip libpython3-stdlib` plus the shared-library package for the installed Python (`libpython3.<minor>`, name found at implementation: `dpkg -L` must contain `libpython3.<minor>.so.1.0`). Do not reinstall `curl`, `libicu-dev`, `libssl3` (in base).
   - `pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt --target /app/python` (cache and tmp under `/tmp`).
   - `ENV ZILEAN_PYTHON_PYLIB=<resolved path>` (resolve it in the same RUN with `python3 -c "import sysconfig,os;print(os.path.join(sysconfig.get_config_var('LIBDIR'),sysconfig.get_config_var('LDLIBRARY')))"` and `test -f`; write it to `/etc/zilean.env` is unnecessary, use `ENV` literal after verifying).
   - `COPY --from=build /out /app` (the binary `zilean-api` and `zilean-scraper`).
   - Data dir: `rm -rf /app/data; ln -s /config /app/data` (the app expects `./data` relative to `/app`).
   - License notice: no upstream LICENSE; ship `/usr/share/licenses/zilean/NOTICE` with source URL and tag, and the third-party notices if present in the repo; update when the license is resolved.
   - `chown -R root:root /app && chmod -R a+rX /app`; cleanup `/var/lib/apt/lists/* /tmp/*`.
3. `ENV DOTNET_RUNNING_IN_CONTAINER=true DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false PYTHONUNBUFFERED=1 PYTHONPYCACHEPREFIX=/tmp/pycache DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet ASPNETCORE_URLS=http://+:8181 HOME=/tmp`.
4. `EXPOSE 8181`, `VOLUME /config`, `WORKDIR /app`, `CMD ["/start.sh"]`.
5. `USER apps`, then `COPY --chmod=0755 . /`. Image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `zilean`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=iPromKnight/zilean versioning=semver
  default = "3.5.0"
  ```
- `LICENSE` = unresolved, see section 1 (do not commit a guessed SPDX id), `SOURCE` = `https://github.com/iPromKnight/zilean/`
- Targets `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 + arm64), group `default`, per `apps/adguardhome-sync/docker-bake.hcl`. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/iPromKnight/zilean/"
ports:
  - port: 8181
    protocol: tcp
    required: true
env:
  - name: Zilean__Database__ConnectionString
    default: "Host=postgresql;Database=zilean;Username=zilean;Password=MYPOSTGRESPASSWORD;Include Error Detail=true;Timeout=30;CommandTimeout=3600;"
    required: true
  - name: Zilean__ApiKey
    default: ""
    required: false      # empty = generated on first run and kept in /config/settings.json
  - name: Zilean__EnableDashboard
    default: "false"
    required: false
  - name: Zilean__Dmm__EnableScraping
    default: "true"
    required: false
  - name: Zilean__Dmm__ScrapeSchedule
    default: "0 * * * *"
    required: false
  - name: Zilean__Imdb__EnableImportMatching
    default: "true"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql   # ✅ apps/postgresql exists
    required: true
```

The default connection string mirrors the documented format with the sibling placeholder style (`MYPOSTGRESPASSWORD`).

## 7. start.sh

- `set -euo pipefail`; `mkdir -p /config /tmp/pycache /tmp/dotnet`.
- Export defaults matching `settings.yaml` (`Zilean__Database__ConnectionString`, etc.) only when unset, so user env always wins. Environment names contain `__`, which bash `export` accepts.
- `Zilean__ApiKey`: if set, pass through the environment (env beats `settings.json`, per docs); if empty, leave unset so the app generates one in `/config/settings.json` on first run (`FirstRun`). Do not write secrets to files from the script or log them.
- Optionally wait for PostgreSQL: loop `bash -c '</dev/tcp/$host/$port'` for up to 60 s with a log line `waiting for database`, parsed from the connection string with `sed`/`awk` (`Host=`, optional `Port=`); continue anyway after the timeout so the app logs its own error. No migrations step by script: the app applies EF migrations itself (UNVERIFIED, docs topic `Database-Migrations.md`).
- Ingestion scheduling is inside `zilean-api` (`Ingestion__EnableScraping`, `Dmm__ScrapeSchedule`); no separate cron needed (UNVERIFIED; check `Scraper.md`).
- Final command: `cd /app && exec ./zilean-api` (listens on `0.0.0.0:8181` because `ASPNETCORE_URLS=http://+:8181`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql; full functional test not feasible in single-container suite
tcp:
- port: '8181'
filePaths:
- /app/zilean-api
- /app/python
- /usr/share/licenses/zilean/NOTICE
```

Use the narrowing only if all three exception criteria hold when measured in step 3 of the protocol: hard `dependencies` on postgresql (yes, in section 6), the app does not stay up without the DB (UNVERIFIED, likely because it migrates at startup), and a sidecar DB cannot be wired in `container-test.yaml` (the schema has `runners` with `env`, but no sidecar container primitive was found). If the app keeps running and retrying while the DB is missing, `tcp 8181` is a valid real probe; if it exits, drop the `tcp` entry, keep the file checks plus the comment above, and add an `http` check on `/healthchecks/ping` ONLY if that path exists (UNVERIFIED). `timeoutSeconds`: take the larger value from `apps/sonarr`/`apps/radarr` container tests and add margin for .NET JIT startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/app/data/settings.json`, `logging.json`, logs | `/app/data` symlink to `/config` |
| .NET single-file/bundle extraction, `~/.dotnet`, NuGet | `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet`, `HOME=/tmp` |
| Python bytecode, pythonnet temp | `PYTHONPYCACHEPREFIX=/tmp/pycache`, packages pre-installed at build into `/app/python` |
| Pip install at build (`/app/python`) | stays at build time; read-only at runtime |

Draft expectations (UID 568, read-only rootfs, writes only to `/app/data`) match the target, with `/app/data` provided as `/config`.

## 10. Risks, caveats and open questions

- BLOCKER candidate: no license file or SPDX id upstream; ask upstream before publishing.
- Project activity is low (last release 2025-04, last commit 2025-05) and Zilean's data source (DebridMediaManager hashlists) may have changed; check that scraping still works.
- Python interop: `rank-torrent-name==1.5.3` and pythonnet compatibility with the newest Ubuntu 26.04 Python is UNVERIFIED (upstream uses 3.11). If it fails, build against a pinned Python, for instance by basing the Python half on `ghcr.io/trueforge-org/python` (3.15.2, even newer) or installing 3.11 from another source.
- `.NET 9`: self-contained publish avoids the missing runtime, but the SDK digest for the build stage must be pinned and kept up to date (renovate for the Microsoft image is not covered by this plan).
- First run downloads a large index (draft); needs disk space on `/config` and plenty of time; DB must be able to run `CommandTimeout=3600` migrations.
- The connection string contains the DB password; it lives only in the environment (the app may persist it into `settings.json`, UNVERIFIED).
- `Include Error Detail=true` default leaks SQL details in logs; keep as upstream or document.

## 11. Build and test steps

```sh
cd apps/zilean
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create zilean-probe-config
docker run --rm -d --name zilean-probe --read-only --tmpfs /tmp \
  -v zilean-probe-config:/config zilean:3.5.0
docker logs -f zilean-probe
forgetool containers test --image zilean:3.5.0 --config ./apps/zilean/container-test.yaml
docker rm -f zilean-probe; docker volume rm zilean-probe-config
```

Without a database the log may show connection retries; per the protocol exception that counts as readiness only when the process stays alive with no fatal exit. For a real check, start `apps/postgresql` on a shared network, set `Zilean__Database__ConnectionString`, and confirm `curl http://zilean:8181/` from another container. Readiness signals: `Now listening on: http://[::]:8181` and `Application started` (ASP.NET Core standard lines).

## 12. PR checklist

- Branch `feat/add-zilean`, commit `feat(zilean): add new container`, PR title the same, target `main`. Hold until the license question is answered.
- PR template filled in; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: whole build, arm64, Python interop, PostgreSQL migrations, first-run ingestion, read-only rootfs, license status.
