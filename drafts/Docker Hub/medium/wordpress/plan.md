# wordpress — implementation plan
> Source: ./draft.md · Target: apps/wordpress/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 7.1.5 (https://api.wordpress.org/core/version-check/1.7/, fields `current` and `version`). The draft's tag is `latest`; pin 7.1.5. |
| Renovate | UNVERIFIED: datasource and depName not confirmed. Suggest `datasource=github-tags depName=WordPress/WordPress versioning=loose` (tag format not checked; confirm in step 4). |
| License | GPL-2.0-or-later (WordPress core). GitHub API reports `NOASSERTION` (https://github.com/WordPress/WordPress), so the SPDX id is UNVERIFIED for the bake `LICENSE`; confirm from `license.txt` in the tarball. |
| Source URL | https://github.com/WordPress/WordPress |
| Download | `https://downloads.wordpress.org/release/wordpress-7.1.5.zip` (HTTP 200, `application/zip`, 37245999 bytes). The draft's `https://wordpress.org/latest.tar.gz` is not what was checked; use the versioned zip. Arch-neutral PHP. |
| Checksum source | `https://downloads.wordpress.org/release/wordpress-7.1.5.zip.sha1` (HTTP 200). The file holds a bare SHA-1 (`d7d004a092a4e8f2b28dc8f4089a11fea9a38807`, read 2026-11-25, no filename). The version-check JSON has no MD5. Verify with `sha1sum -c` in the Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bitnami/containers/9da424411c57f30d7bdc8409eabcce6e5709c9f3/bitnami/wordpress/7/debian-12/Dockerfile. Bitnami build on `bitnami/minideb:bookworm`, Stacksmith components (apache 2.4.71, php 8.4.28, wordpress 7.1.5-1), sha256-verified. EXPOSE 8080, 8443; USER 1001; ENTRYPOINT `/opt/bitnami/scripts/wordpress/entrypoint.sh`; CMD `/opt/bitnami/scripts/apache/run.sh`. No VOLUME. |
| Ports | 8080 (HTTP), 8443 (HTTPS). Upstream confirms both; the draft's 8080 is kept. |
| Env vars | Upstream Bitnami ENV is not reusable (it is Bitnami-specific: `APP_VERSION`, `BITNAMI_APP_NAME`, `OS_*`). ContainerForge reads its own names (see section 7). WordPress reads `WORDPRESS_*` only in Bitnami's scripts, which are not ported: UNVERIFIED which names ContainerForge should expose. |
| Data paths | Upstream: `/opt/bitnami` (group rwX), `/tmp/bitnami/pkg/cache`. The wp-content location and entrypoint config logic are in Bitnami scripts not fetched (UNVERIFIED). |
| Database | MariaDB sibling `apps/mariadb` exists (settings: `MARIADB_ROOT_PASSWORD` required, `MARIADB_USER`, `MARIADB_PASSWORD`, `MARIADB_DATABASE`, port 3306). MySQL sibling does not exist (`apps/mysql` absent). |

## 2. Target layout

- `apps/wordpress/Dockerfile`
- `apps/wordpress/docker-bake.hcl`
- `apps/wordpress/settings.yaml`
- `apps/wordpress/container-test.yaml`
- `apps/wordpress/start.sh` (writes Apache and wp-config on first run, see section 7)
- `apps/wordpress/defaults/` for the Apache vhost and `wp-config` template, only if they are not inline in start.sh. Reason: the template is larger than a heredoc is comfortable with.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, the ubuntu base alone (draft says no runtime image is needed). PHP comes from Ubuntu apt. Closest sibling: `apps/bookstack` (PHP on the ubuntu base, php8.5 packages from apt, `/config` symlinks, `USER apps`, `COPY --chmod=0755 . /`). Confirmed in that Dockerfile: `php8.5-*` packages install on ubuntu 26.04.

The Bitnami base is not used: it is Debian/minideb with its own stack, so ContainerForge would not match its layout.

## 4. Dockerfile

1. `FROM <ubuntu> ` with `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install, pinned to the archive for ubuntu 26.04 (check `apt-cache policy` in the build; do not guess versions):
   `apache2 libapache2-mod-php8.5 php8.5-mysql php8.5-gd php8.5-curl php8.5-xml php8.5-mbstring php8.5-zip php8.5-intl php8.5-imagick php8.5-opcache unzip`
   The draft's `php-*` names are inferred. Packages are confirmed only by the `bookstack` pattern (`php8.5-*`): `bookstack` uses no Apache at all, so `libapache2-mod-php8.5` and `php8.5-mbstring`, `php8.5-intl`, `php8.5-imagick` are UNVERIFIED for this archive. Check each in the build and drop any that do not exist.
3. Fetch and verify the release:
   ```sh
   curl -fL -o /tmp/wordpress.zip https://downloads.wordpress.org/release/wordpress-${VERSION}.zip
   curl -fL -o /tmp/wordpress.zip.sha1 https://downloads.wordpress.org/release/wordpress-${VERSION}.zip.sha1
   (cd /tmp && echo "$(cut -d' ' -f1 wordpress.zip.sha1)  wordpress.zip" | sha1sum -c -)
   unzip -q /tmp/wordpress.zip -d /tmp/src && mv /tmp/src/wordpress/* /app/www/
   ```
   The `.sha1` file holds a bare hash, so the `cut` above is a no-op and is safe.
4. Mirror bookstack: `mkdir -p /app/www`, move the WordPress core there, and symlink `wp-content` to `/config/wp-content`, which the draft requires. wp-content holds themes, plugins and uploads.
   `ln -s /config/wp-content /app/www/wp-content` after `rm -rf /app/www/wp-content` (the core ships one).
5. Apache: `a2dissite 000-default`, set `Listen 8080`, `ServerName localhost`, `DocumentRoot /app/www`, `PidFile /tmp/apache2.pid`, `ErrorLog /dev/stderr`, `CustomLog /dev/stdout`. Place the vhost in `etc/apache2/sites-available/wordpress.conf` if it is not inline (`etc/` is in the dockerignore allow-list).
6. Caches and scratch to `/tmp`: `ENV TMPDIR=/tmp`, `PHP_SESSION_SAVE_PATH=/tmp`. Clean apt lists and `/tmp/*` as bookstack does.
7. License: `COPY` `license.txt` from the tarball into `/usr/share/licenses/wordpress/LICENSE` (inside the same RUN as the download).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

`USER apps` means Apache binds 8080 without root (above 1024). Port 8443 is not exposed or configured (no TLS vhost, no probe); upstream's 8443 is dropped on purpose. The final `start.sh` runs `apache2 -DFOREGROUND` as `apps`, which needs the apache log, pid and lock dirs writable: move them to `/tmp` (see section 9).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wordpress" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=WordPress/WordPress versioning=loose
  default = "7.1.5"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }   // UNVERIFIED SPDX: confirm from license.txt
variable "SOURCE" { default = "https://github.com/WordPress/WordPress" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/WordPress/WordPress"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: WORDPRESS_DB_HOST
    default: "mariadb"
    required: true
  - name: WORDPRESS_DB_PORT
    default: "3306"
    required: false
  - name: WORDPRESS_DB_NAME
    default: "MYMARIADBDB"
    required: true
  - name: WORDPRESS_DB_USER
    default: "MYMARIADBUSER"
    required: true
  - name: WORDPRESS_DB_PASSWORD
    default: "MYMARIADBPASSWORD"
    required: true
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```

The `WORDPRESS_DB_*` names are a ContainerForge choice, not upstream names: the names must match what `start.sh` reads. The MariaDB defaults mirror `apps/mariadb` and `apps/bookstack`. The draft lists mariadb as the hard dependency (`✅`); `mysql` is not available in ContainerForge and is not listed.

## 7. start.sh

Idempotent, runs as `apps`, writes only under `/config` and `/tmp`:

1. `mkdir -p /config/wp-content` and seed `/config/wp-content` from the core default (`/app/www/wp-content` is the core copy, not used once symlinked: seed only when `/config/wp-content` is missing or empty).
2. Regenerate `/config/wp-config.php` on every start from `WORDPRESS_DB_*` (so password and host changes apply), escaping `'` and `\`, and reuse the salts from step 3.
3. Generate salts once and store them in `/config` (WordPress salts are per install).
4. The symlink `/app/www/wp-config.php` -> `/config/wp-config.php` is created at build time in the Dockerfile (dangling until start.sh writes the file), because `/app/www` is read-only at runtime.
5. `exec apache2 -DFOREGROUND -f /tmp/apache2.conf` (or the default config with the `PidFile` and `Listen` settings above).

Do not seed the setup wizard: WordPress finishes install in the browser on first visit (draft caveat, inferred; UNVERIFIED for this image).

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
- /app/www/index.php
- /app/www/wp-settings.php
- /usr/share/licenses/wordpress/LICENSE
```

The test runs with no env vars, so no DB is reachable and the install page or DB error is expected. Per the protocol's DB-dependent exception (`mariadb` is a hard dependency), this is narrowed: keep the tcp and http checks (the HTTP probe may get the DB error page with a non-200 status; confirm and, if needed, probe a 200 or 500 that proves PHP runs, with a comment `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| wp-content (themes, plugins, uploads) | `/config/wp-content` via symlink (the draft's remap). |
| `wp-config.php` | `/config/wp-config.php` via symlink, generated by start.sh on first run. |
| Apache PID, lock, log dirs | `PidFile /tmp/apache2.pid`, `Mutex file:/tmp`, logs to stdout/stderr. |
| PHP sessions, upload temp | `/tmp` via `session.save_path` and `upload_tmp_dir`. |
| Core and plugin self-update | Writes into `/app/www`, which is read-only at runtime. Disable with `define('AUTOMATIC_UPDATER_DISABLED', true);` in the generated config, and note the upgrade path in the PR (draft caveat, inferred). |

Reconciling the draft's security expectations: the chart's `runAsUser 0` and `runAsGroup 0` are overrides of the common defaults and are not needed; the image runs as `apps` and listens on 8080 (no root needed). `readOnlyRootFilesystem` is possible with the remaps above and `--read-only --tmpfs /tmp`. Not privileged. Extra persistence: `/bitnami/wordpress` in the chart maps to `/config` here, so remap rather than add a volume. Confidence stays medium until the read-only run succeeds.

## 10. Risks, caveats and open questions

- Core self-updates write to `/app/www` (read-only at runtime): disable the auto-updater and document upgrades (draft caveat).
- The browser setup wizard creates the site title and admin account; the container alone does not provide a working site (draft caveat, inferred).
- Bitnami's entrypoint logic (wp-config generation, DB wait, salt handling) is not ported; the ContainerForge `start.sh` must reproduce only what is needed (UNVERIFIED which parts).
- PHP and Apache package names for ubuntu 26.04 are UNVERIFIED beyond the bookstack `php8.5-*` pattern.
- Upstream WordPress core: GPL-2.0-or-later (UNVERIFIED SPDX id; GitHub says NOASSERTION).
- No blockers identified for arm64 (PHP and the zip are arch-neutral; confirm by bake `image-all` in step 11).

## 11. Build and test steps

```sh
cd apps/wordpress
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wordpress-probe --read-only --tmpfs /tmp \
  -v wordpress-probe-config:/config wordpress:7.1.5
docker logs -f wordpress-probe
forgetool containers test --image wordpress:7.1.5 --config ./apps/wordpress/container-test.yaml
docker rm -f wordpress-probe; docker volume rm wordpress-probe-config
```

Expected readiness signal: `apache2 -DFOREGROUND` keeps running with no `AH` error lines, and `curl http://localhost:8080/` returns a response from PHP. Full DB-backed readiness needs a real MariaDB (not in the single-container test); do this manually with `apps/mariadb` on the same network.

## 12. PR checklist

- Branch `feat/add-wordpress`, commit and PR title `feat(wordpress): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested (state honestly in the PR): PHP and Apache package names on the archive, the setup wizard, DB-backed start with mariadb, the read-only run, the auto-updater behaviour, and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; the DB narrowing is annotated; no assertion weakened.
