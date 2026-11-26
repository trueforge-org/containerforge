# rss-bridge — implementation plan
> Source: ./draft.md · Target: apps/rss-bridge/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable release `2025-08-05` (published 2025-08-05T17:52:31Z, not prerelease) (https://api.github.com/repos/RSS-Bridge/rss-bridge/releases/latest). The draft's chart pin `2025-06-03` (published 2025-06-03T19:25:56Z) is one release behind. Decide the target and re-review the Dockerfile at that tag: the Dockerfile reviewed here is at commit `98e03011dbb80ea9cea3ef8c5e29a1778f169cc9`, which is not confirmed to be the `2025-08-05` tag. |
| Renovate | `datasource=github-releases depName=RSS-Bridge/rss-bridge versioning=loose` (tags are dates, not semver; `loose` per the bake rule). |
| License | Unlicense (GitHub API SPDX `Unlicense`, https://api.github.com/repos/RSS-Bridge/rss-bridge). |
| Source URL | https://github.com/RSS-Bridge/rss-bridge |
| Download | No release assets. The GitHub release `2025-06-03` has an empty `assets` array (https://api.github.com/repos/RSS-Bridge/rss-bridge/releases/tags/2025-06-03). Fetch the source archive `https://github.com/RSS-Bridge/rss-bridge/archive/refs/tags/${VERSION}.tar.gz`. PHP source, no compile step. |
| Per-arch | Source is arch-neutral. The upstream Dockerfile picks the curl-impersonate archive by build arch (aarch64, armv7l, x86_64). arm64 is supported by design, not tested here. |
| Checksum source | Upstream Dockerfile verifies SHA-512 of each libcurl-impersonate archive (summary of https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/Dockerfile). The curl-impersonate release asset names and URLs are UNVERIFIED: the GitHub API returned HTTP 403 for `lwthiker/curl-impersonate` tag `v1.0.0-rc2`. Read the exact URLs and hashes from the upstream Dockerfile before writing them. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/Dockerfile (summarized, not verbatim). Base `debian:12-slim`, apt `nginx php-fpm` + PHP extensions (curl, intl, mbstring, memcached, sqlite3, xml, zip), `ca-certificates nss-plugin-pem curl patchelf` (last two purged). libcurl-impersonate `v1.0.0rc2` for each arch, SHA-512 checked, extracted to `/usr/local/lib/curl-impersonate`, soname `libcurl.so.4`. nginx logs to stdout/stderr. PHP-FPM pool config for PHP 8.2. `COPY` app to `/app` owned `www-data`. `ENV LD_PRELOAD=<lib>`, `CURL_IMPERSONATE=chrome131`, `EXPOSE 80`, `ENTRYPOINT /app/docker-entrypoint.sh`. No CMD, USER or VOLUME. |
| docker-entrypoint.sh reviewed | https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/docker-entrypoint.sh (summarized). Reads only `HTTP_PORT`. Scans `/config/` recursively for files. Copies `*Bridge.php` to `/app/bridges/`, `*Format.php` to `/app/formats/`, writes `/app/config.ini.php`, `/app/whitelist.txt`, `/app/DEBUG`, and seds `/etc/nginx/sites-enabled/default` when `HTTP_PORT` is set. Starts nginx (daemonizes), then `exec php-fpm8.2 --nodaemonize`. |
| Port | 80/http (nginx, EXPOSE 80). `HTTP_PORT` changes it. |
| Env vars | `HTTP_PORT` (confirmed in entrypoint). `LD_PRELOAD`, `CURL_IMPERSONATE` are set by the image itself, not user config. Others UNVERIFIED. |
| Docs | https://rss-bridge.github.io/rss-bridge/index.html is the landing page only; the install and config pages were not fetched (UNVERIFIED). |
| Dependencies | No database confirmed. Needs outbound internet to fetch the feeds. |

## 2. Target layout

- `apps/rss-bridge/Dockerfile`
- `apps/rss-bridge/docker-bake.hcl`
- `apps/rss-bridge/settings.yaml`
- `apps/rss-bridge/container-test.yaml`
- `apps/rss-bridge/start.sh` (replaces the upstream `docker-entrypoint.sh`; do not copy that script)
- `apps/rss-bridge/etc/nginx/sites-enabled/default` and `apps/rss-bridge/etc/php/8.5/fpm/pool.d/www.conf` (or an equivalent file), because `COPY . /` ships only `etc/` from the app folder (`include/.dockerignore` allow-list). Reason: nginx and PHP-FPM configs must be rootless (listen port, pid and temp paths under `/tmp`).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (porter table: generic userland maps to ubuntu). Upstream is `debian:12-slim`, which is not a ContainerForge base; ubuntu is the family default.

Closest sibling: `apps/bookstack` (PHP stack on ubuntu 26.04, `php8.5-*` packages from apt, `clear_env = no` for php-fpm, `USER apps`, `COPY --chmod=0755 . /`). Use `php8.5` the same way. Also `apps/nginx` for nginx config layout. PHP version support by RSS-Bridge is UNVERIFIED: check the upstream `composer.json` or README at the chosen tag before pinning `php8.5`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install runtime packages (no `--no-install-recommends` drift): `nginx php8.5-fpm php8.5-cli php8.5-curl php8.5-intl php8.5-mbstring php8.5-memcached php8.5-sqlite3 php8.5-xml php8.5-zip ca-certificates curl`. Verify the names exist on ubuntu 26.04 (`php8.5-*` used by bookstack confirms the family). Do not install `nss-plugin-pem` unless the upstream Dockerfile needs it for the curl-impersonate library.
3. Fetch the source: `curl -fL "https://github.com/RSS-Bridge/rss-bridge/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/rssbridge.tar.gz && tar xzf /tmp/rssbridge.tar.gz -C /app --strip-components=1`.
4. curl-impersonate: copy the exact per-arch asset URL and SHA-512 from the upstream Dockerfile at the chosen commit. Map `TARGETARCH` (`amd64` to `x86_64`, `arm64` to `aarch64`) with a `case` in the `RUN`. Verify with `sha512sum -c`. Extract to `/usr/local/lib/curl-impersonate`, set the soname to `libcurl.so.4` as upstream does. Ship the upstream license for curl-impersonate in `/usr/share/licenses/rss-bridge/`.
5. Remove `curl`/`patchelf` after use if they are only build helpers (upstream purges them). Keep `curl` if the base already provides it.
6. License files: `COPY`-equivalent `cp /app/LICENSE /usr/share/licenses/rss-bridge/` (exact file name UNVERIFIED).
7. Ownership and permissions: `chown -R apps:apps /app && chmod -R 755 /app`. The entrypoint's `www-data` owner has no meaning here.
8. Cleanup: `rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*`.
9. Tail:

```dockerfile
ENV HOME=/tmp \
    LD_PRELOAD=/usr/local/lib/curl-impersonate/libcurl.so.4 \
    CURL_IMPERSONATE=chrome131

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app
```

Note: `EXPOSE 8080` (not 80) because the app runs as non-root and cannot bind port 80 (section 9). Confirm the port in `start.sh`. The `LD_PRELOAD` path must be the exact soname/path extracted in step 4.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rss-bridge"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=RSS-Bridge/rss-bridge versioning=loose
  default = "2025-08-05"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/RSS-Bridge/rss-bridge"
}
```

`LICENSE` is the SPDX id from section 1. Then the four standard targets and `group "default"` from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/RSS-Bridge/rss-bridge"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: HTTP_PORT
    default: "8080"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `HTTP_PORT` is the only env var confirmed by the entrypoint. Its default is set to 8080 here because a non-root process cannot bind 80. Upstream default is 80: state this change in the PR.
- `/config` holds user state: `config.ini.php`, `whitelist.txt`, custom bridges and formats (section 7).
- `dependencies: []`: no database.

## 7. start.sh

Replace the upstream entrypoint. Do not write into `/app` or `/etc`.

```bash
#!/usr/bin/env bash

HTTP_PORT="${HTTP_PORT:-8080}"
mkdir -p /config/bridges /config/formats /tmp/nginx /tmp/php-fpm /tmp/sessions

# seed default config only when missing (empty /config must work)
[[ -f /config/config.ini.php ]] || cp /app/config.ini.php.example /config/config.ini.php 2>/dev/null || true
[[ -f /config/whitelist.txt ]] || touch /config/whitelist.txt

# nginx listen port from env, written under /tmp (not /etc)
sed "s/listen 80;/listen ${HTTP_PORT};/" /etc/nginx/sites-enabled/default > /tmp/nginx-default.conf

nginx -c /etc/nginx/nginx.conf -g "daemon off;" &
exec php-fpm8.5 --nodaemonize --fpm-config /etc/php/8.5/fpm/php-fpm.conf
```

Points to confirm before writing:

- Symlinks into `/app` (`/app/config.ini.php`, `/app/whitelist.txt`) are NOT created in `start.sh`, because `/app` is read-only at runtime. Create them in the Dockerfile at build time, pointing to `/config/...` (dangling until seeded). Verify that RSS-Bridge follows symlinks. Only do this if the app reads those paths from `/app`.
- Custom bridges/formats: upstream copies `/config/*Bridge.php` into `/app/bridges`. That copy cannot run on a read-only `/app`. Check whether RSS-Bridge can load bridges from an alternate directory (UNVERIFIED). If not, the feature needs a documented limitation, not a `/app` write.
- `DEBUG` file: upstream writes `/app/DEBUG` to toggle debug. Map to `/config/DEBUG` only if the app reads it from `/config`; otherwise drop it and say so.
- The `sed` line above assumes the nginx listen line is `listen 80;`. Check the shipped `etc/` config and use the real line.
- nginx must not be daemonized by its own config. Run it foreground and use the job, or run php-fpm as the foreground process and nginx from the same script. Only one `exec` is allowed; decide the process model with the probe run (section 11).
- `exec` the final long-running process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/index.php
- /app/lib
- /usr/local/lib/curl-impersonate
- /usr/share/licenses/rss-bridge
```

- One `tcp` and one `http` probe on 8080, matching `ports` in `settings.yaml`.
- `filePaths` checks the entry point, the library directory and the curl-impersonate library (the file in `/usr/local/lib/curl-impersonate`). Confirm the actual file names at the chosen tag.
- `timeoutSeconds: 120` is a starting value; check `apps/bookstack` (240 with its own queue). Use the sibling value if the first probe run needs longer.
- Test runs without env vars: `HTTP_PORT` takes its default, so this path is covered.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/config.ini.php`, `/app/whitelist.txt`, `/app/DEBUG` (entrypoint) | `/config/...`, with symlinks made at build time, or read from `/config` if the app supports it (section 7) |
| `/app/bridges`, `/app/formats` (entrypoint copies custom bridges) | `/config/bridges`, `/config/formats` if the app loads them there (UNVERIFIED); otherwise documented limitation |
| `/etc/nginx/sites-enabled/default` (sed on `HTTP_PORT`) | Not written at runtime. The port comes from `HTTP_PORT` through a file under `/tmp` (section 7) |
| nginx pid, temp, logs (`/var/log/nginx`, `/var/lib/nginx`) | Set to `/tmp` in the shipped nginx config. nginx logs to stdout/stderr through the `/dev/stdout` symlinks used upstream, if the user can write them; otherwise `error_log /dev/stderr` |
| PHP-FPM pool: `user`/`group` and listen socket | Remove `user`/`group` (process runs as `apps`). Listen on `127.0.0.1:9000` or a socket under `/tmp` |
| `/var/lib/php/sessions`, PHP temp | `session.save_path=/tmp/sessions`, `upload_tmp_dir=/tmp` in the shipped `php.ini` override |
| `/usr/local/lib/curl-impersonate` | Read-only at runtime, populated at build time. Fine. |

- Upstream runs as root (`runAsUser: 0` in the chart). ContainerForge requires `USER apps` and read-only rootfs. The draft's "non-root: no" and "read-only-rootfs: no" expectations are the chart's behavior, not the target; the port must meet ContainerForge rules.
- Port 80 cannot be bound by `apps`, hence `8080` (section 4).
- `privileged: no` matches the default. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Version: `2025-08-05` is the latest release; the chart pins `2025-06-03`. Re-review the Dockerfile and `docker-entrypoint.sh` at the chosen tag, since the review here was at commit `98e0301`.
- PHP version: upstream uses `php8.2` in the Debian image. This plan uses `php8.5` (ubuntu 26.04). Confirm RSS-Bridge runs on 8.5 (UNVERIFIED).
- Symlinks and custom bridges (section 7): the biggest design risk. If RSS-Bridge only reads from `/app`, the custom-bridge feature cannot be supported on a read-only rootfs without a documented change.
- curl-impersonate: asset names and checksums UNVERIFIED (HTTP 403 on the release API). The `LD_PRELOAD` path must match the extracted file. arm64 asset existence not confirmed.
- Outbound network needed to fetch feeds: not testable in the test suite (no external access assumed); say so in the PR.
- Blockers: none known beyond the items above. Upstream image design (root, nginx on 80, entrypoint writes into `/app`) does not match ContainerForge rules and must be reworked, not copied.
- Downstream: none. `FROM` consumers of this app: none.

## 11. Build and test steps

From `apps/rss-bridge` (one app at a time):

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run, empty `/config`, read-only root:

```sh
docker volume create rss-bridge-probe-config
docker run --rm -d --name rss-bridge-probe --read-only --tmpfs /tmp \
  -v rss-bridge-probe-config:/config rss-bridge:<version>
docker logs -f rss-bridge-probe
```

   Pass: container still running, nginx and php-fpm both up (readiness line UNVERIFIED), no fatal error or repeated PHP stack trace. Then `curl -f http://localhost:8080/` from the host (port publish needed for this step only).
4. `forgetool containers test --image rss-bridge:<version> --config ./apps/rss-bridge/container-test.yaml`
5. Cleanup: `docker rm -f rss-bridge-probe; docker volume rm rss-bridge-probe-config`.
6. arm64 only after amd64 is green, or for an arm64-specific failure (protocol).

## 12. PR checklist

- Branch `feat/add-rss-bridge`, commit `feat(rss-bridge): add new container`, target `main`.
- PR title matches the commit.
- Body: upstream source and tag, pinned curl-impersonate version and checksum source, base image and digest, port (8080, changed from upstream 80, with reason), volume `/config`, what was built and tested, and the unverified points (section 10).
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only the applicable boxes.
- Untested items to list: arm64 build, feed fetching (needs internet), custom bridges, and the PHP 8.5 compatibility.
