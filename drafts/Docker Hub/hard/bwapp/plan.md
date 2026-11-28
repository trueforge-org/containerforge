# bwapp — implementation plan
> Source: ./draft.md · Target: apps/bwapp/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2.2: the SourceForge "Download Latest Version" button points to `bWAPP/bWAPPv2.2/bWAPPv2.2.zip` (15.1 MB, 2014-11-02). `bWAPP_latest.zip` sits at the `bWAPP/` root with the same size. The homepage shows no version number. Pin `bWAPPv2.2.zip` and a sha256 once computed |
| Renovate | Not applicable: SourceForge has no supported datasource and the project is archived. Pin manually |
| License | Creative Commons BY-NC-ND 4.0 (footer of itsecgames.com, MME BV). SPDX `CC-BY-NC-ND-4.0`. NoDerivatives and NonCommercial terms conflict with repackaging, patching and redistributing a public image: likely blocker |
| Source URL | https://www.itsecgames.com/ |
| Download | https://sourceforge.net/projects/bwapp/files/bWAPP/ (same zip for both archs, PHP is interpreted) |
| Checksum | No MD5/SHA1 is shown on the SourceForge folder page; record sha256 yourself when porting |
| Upstream Dockerfile | None (draft: `-`). Community image `raesene/bwapp` not reviewed |
| Ports/env | 80/http (Apache) and 3306 (MySQL) in the draft image. App settings are in `admin/settings.php` (host, user, password, db); the install page `install.php` creates the DB. Default login `bee`/`bug` UNVERIFIED on this page |

## 2. Target layout

`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, `defaults/apache2.conf` and `defaults/php.ini` (rootless Apache config and PHP overrides), `defaults/settings.php` (env-driven DB settings). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Closest sibling: `apps/bookstack` (PHP stack). MySQL is NOT bundled: use the existing `apps/mariadb` container as a dependency (mariadb ✅), splitting the draft's all-in-one image.

## 4. Dockerfile

1. `ARG VERSION`; `USER root`.
2. apt (pin versions where possible, checking they match what the base offers): `apache2`, `libapache2-mod-php` (or `php-fpm`), `php-mysql`, `php-gd`, `php-xml`, `php-mbstring`, `php-curl`, `unzip`. Check which are already in the base before adding.
3. Download the zip to `/tmp`, verify sha256, unzip to `/app/www`.
4. Do not modify upstream PHP (ND licence); only add config files (`settings.php` replacement is a modification of admin config: keep it as an included override or generate it in `/tmp`).
5. Make bWAPP's writable folders (`passwords/`, `images/`, `documents/`, `logs/`) symlinks into `/config/bwapp/...`, created at build with `ln -s`.
6. License: ship upstream license text to `/usr/share/licenses/bwapp/`.
7. `ENV HOME=/config APACHE_RUN_DIR=/tmp/apache APACHE_LOCK_DIR=/tmp/apache APACHE_PID_FILE=/tmp/apache/apache2.pid APACHE_LOG_DIR=/tmp/apache/log`.
8. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

APP `bwapp`; VERSION `2.2` (from `bWAPPv2.2.zip`) with a comment `// renovate: ...` noting no datasource (use `# no renovate datasource: SourceForge, archived`); LICENSE `CC-BY-NC-ND-4.0`; SOURCE `https://www.itsecgames.com/`. Four standard targets, default `image-local`. `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://www.itsecgames.com/"`. ports: 8080/tcp (non-root cannot bind 80; draft's 80 and 3306 are not exposed here). env: `DB_HOST` `mariadb`, `DB_PORT` `3306`, `DB_NAME` `bwapp`, `DB_USER` `MYMARIADBUSER`, `DB_PASS` `MYMARIADBPASSWORD` (all required, since bWAPP cannot work without a DB), `TZ`. volumes: `/config` required. dependencies: `- name: mariadb` ✅ (apps/mariadb exists).

## 7. start.sh

1. `mkdir -p /config/bwapp/{passwords,images,documents,logs}` and `/tmp/apache/log`.
2. Render Apache config to `/tmp` (listen 8080, `DocumentRoot /app/www`); render `admin/settings.php` values from env into a file in `/tmp` and load it via `auto_prepend_file` so `/app` is untouched; never put the password on a command line.
3. Wait for the DB (bounded `/dev/tcp` loop); run the schema install only when the bWAPP database is missing (call the install routine through a one-shot PHP CLI script reproducing `install.php`, UNVERIFIED), idempotent.
4. `exec apache2ctl -D FOREGROUND` (or `apache2 -f /tmp/apache2.conf -DFOREGROUND`), binding `0.0.0.0:8080`.

## 8. container-test.yaml

Narrowed per the protocol exception (hard mariadb dependency, will not serve a working app without it, no sidecar primitive): add `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`. `timeoutSeconds: 180`; `tcp: - port: '8080'` (Apache starts without DB, so keep it); `filePaths: /app/www/index.php` (path UNVERIFIED, confirm after unzip) and `/app/www/login.php`. Runner `apache2 -v`.

## 9. Rootless and read-only-rootfs adaptations

- Apache pid, lock, logs, `/var/run/apache2` to `/tmp/apache`; port 8080 instead of 80.
- PHP sessions `session.save_path=/tmp`, uploads `upload_tmp_dir=/tmp`.
- bWAPP writable dirs to `/config/bwapp/*` via symlinks.
- MySQL data moves to the separate mariadb container (draft's chart ran root and no persistence; rework accepted).
- Runs as UID 568; vulnerabilities are intentional, so isolate it from real networks.

## 10. Risks, caveats and open questions

- Likely blocker: CC BY-NC-ND forbids derivatives and commercial use; confirm with the maintainers that building and publishing an image is acceptable before porting.
- Archived project and a SourceForge-only download that can vanish or change; UNVERIFIED version and checksum.
- `install.php` expects to run in a browser; CLI replacement UNVERIFIED.
- Deliberately vulnerable: never expose publicly.
- Does not match the draft's single-container shape (MySQL separated).

## 11. Build and test steps

```sh
cd apps/bwapp
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create bwapp-probe-config
docker run --rm -d --name bwapp-probe --read-only --tmpfs /tmp -v bwapp-probe-config:/config bwapp:<VERSION>
docker logs -f bwapp-probe
forgetool containers test --image bwapp:<VERSION> --config ./apps/bwapp/container-test.yaml
docker rm -f bwapp-probe; docker volume rm bwapp-probe-config
```
Step 3 also runs once against a throwaway `mariadb` container on a shared network. Expected: Apache `AH00094: Command line` / `resuming normal operations`, port 8080 open, `login.php` returns 200 with the DB reachable; "waiting for database" retries are acceptable without it as long as the process stays alive.

## 12. PR checklist

- Branch `feat/add-bwapp`; commit and PR title `feat(bwapp): add new container`; target `main`.
- Fill the PR template; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything (zip name, checksum, build, install routine, read-only run, arm64); list the licence concern explicitly.
