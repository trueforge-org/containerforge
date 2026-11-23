# adminer — implementation plan
> Source: ./draft.md · Target: apps/adminer/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 6.3.1 (GitHub release tag `v6.3.1`). The draft says `adminer:latest` (Docker Official Image, built by TimWolla/docker-adminer), whose Dockerfile still pins 6.3.0, so the draft spec of 6.3.1 is the newer, correct target. |
| Renovate | `datasource=github-releases depName=vrana/adminer` (`versioning=semver` is fine; tags are `vX.Y.Z`) |
| License | Dual: `Apache-2.0 OR GPL-2.0-only` (file header: "Apache License 2.0 or GPL 2.0 (one or other)"; repo LICENSE says the same). SPDX for bake: `Apache-2.0 OR GPL-2.0-only`. |
| Source URL | https://github.com/vrana/adminer |
| Binary | single PHP file, arch-neutral: `https://github.com/vrana/adminer/releases/download/v6.3.1/adminer-6.3.1.php` (other assets: `-en`, `-mysql`, `-mysql-en`, `.zip`, `editor-6.3.1.php`) |
| Checksum | UNVERIFIED as an upstream checksum: the release publishes none. Reference sha256 of `adminer-6.3.1.php` computed on 2026-11-23: `a9aed04e4e68c4e46283804a69ee70cad4fbf23203b46470b760868b2fd9bd76`. The file header carries `@version 6.3.1`, which the build can check against `VERSION`. |
| PHP requirement | PHP 5.4+ for the compiled file (upstream README). Ubuntu 26.04 ships php8.5 (`php8.5-cli 8.5.4-0ubuntu1.5`, amd64 and arm64). |
| Upstream Dockerfile reviewed | https://github.com/TimWolla/docker-adminer/blob/6d83dde54e9e8a76c9e003eb494e296808a2a627/6/Dockerfile (php:8.4-alpine, `php -S [::]:8080 -t /var/www/html`, extensions mysqli, pdo_pgsql, pdo_sqlite, pdo_odbc, pdo_dblib; `USER adminer`; EXPOSE 8080; PHP ini: upload 128M, memory 1G, execution 600s, max_input_vars 5000) |
| Upstream env vars | None read by `adminer.php` itself. `ADMINER_DEFAULT_SERVER`, `ADMINER_DESIGN`, `ADMINER_PLUGINS` belong to the TimWolla wrapper (`index.php`, `entrypoint.sh`, `plugin-loader.php`) and are not part of Adminer. |

## 2. Target layout

