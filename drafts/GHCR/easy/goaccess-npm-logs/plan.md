# goaccess-npm-logs — implementation plan
> Source: ./draft.md · Target: apps/goaccess-npm-logs/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | The draft has no version. The Ubuntu apt package to pin is `goaccess` `1:1.9.4-1` in suite `resolute` (Ubuntu 26.04, the base's release). Source: https://packages.ubuntu.com/resolute/goaccess. Upstream GoAccess is newer (tags `v1.12`, `v1.11`, `v1.10.2`, `v1.10.1`; no GitHub release object, so `releases/latest` returns 404). The wrapper builds GoAccess `1.10.2` from source. So the apt build is older than both. |
| The draft's `latest` tag | `ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager:latest` is a rolling third-party tag. Its version is UNVERIFIED (no tag/digest page fetched). The plan does not use this image (see section 3). |
| Renovate | UNVERIFIED. `apps/steamcmd/docker-bake.hcl` uses `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`, which could be tried here (epoch handling UNVERIFIED). Otherwise use the same approach as `apps/valkey`: keep the version in `VERSION` with a `// NOTE` and a commented-out datasource line, and say so in the PR. |
| License | Upstream GoAccess: MIT (GitHub API `license.spdx_id`: `MIT`, https://api.github.com/repos/allinurl/goaccess). Wrapper: MIT (https://api.github.com/repos/xavier-hernandez/goaccess-for-nginxproxymanager). |
| Source URL | https://goaccess.io (project); https://github.com/allinurl/goaccess (source) |
| Download | None needed: `apt-get install goaccess=<PACKAGE_VERSION>` from the ubuntu archive. No release file. |
| Checksum source | The apt repository's signed metadata (Ubuntu archive signing). Not checked on a fetched page; UNVERIFIED for this plan. |
| Arm64 availability | UNVERIFIED: the package page was read for the `resolute` suite without an architecture filter; per-arch availability was not checked. Confirm with a build of `image-all` (arm64) before claiming arm64 support. |
| Upstream wrapper Dockerfile reviewed | https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/Dockerfile. Two stages on `alpine:latest` (musl). Builder compiles GoAccess 1.10.2 from a bundled tarball with `--enable-utf8 --enable-geoip=mmdb`. Final stage installs `bash nginx tini wget curl apache2-utils libmaxminddb tzdata gettext musl-locales ncurses`. Bundles three MaxMind GeoLite2 `.mmdb` files. Runs as root (no `USER`). `VOLUME ["/opt/log"]`, `EXPOSE 7880`, `ENTRYPOINT ["tini", "--", "/goan/start.sh"]`. |
| Wrapper start script | https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/resources/scripts/start.sh. Starts nginx (`tini -s -- nginx`) for basic auth and static pages, then runs the log scripts in `logs/`, and ends with `wait -n`. |
| NPM log format used by the wrapper | `log_format [%d:%t %^] %^ %^ %s - %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"` (wrapper `resources/scripts/logs/npm.sh`, line 37). Written into its generated config. |
| Port | 7880 per the wrapper's `EXPOSE` and README. **Conflict:** the wrapper's `npm.sh` writes `port 7890` into the generated GoAccess config (line 38). Which port is served in practice is UNVERIFIED; check at step 3. |
| Log files | The wrapper README names NPM logs `proxy-host-<N>_access.log` (plus `*.gz` archives) under the mount point `/opt/log`. README example mounts `/path/to/host/nginx/logs:/opt/log:ro`. |
| Env vars (wrapper README) | `SKIP_ARCHIVED_LOGS`, `DEBUG`, `BASIC_AUTH`, `BASIC_AUTH_USERNAME`, `BASIC_AUTH_PASSWORD`, `EXCLUDE_IPS`, `INCLUDE_PROXY_HOSTS`, `LOG_TYPE` (default `NPM`), `LOG_TYPE_FILE_PATTERN`, `LANG`, `LANGUAGE`, `ENABLE_BROWSERS_LIST`, `CUSTOM_BROWSERS`, `HTML_REFRESH`, `KEEP_LAST`, `PERSIST`. Source: https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/README.md |
| Data/config write paths (wrapper) | `/goaccess-config` (config, browsers list, GeoIP), `/goaccess-logs` (archives, debug and invalid files), `/var/www/html` (nginx pages), `/opt/auth/.htpasswd`. |

Differences from the draft:
- The draft says "apt: goaccess" and "no services or root needed". Confirmed as a plan: the apt package is the base of this plan, not the wrapper image.
- The draft's "Reads logs from a shared volume" is confirmed by the wrapper README (`/opt/log`, read-only mount).
- The draft's `latest` image tag is not pinnable; the plan builds from apt instead.

## 2. Target layout

Files under `apps/goaccess-npm-logs/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: builds the GoAccess command, runs it, `exec`s it)

Not needed: `defaults/`, `etc/`, `health/`, `app/`, `root/` (never use `root/`). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: the apt package is in the Ubuntu archive, so it installs on the ubuntu base. The wrapper's alpine/nginx/root stack is not reused: it adds nginx basic auth and a web server that ContainerForge can handle at the ingress instead, and its GeoLite2 databases are not redistributed by this plan (see section 10).
- Closest sibling: none for GoAccess. For a single-package ubuntu app with a `start.sh` that reads a mounted directory, use `apps/adguardhome-sync` for layout, and `apps/valkey` for the pinned apt pattern (`apt-get install "pkg=${PACKAGE_VERSION}"` plus a `test` that checks `VERSION`).

## 4. Dockerfile

Step list:

1. `FROM` the ubuntu base digest above. `ARG VERSION`, `ARG PACKAGE_VERSION`. `USER root` for the install step.
2. Check and install the pinned package, following `apps/valkey`. The epoch (`1:`) must be stripped before the version check:
   ```dockerfile
   # hadolint ignore=DL3008,DL3015
   RUN v="${PACKAGE_VERSION#*:}"; \
       test "${v%%-*}" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends "goaccess=${PACKAGE_VERSION}" && \
       apt-get purge -y --auto-remove && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   `PACKAGE_VERSION=1:1.9.4-1`, `VERSION=1.9.4`. Check which other packages `goaccess` pulls in (its dependencies, such as the GeoIP library, are not known from the fetched page) and add them only if the binary needs them.
3. Environment (keep all writes off `/app`):
   ```dockerfile
   ENV HOME=/config \
       GOACCESS_LOG_DIR=/opt/log
   ```
   `GOACCESS_LOG_DIR` is read by `start.sh` (section 7). It is not a GoAccess or wrapper variable, so list it in `settings.yaml` only if it is meant to be user-set. The report directory `/config/reports` is hard-coded in `start.sh`.
4. `COPY --chmod=0755 start.sh /start.sh` (as `apps/valkey` does), then `USER apps`, then `COPY --chmod=0755 . /`.
5. `EXPOSE 7880`, `VOLUME /config`, `CMD ["/start.sh"]`.

Do not compile GoAccess from source: that would need the build stage and the wrapper's tarball, which is not needed for the apt build.

## 5. docker-bake.hcl

Standard layout from `apps/adguardhome-sync/docker-bake.hcl`, with:

```hcl
variable "APP" {
  default = "goaccess-npm-logs"
}

variable "VERSION" {
  // NOTE: Ubuntu package version, no renovate datasource confirmed for apt.
  // Keep in step with PACKAGE_VERSION in the Dockerfile (1:1.9.4-1 -> 1.9.4).
  default = "1.9.4"
}

variable "PACKAGE_VERSION" {
  default = "1:1.9.4-1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://goaccess.io"
}
```

The `image` target should also pass `PACKAGE_VERSION = "${PACKAGE_VERSION}"` in `args`. Keep `image-all` for amd64 and arm64. Validate with `cd apps/goaccess-npm-logs && docker buildx bake --print`.

Open point: the valkey precedent uses a commented-out `repologydepName=...` line because repology was unreachable from their network. Use the same style here if no datasource is confirmed, and do not invent a `// renovate:` datasource.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://goaccess.io"` (matches `SOURCE`).
- `ports`:
  - `port: 7880`, `protocol: tcp`, `required: false`. The conflict with the wrapper's `7890` (section 1) must be settled before merging; if the real port is different, change this and the test.
- `env` (only names the start script or GoAccess reads; defaults match `start.sh`):
  - `TZ`, default `Etc/UTC`, `required: false` (sibling convention).
  - `GOACCESS_LOG_DIR` (default `/opt/log`, `required: false`) is the only variable the sketch in section 7 reads. Wrapper options (`EXCLUDE_IPS`, `HTML_REFRESH`, `KEEP_LAST`, `PERSIST`) are listed only once `start.sh` implements them. Do not list the wrapper's basic-auth variables: the plan does not implement them (section 10).
- `volumes`:
  - `- path: /config`, `required: true` (reports and state).
  - `- path: /opt/log`, `required: false`: a read-only mount of the NPM log directory. The image does not declare it as `VOLUME` (a read-only mount is chosen by the user), so the entry documents the expected mount.
- `dependencies` / `opt_dependencies`: none. The NPM container is not a ContainerForge dependency; the logs come from a host mount.

## 7. start.sh

Requirements: idempotent, works with an empty `/config`, no writes to `/app`, `exec` at the end. Logs must be read from `/opt/log`, which is mounted read-only; the test runs with no mount at all.

Sketch:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="/config/reports"
mkdir -p "${REPORT_DIR}" /tmp/goaccess

LOG_DIR="${GOACCESS_LOG_DIR:-/opt/log}"
shopt -s nullglob
logs=( "${LOG_DIR}"/proxy-host-*_access.log )
shopt -u nullglob

# No logs yet (or none mounted, as in the test run): read an empty file so the
# process keeps running and the report server still starts.
if [ "${#logs[@]}" -eq 0 ]; then
  : > /tmp/goaccess/empty.log
  logs=( /tmp/goaccess/empty.log )
fi

exec goaccess "${logs[@]}" \
  --log-format='[%d:%t %^] %^ %^ %s - %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"' \
  --date-format=%d/%b/%Y --time-format=%H:%M:%S \
  --real-time-html --addr=0.0.0.0 --port=7880 \
  -o "${REPORT_DIR}/report.html"
```

Notes:
- The `--log-format` string is copied from the wrapper's `npm.sh` (section 1). `--date-format`/`--time-format` are inferred from the `%d:%t` pattern and are UNVERIFIED; confirm with a real NPM log sample.
- `--addr` and `--real-time-html`/`--port` are GoAccess options (the wrapper uses `real-time-html` and `port` in its config file). Confirm `goaccess --help` in the built image before relying on the exact flag names.
- Empty `/config` works: the report directory is created, and no config file is needed.
- Wrapper's behaviour of `CUSTOM` or `NGINX_ACCESS` log types is out of scope for this first version. Only the NPM format is implemented.
- The wrapper's `EXCLUDE_IPS` and `KEEP_LAST` options map to GoAccess flags (`--ignore-ip`, `--keep-last`), if added later.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '7880'

filePaths:
- /usr/bin/goaccess
```

- The test runs with no environment variables and no `/opt/log` mount, so the empty-log path in `start.sh` is the one being tested. The NPM-log path is run by hand (section 11).
- `timeoutSeconds` is a top-level key; 180 is the most common value across sibling tests.
- A `tcp` check only proves the server listens inside the container, not that another container can reach it (per `container-test.instructions.md`).

## 9. Rootless and read-only-rootfs adaptations

| Draft / wrapper expectation | Plan |
| --- | --- |
| Chart runs as root (`runAsUser 0`) | Runs as `apps` (uid 568). GoAccess needs no root: it reads files and listens on 7880 (above 1024). |
| `readOnlyRootFilesystem false` | Compatible with `true`: writes go to `/config/reports` and `/tmp/goaccess`. |
| Wrapper writes to `/goaccess-logs`, `/goaccess-config`, `/var/www/html` | Not used. Reports go to `/config/reports`; no nginx, no browser list copy. |
| `hostPath` volume for logs (`hostpath1`) | Plan documents `/opt/log` as a read-only mount in `settings.yaml`. Whether the user uses a hostPath or a PVC is the user's choice. |
| Privileged: no | No privileges needed. |

## 10. Risks, caveats and open questions

- Port conflict: wrapper `EXPOSE 7880` and README use 7880; its `npm.sh` config writes `port 7890`. Check which one the real report uses before merging, and fix `settings.yaml` and the test to match.
- Nginx and basic auth are removed. The wrapper's basic auth (`BASIC_AUTH*`) is not reproduced here; the report is served without auth on port 7880. Put it behind the ingress or a reverse proxy with auth. Flag this to the user as a deliberate deviation.
- WebSocket: the realtime report needs the reverse proxy to forward upgrade headers (the draft says so; the draft's point is inferred, not fetched).
- GeoIP: the wrapper bundles three MaxMind GeoLite2 `.mmdb` files (dated 2026-04-30 in its README). This plan does not bundle them. MaxMind's license terms apply to redistributing those files; GeoIP is off unless a user supplies a database under `/config`. Confirm this is acceptable before enabling GeoIP.
- Log format: the NPM `log-format` string is taken from the wrapper and not tested against real logs. Check against a real `proxy-host-*_access.log` sample.
- Version: apt `1:1.9.4-1` is older than upstream 1.12 and the wrapper's 1.10.2. Pinned apt packages can be replaced by a newer Ubuntu revision; if the pinned revision disappears from the archive, the build fails, and the pin must be updated.
- Arm64: UNVERIFIED (section 1).
- Blockers: none for the apt install on amd64. The `latest` tag cannot be pinned, so the draft's image cannot be used as-is.

## 11. Build and test steps

```sh
cd apps/goaccess-npm-logs
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker rm -f goaccess-npm-logs-probe 2>/dev/null; docker volume rm goaccess-npm-logs-probe-config 2>/dev/null
docker run --rm -d --name goaccess-npm-logs-probe --read-only --tmpfs /tmp \
  -v goaccess-npm-logs-probe-config:/config goaccess-npm-logs:1.9.4
docker logs -f goaccess-npm-logs-probe         # until idle
docker exec goaccess-npm-logs-probe sh -c 'ss -ltn | grep -q ":7880 "' && echo "listening"
docker rm -f goaccess-npm-logs-probe; docker volume rm goaccess-npm-logs-probe-config

forgetool containers test --image goaccess-npm-logs:1.9.4 --config ./apps/goaccess-npm-logs/container-test.yaml
```

Then run once with a sample NPM log in a read-only mount to check parsing:

```sh
mkdir -p /tmp/npm-sample && printf '%s\n' '[25/Nov/2026:10:00:00 +0000] - 200 200 - GET https example.test "/" [Client 192.0.2.1] [Length 512] [Gzip -] [Sent-to 127.0.0.1] "Mozilla/5.0" "-"' > /tmp/npm-sample/proxy-host-1_access.log
docker run --rm -d --name goaccess-npm-logs-npm --read-only --tmpfs /tmp \
  -v /tmp/npm-sample:/opt/log:ro -v goaccess-npm-logs-npm-config:/config goaccess-npm-logs:1.9.4
```

The sample line is illustrative: it must be checked against a real NPM log before it is used. Readiness: the container is still running, the port is listening, and the log shows a GoAccess start line with no parse errors. Exact text UNVERIFIED.

Expected test result: `tcp 7880` and `filePaths /usr/bin/goaccess` pass.

## 12. PR checklist

- Branch: `feat/add-goaccess-npm-logs`
- Commit: `feat(goaccess-npm-logs): add new container`
- PR title: `feat(goaccess-npm-logs): add new container`
- PR description: from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user the PR needs a signed Contributor License Agreement at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: this plan was written without building or running the image. Include the port conflict, the NPM log-format check, arm64, and the GeoIP decision as open items.
- Version alignment: `VERSION` (`1.9.4`) and `PACKAGE_VERSION` (`1:1.9.4-1`) in `docker-bake.hcl` match the Dockerfile's `ARG`s.
- Not a `FROM` base: no `DOWNSTREAM_CHANGES.md`.
