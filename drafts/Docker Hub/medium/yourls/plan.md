# yourls — implementation plan
> Source: ./draft.md · Target: apps/yourls/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.10.6 (GitHub release published 2026-08-30, https://api.github.com/repos/YOURLS/YOURLS/releases). Draft tag matches. Previous: 1.10.5 (2026-08-28). |
| Renovate | `datasource=github-releases depName=YOURLS/YOURLS versioning=semver` |
| License | MIT (GitHub SPDX `MIT`, https://api.github.com/repos/YOURLS/YOURLS) |
| Source URL | https://github.com/YOURLS/YOURLS |
| Download | `https://github.com/YOURLS/YOURLS/archive/refs/tags/${VERSION}.tar.gz` (tag confirmed in the tags list). The release has no uploaded assets. |
| Checksum source | None published. UNVERIFIED: no checksum found; the tag is the only pin. |
| Upstream Dockerfile reviewed | Draft names `https://github.com/YOURLS/containers/blob/ab773d7d9e7408f66b532736ceea60324b9f3e3f/images/yourls/Dockerfile.template`. UNVERIFIED: not fetched in this run. |
| Per-arch | Interpreted PHP, identical on amd64 and arm64. |
| Config | `user/config-sample.php` (https://raw.githubusercontent.com/YOURLS/YOURLS/master/user/config-sample.php). Constants read: `YOURLS_DB_USER`, `YOURLS_DB_PASS`, `YOURLS_DB_NAME`, `YOURLS_DB_HOST` (accepts `host:port`), `YOURLS_DB_PREFIX` (default `yourls_`), `YOURLS_SITE`, `YOURLS_LANG` (empty), `YOURLS_UNIQUE_URLS` (true), `YOURLS_PRIVATE` (true), `YOURLS_COOKIEKEY`, `YOURLS_URL_CONVERT` (36), `YOURLS_DEBUG` (false). No port, path or timezone constant. |
| Env vars the chart sets | `YOURLS_DB_HOST`, `YOURLS_DB_NAME`, `YOURLS_DB_USER`, `YOURLS_DB_PASS`, `YOURLS_PRIVATE`, `YOURLS_SITE`, `YOURLS_USER`, `YOURLS_PASS` (chart values, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yourls/values.yaml). UNVERIFIED: the sample config has no `YOURLS_USER`/`YOURLS_PASS` constants, so whether the app reads them is not confirmed. Do not list them in `settings.yaml` until confirmed. |
| Port | Chart service `main` is 8080/tcp (targetPort 8080). Upstream port not stated in any fetched source. |
| Chart security | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, runAsNonRoot and privileged unset. Persistence: none. |
| Upstream image | `yourls:1.10.6@sha256:4e5ec5cdc4be3470bf2a718a1b77c01525498c7b770119bd2a1ed669dd4c529a` (chart). |
| PHP requirements | UNVERIFIED: minimum PHP version and extension list not confirmed. docs.yourls.org redirects to https://yourls.org/docs/guide/requirements, which was not followed in this run. |
| Ubuntu PHP packages | `php8.5-mysql`, `php8.5-curl`, `php8.5-xml`, `php8.5-zip` are installed from apt on this base in `apps/bookstack/Dockerfile`, so PHP 8.5 is available on `ghcr.io/trueforge-org/ubuntu:26.04`. `php8.5-mbstring` is UNVERIFIED for this base. |
| Dependencies | `mariadb` (apps/mariadb exists ✅). |

## 2. Target layout

- `apps/yourls/Dockerfile`
- `apps/yourls/docker-bake.hcl`
- `apps/yourls/settings.yaml`
- `apps/yourls/container-test.yaml`
- `apps/yourls/start.sh`
- `apps/yourls/defaults/user/config.php` (seed template for `/config`, only when missing), reason: YOURLS needs a config file and the app tree must stay read-only.

No `root/`, `etc/`, `health/`. No `DOWNSTREAM_CHANGES.md`: YOURLS is not a `FROM` base. If the seed template is generated in `start.sh` instead, drop `defaults/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits: a PHP app with PHP from apt on the Ubuntu base. Closest sibling: `apps/bookstack` (PHP 8.5 from apt, app tree under `/app/www`, `/config` symlinks). Not `apps/nginx` or `apps/java*`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. One `RUN` with `apt-get update`, then `apt-get install -y --no-install-recommends php8.5-fpm php8.5-cli php8.5-mysql php8.5-curl php8.5-xml php8.5-mbstring nginx` (see section 10 for the web-server choice). No version pin on PHP: it is the runtime, not the app, so it is not compared with `VERSION`. Then `rm -rf /var/lib/apt/lists/*`.
3. Fetch and unpack the release:
   ```dockerfile
   RUN curl -fL -o /tmp/yourls.tar.gz "https://github.com/YOURLS/YOURLS/archive/refs/tags/${VERSION}.tar.gz" && \
       mkdir -p /app/yourls && \
       tar xf /tmp/yourls.tar.gz -C /app/yourls --strip-components=1 && \
       rm -f /tmp/yourls.tar.gz
   ```
   UNVERIFIED checksum: no published checksum; the tag pins the content.
4. Ship the licence: `install -D /app/yourls/LICENSE /usr/share/licenses/yourls/LICENSE` (the upstream tarball includes a LICENSE file; UNVERIFIED until unpacked).
5. Build-time symlink for mutable state: `ln -s /config/yourls/user /app/yourls/user` after removing the shipped `user/` sample, so `user/config.php`, `user/plugins` and `user/languages` live under `/config`. The symlink target is created by `start.sh`.
6. Set the runtime PHP/nginx paths to `/tmp` (sockets, pid, temp files): `/tmp/php-fpm.sock`, `/tmp/nginx` (client_body, proxy, fastcgi temp dirs).
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config

   WORKDIR /app/yourls
   ```

Version alignment: `ARG VERSION` must equal the `docker-bake.hcl` default `1.10.6`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "yourls"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=YOURLS/YOURLS versioning=semver
  default = "1.10.6"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/YOURLS/YOURLS"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `cd apps/yourls && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/YOURLS/YOURLS"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: YOURLS_SITE
    default: "http://localhost:8080"
    required: true
  - name: YOURLS_DB_HOST
    default: "mariadb"
    required: true
  - name: YOURLS_DB_NAME
    default: "MYMARIADBDB"
    required: true
  - name: YOURLS_DB_USER
    default: "MYMARIADBUSER"
    required: true
  - name: YOURLS_DB_PASS
    default: "MYMARIADBPASSWORD"
    required: true
  - name: YOURLS_DB_PREFIX
    default: "yourls_"
    required: false
  - name: YOURLS_PRIVATE
    default: "true"
    required: false
  - name: YOURLS_COOKIEKEY
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```

Rules: every name above is a `define()` constant from `config-sample.php`. `YOURLS_USER`/`YOURLS_PASS` are left out until confirmed (section 1). Port 8080 comes from the chart; confirm the nginx listen port in step 4 matches. The required DB variables carry non-empty placeholder defaults mirroring `apps/mariadb` (settings rule: `required: true` needs a default), so `start.sh` can start on the no-env test run (see section 8).

Dependencies: the draft lists mariadb as a hard dependency (YOURLS cannot install without a database), and apps/mariadb exists. It is declared as `dependencies: - name: mariadb` (hard; same form as `apps/kimai` and `apps/monica`), not `opt_dependencies`, and section 8 uses the narrowed database-dependent test per the build-test-protocol exception.

## 7. start.sh

Requirements:
- `mkdir -p /config/yourls /config/yourls/user/plugins`. Seed `/config/yourls/user/config.php` from the template in `defaults/` only when the file is missing or empty, never overwrite it.
- The `/app/yourls/user` directory is a build-time symlink to `/config/yourls/user` (section 4 step 5), so `/app` is never written at runtime.
- Apply DB and site settings from env on every start by rewriting the matching `define()` lines in `/config/yourls/user/config.php`. Escape `'` and `\` in values before writing. UNVERIFIED: that the app reads a symlinked `user/` directory without issue; test in step 3 of the protocol.
- Start PHP-FPM with the socket in `/tmp`, then `exec nginx -g 'daemon off;'` (or the chosen web server) so signals reach nginx.
- Bind `0.0.0.0:8080`.
- No writes to `/app`. Caches and sockets under `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /admin/
filePaths:
- /app/yourls/index.php
- /app/yourls/includes/load-yourls.php
- /usr/share/licenses/yourls/LICENSE
```

- The test runs without env vars, so the DB-dependent path (`YOURLS_DB_HOST` set, install check) is not exercised. Narrowed assertion: `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`. The http check on `/admin/` may return a redirect to the install page: UNVERIFIED which status the probe sees with no DB; if it is not 200 or 302, narrow to the `tcp` check and a `filePaths` check.
- Do not remove the tcp probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `user/config.php` (written by the installer and by the admin UI) | `/app/yourls/user` -> `/config/yourls/user` (symlink created at build time). |
| `user/plugins`, `user/languages` | Same symlink, so they persist in `/config`. |
| PHP session and upload temp dirs | `/tmp` (php-fpm `php_admin_value[session.save_path]=/tmp`, `upload_tmp_dir=/tmp`). |
| nginx temp and pid | `/tmp/nginx`, `/tmp/nginx.pid`. |
| Chart security | Chart runs root (runAsUser 0). The plan drops root: `USER apps` in the final stage, nginx on 8080 (no privileged port), PHP-FPM as the `apps` user. |

## 10. Risks, caveats and open questions

- Web server choice: nginx plus PHP-FPM (recommended, matches the chart's http model) versus `php -S` (not production). Decide in step 4; record the decision in the PR.
- YOURLS config path: the symlink approach (section 9) is untested. UNVERIFIED that YOURLS will follow a symlinked `user/` directory without issue.
- `YOURLS_USER`/`YOURLS_PASS`: passed by the chart but not in the sample config. UNVERIFIED whether they are read. Do not add to `settings.yaml` until confirmed.
- PHP minimum version and extensions: UNVERIFIED (docs redirect not followed). Installing php8.5 from the base is an assumption that YOURLS 1.10.6 runs on it.
- Database: mariadb must exist with the `yourls` database and user before the install step. The chart uses user `yourls` and database `yourls`.
- Upgrading by replacing `/app` drops plugins only if they are outside `/config`; the symlink keeps them.
- Blockers: none known.

## 11. Build and test steps

```sh
cd apps/yourls
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create yourls-probe-config
docker run --rm -d --name yourls-probe --read-only --tmpfs /tmp \
  -v yourls-probe-config:/config yourls:1.10.6
docker logs -f yourls-probe
docker rm -f yourls-probe; docker volume rm yourls-probe-config
forgetool containers test --image yourls:1.10.6 --config ./apps/yourls/container-test.yaml
```

Expected readiness signal: nginx logs `start worker processes` and php-fpm logs `ready to handle connections`. The container must stay running. A DB-less start is expected to log a database connection failure; that is the narrowed case in the protocol.

## 12. PR checklist

- Branch: `feat/add-yourls`
- Commit: `feat(yourls): add new container`
- Title: `feat(yourls): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: the database-backed install and the arm64 build, unless run.