```
apps/adminer/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base; check with `grep -r "containerforge/adminer\|apps/adminer" apps/*/Dockerfile` before the PR).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: the draft says ubuntu alone is enough; PHP comes from apt. Closest sibling: `apps/phpmyadmin` (ubuntu + php8.5 apt packages + `php -S` built-in server, `/app/www/public`) and `apps/adguardhome-sync` for the file layout.

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `USER root`.
2. `RUN` apt (no pin needed: the tagged version is Adminer, not PHP): `apt-get update && apt-get install -y --no-install-recommends php8.5-cli php8.5-mysql php8.5-pgsql php8.5-sqlite3 php8.5-mbstring && rm -rf /var/lib/apt/lists/*`. Confirm at build time that none of these is already in the base (`php` is not: the ubuntu base package list has no PHP), and that `php8.5-mbstring` exists on resolute (UNVERIFIED, drop it if not, Adminer works without it).
   - `pdo_odbc` and `pdo_dblib` (MSSQL, ODBC) from the upstream Dockerfile are out of scope; list as a possible follow-up.
3. Download and install into `/app/www` (read-only at runtime):
   ```sh
   mkdir -p /app/www /usr/share/licenses/adminer && \
   curl -fsSL -o /app/www/index.php "https://github.com/vrana/adminer/releases/download/v${VERSION#v}/adminer-${VERSION#v}.php" && \
   grep -q "@version ${VERSION#v}" /app/www/index.php && \
   curl -fsSL -o /usr/share/licenses/adminer/LICENSE "https://raw.githubusercontent.com/vrana/adminer/v${VERSION#v}/LICENSE" && \
   chown -R root:root /app && chmod -R a+rX /app
   ```
   The `grep` is the integrity guard (upstream publishes no checksum). Naming the file `index.php` makes `php -S` serve it at `/`.
4. `ENV` (all caches to /tmp, HOME already `/config` from base): `MEMORY_LIMIT=1G UPLOAD_LIMIT=128M MAX_EXECUTION_TIME=600` (same pattern as `apps/phpmyadmin`; defaults copied from the upstream Docker image ini).
5. `USER apps`, then `COPY --chmod=0755 . /` (puts `start.sh` at `/start.sh`).
6. `EXPOSE 8080`, `WORKDIR /config`, `VOLUME /config`. Final instruction state must be `USER apps`.

## 5. docker-bake.hcl

- `APP` = `adminer`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=vrana/adminer
  default = "6.3.1"
  ```
  (the Dockerfile uses `${VERSION#v}` so both a `6.3.1` and a `v6.3.1` value work; confirm what the repo's renovate setup returns for `v`-prefixed tags, as `adguardhome-sync` stores no `v` and `bazarr` stores `v`.)
- `LICENSE` = `Apache-2.0 OR GPL-2.0-only`; `SOURCE` = `https://github.com/vrana/adminer`
- Copy the 4 targets and the `default` group verbatim from `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `image` with `args.VERSION` and the two OCI labels, `image-local` with `type=docker` and tag `${APP}:${VERSION}`, `image-all` with amd64 and arm64).
- Validate: `cd apps/adminer && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/vrana/adminer"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - {name: MEMORY_LIMIT, default: "1G", required: false}
  - {name: UPLOAD_LIMIT, default: "128M", required: false}
  - {name: MAX_EXECUTION_TIME, default: "600", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: false
opt_dependencies:
  - name: mariadb      # exists
  - name: postgresql   # exists
```
(Write the entries in the multi-line style of sibling files.) `MEMORY_LIMIT`, `UPLOAD_LIMIT` and `MAX_EXECUTION_TIME` are read by `start.sh` and passed to PHP, they are not Adminer variables. `dependencies:` is intentionally absent: Adminer starts without a database. `/config` is only used for PHP scratch and for SQLite files a user chooses.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /tmp/php-sessions
cd /app/www
exec php -S 0.0.0.0:8080 -t /app/www \
  -d "memory_limit=${MEMORY_LIMIT:-1G}" \
  -d "upload_max_filesize=${UPLOAD_LIMIT:-128M}" \
  -d "post_max_size=${UPLOAD_LIMIT:-128M}" \
  -d "max_execution_time=${MAX_EXECUTION_TIME:-600}" \
  -d "max_input_vars=5000" \
  -d "session.save_path=/tmp/php-sessions" \
  -d "sys_temp_dir=/tmp" \
  -d "upload_tmp_dir=/tmp"
```
Idempotent, nothing written to `/app` or seeded into `/config`. Binds all interfaces. Optional `PHP_CLI_SERVER_WORKERS` (a PHP 7.4+ built-in server variable) could be exposed later; not included now.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /
  statusCode: 200
filePaths:
- /app/www/index.php
- /usr/bin/php
- /usr/share/licenses/adminer/LICENSE
```
No env needed. `timeoutSeconds`: default (php starts instantly; `apps/phpmyadmin` uses 180, copy that only if CI flakes). Not a database-dependent app, so the narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/www/html/plugins-enabled`, `.adminer-init`, `adminer.css` symlink (TimWolla wrapper) | Not used; wrapper features dropped, `/app/www` stays read-only. |
| PHP sessions (default `/var/lib/php/sessions`) | `session.save_path=/tmp/php-sessions`. |
| PHP upload and temp files | `/tmp`. |
| Port 80 | Not used; 8080 (upstream image also uses 8080). |

Draft security expectations: chart runs as UID 0 and `readOnlyRootFilesystem: false`. Both are rejected: the image runs as `apps` (UID 568) with a read-only rootfs, `/tmp` tmpfs, `/config` volume. No privileged mode, no extra persistence.

## 10. Risks, caveats and open questions

- Draft: `adminer:latest` is rolling; the new image pins `VERSION` and renovate bumps it.
- Draft: needs an external DB; none is bundled. Users must set the server field at login (the `ADMINER_DEFAULT_SERVER` prefill is a wrapper feature and not ported; offer a follow-up if wanted).
- Plugins and designs (upstream wrapper features) are not included. They would need the source tarball (`designs/`, `plugins/`) and its checksum.
- Adminer has a history of SSRF/auth issues when exposed publicly; do not expose without auth (documentation note, not a build change).
- No upstream checksum; the `@version` grep is the only guard. A pinned sha256 would need a manual bump with each renovate PR, so it is not used.
- UNVERIFIED: whether `php8.5-mbstring` is a separate package on Ubuntu 26.04; check with `apt-cache policy` in the build.
- Not blockers: no musl, GPU, privileged mode or arm64 gaps (arch-neutral).

## 11. Build and test steps

```sh
cd apps/adminer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name adminer-probe --read-only --tmpfs /tmp -v adminer-probe-config:/config adminer:6.3.1
docker logs -f adminer-probe        # expect: "PHP 8.5.x Development Server (http://0.0.0.0:8080) started"
curl -fsS http://<container-ip>:8080/ | grep -i adminer
docker rm -f adminer-probe; docker volume rm adminer-probe-config
forgetool containers test --image adminer:6.3.1 --config ./apps/adminer/container-test.yaml
```
Fresh `/config` volume each round, max 10 rounds. Optionally try a login against a throwaway `mariadb` container (the apt `php8.5-mysql` driver is the only part not covered by the tests).

## 12. PR checklist

- Branch `feat/add-adminer` from a freshly pulled `main`; commit and PR title `feat(adminer): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` keeping all sections; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Tick only what applies. Untested until run: image build (amd64 and arm64), startup under `--read-only`, DB logins (mysql, pgsql, sqlite), `forgetool` run, `docker buildx bake --print`.
- Checklist: minimal and app-scoped, instruction files followed, bake and Dockerfile version aligned, rootless and read-only, empty `/config` works, no downstream impact, `bake --print` ran.
