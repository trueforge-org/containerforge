# humhub — implementation plan
> Source: ./draft.md · Target: apps/humhub/ · Difficulty: hard · Role: sidecar (nginx frontend; the PHP-FPM half is a separate container) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest upstream release | HumHub `v1.19.4`, published 2026-11-09 (https://api.github.com/repos/humhub/humhub/releases/latest). Tag `v1.17.2` exists on humhub/humhub. |
| Draft image | `ghcr.io/mriedmann/humhub-nginx:1.17.2`. Git tag `1.17.2` was NOT found on mriedmann/humhub-docker (refs API 404). Latest git tag there is `1.16.2` (published 2025-03-27). The GHCR tag cannot be checked from here: UNVERIFIED. |
| Plan version to build | HumHub `v1.19.4` (latest release). The draft's image is HumHub `1.17.2`, so the plan does not reuse it. |
| Renovate | `datasource=github-releases depName=humhub/humhub versioning=semver` |
| License | HumHub repo reports `NOASSERTION` on GitHub, so the SPDX id is UNVERIFIED (the project is described as AGPL-3.0; confirm on the LICENSE file before setting `LICENSE`). The upstream image repo mriedmann/humhub-docker is MIT (GitHub API). |
| Source URL | https://github.com/humhub/humhub |
| Download | `https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz` (the tarball is a source archive, not a prebuilt release). |
| Checksum source | None. Upstream `Dockerfile` uses `ADD <url>` with no checksum. The plan adds `sha256sum -c` against a hash recorded from the tag at port time; UNVERIFIED that the hash is published upstream. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile: builder `alpine:3.19.4` runs `composer install --no-dev` and `grunt build-assets`; `humhub_nginx` stage `FROM docker.io/library/nginx:1.27.2-alpine`; `ENTRYPOINT ["/docker-entrypoint.sh"]`; no `USER` line; `VOLUME /var/www/localhost/htdocs/uploads`, `.../protected/config`, `.../protected/modules`; `EXPOSE 9000` (phponly) and `EXPOSE 80` (allinone). The nginx variant has no EXPOSE line in the reviewed summary (UNVERIFIED). |
| Architectures | Upstream nginx image is alpine (musl), so `copy-from` is `no` per draft rules. amd64 and arm64: best judgement, the HumHub source is arch-independent; nginx from ubuntu apt is multi-arch. |
| Port | Upstream nginx listens on 80 in the all-in-one variant. ContainerForge nginx sibling listens on 8080 (`apps/nginx/Dockerfile`), so this plan uses 8080. |
| Env vars (upstream, PHP side) | `PHP_POST_MAX_SIZE=16M`, `PHP_UPLOAD_MAX_FILESIZE=10M`, `PHP_MAX_EXECUTION_TIME=60`, `PHP_MEMORY_LIMIT=1G`, `PHP_TIMEZONE=UTC`. Nginx side: `NGINX_CLIENT_MAX_BODY_SIZE=10m`, `NGINX_KEEPALIVE_TIMEOUT=65`, `NGINX_UPSTREAM=humhub:9000`. |
| Data paths | Upstream VOLUME: `/var/www/localhost/htdocs/uploads`, `/var/www/localhost/htdocs/protected/config`, `/var/www/localhost/htdocs/protected/modules`. The draft's `/assets` and `/themes` are not confirmed as VOLUMEs. |
| Dependencies | PHP-FPM companion (humhub-phponly on port 9000) and a database. The database type is not fixed by the Dockerfile: UNVERIFIED for the exact engine. |

## 2. Target layout

- `apps/humhub/Dockerfile`
- `apps/humhub/docker-bake.hcl`
- `apps/humhub/settings.yaml`
- `apps/humhub/container-test.yaml`
- `apps/humhub/start.sh`
- `apps/humhub/etc/nginx/` (only the server block and the upstream pointing at the PHP-FPM companion; reason: the sibling `apps/nginx` serves its config from `/config/nginx.conf`, so check that path first)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The PHP-FPM half is NOT part of this folder; see section 10.

## 3. Base image

Final stage: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. Fits because the role is a static-asset frontend and ContainerForge already has a nginx base. Closest sibling: `apps/nginx` (nginx on ubuntu, `USER apps`, writable temp dirs under `/tmp`).

Build stage (only if assets must be built, see section 4): `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, which provides composer and node packages through apt.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `USER root`.
2. Install build tools from apt: `composer`, `nodejs`, `npm`, PHP CLI and the extensions HumHub's `composer.json` needs (PHP 8.2+; ubuntu 26.04 provides `php8.5`, as `apps/bookstack` uses). Exact extension list: UNVERIFIED against HumHub's `composer.json`.
3. Download and verify:
   ```dockerfile
   RUN curl -fL -o /tmp/humhub.tar.gz "https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz" && \
       echo "<sha256>  /tmp/humhub.tar.gz" | sha256sum -c - && \
       tar xzf /tmp/humhub.tar.gz -C /tmp --strip-components=1 ...
   ```
   The `<sha256>` value must be computed from the tag at port time, because upstream does not publish one. Mark it in the Dockerfile comment as recorded from the tag (UNVERIFIED publication).
4. In the build stage: `composer install --no-dev --optimize-autoloader -d /tmp/humhub`, then `npm ci` and `npx grunt build-assets` (upstream builder runs `grunt build-assets`), then delete `node_modules`. Caches go to `/tmp` (`COMPOSER_HOME=/tmp/composer`, `npm_config_cache=/tmp/npm`).
5. Final stage `FROM <nginx base>`, `USER root`: copy only the static assets and the built `protected/` tree from `build` into `/app/humhub/`. Do not copy the PHP runtime. Remove any PHP-only files.
6. `ln -s /config/uploads /app/humhub/protected/uploads` and the same for `protected/config` and `protected/modules` (the remap is in section 9). `chown -R apps:apps /app/humhub` and `chmod -R 755 /app/humhub`.
7. License: copy the upstream LICENSE into `/usr/share/licenses/humhub/` (path confirmed from the tarball root; exact filename UNVERIFIED).
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app/humhub`.

Do NOT install PHP-FPM in this image (the frontend is nginx only). Do NOT copy the mriedmann `humhub-nginx` image: it is alpine (musl) and HumHub `1.17.2`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "humhub"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=humhub/humhub versioning=semver
  default = "1.19.4"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/humhub/humhub"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`LICENSE` is a best judgement pending the UNVERIFIED SPDX check in section 1; confirm before commit. `ARG VERSION` in the Dockerfile must be `1.19.4` (no `v` prefix; the tarball URL adds it). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/humhub/humhub"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: NGINX_CLIENT_MAX_BODY_SIZE
    default: "10m"
    required: false
  - name: NGINX_KEEPALIVE_TIMEOUT
    default: "65"
    required: false
  - name: NGINX_UPSTREAM
    default: "humhub:9000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
    required: false
```

The database dependency is shown as `mariadb` (`apps/mariadb` exists; `apps/postgresql` also exists) only as a placeholder because the Dockerfile does not fix the engine: UNVERIFIED which engine HumHub supports. Replace it with the real engine before commit, or drop the entry. `NGINX_UPSTREAM` must match the PHP-FPM companion's service name (section 10). Do not list `PHP_*` vars here: they belong to the PHP-FPM container.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/uploads /config/config /config/modules /tmp/nginx-temp /tmp/nginx-cache

sed -i "s|humhub:9000|${NGINX_UPSTREAM:-humhub:9000}|" /etc/nginx/conf.d/humhub.conf 2>/dev/null || true

echo "Starting HumHub nginx frontend on 8080"
exec nginx -c /config/nginx.conf -g "daemon off;"
```

- Idempotent: only creates directories; no seeding of `/config/config` unless HumHub's first-run setup requires it (UNVERIFIED).
- No writes to `/app`. Temp goes to `/tmp`.
- The `sed` edit writes under `/etc` at runtime, which is NOT writable with a read-only rootfs. Replace it: render the upstream into `/tmp/nginx.conf` with `envsubst` and run nginx with `-c /tmp/nginx.conf`. Use that instead of editing `/etc` (the `sed` line above is a placeholder, not final).
- `exec` nginx so signals reach it (PID 1 handoff through the base's init).

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
- /app/humhub/protected/yii
- /app/humhub/index.php
- /usr/share/licenses/humhub/
```

Port 8080 has a tcp and an http probe. The nginx frontend serves static assets only; a `/` request may return 404 or a redirect when no PHP-FPM is present. Confirm the HTTP status against a real run and choose a path that serves a static asset (for example a file from `static/`) rather than `/` (UNVERIFIED). Do not weaken the probe to make it pass.

Because the app is a sidecar that depends on PHP-FPM and a database (protocol criterion "hard dependency on a database"): the database-dependency exception may apply to the health assertions only if all three criteria hold. Document the narrowing in a comment if used: `# narrowed: requires external php-fpm and database; full functional test not feasible in single-container suite`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/localhost/htdocs/uploads` (VOLUME) | `/app/humhub/protected/uploads` -> `/config/uploads` (symlink made at build time) |
| `/var/www/localhost/htdocs/protected/config` (VOLUME) | `/app/humhub/protected/config` -> `/config/config` |
| `/var/www/localhost/htdocs/protected/modules` (VOLUME) | `/app/humhub/protected/modules` -> `/config/modules` |
| nginx temp and cache (`/var/lib/nginx`, `/var/cache/nginx`) | `/tmp/nginx-temp`, `/tmp/nginx-cache` (as used by `apps/nginx`) |
| Draft `/assets`, `/themes` | Not confirmed as writes; left unmapped until a run shows a write (UNVERIFIED) |

Draft expectations reconciled: the chart runs as UID 0 and `readOnlyRootFilesystem false`. This image runs as `apps` and is compatible with `--read-only --tmpfs /tmp`, which is stricter. Existing chart users mount their `/var/www/...` PVCs; they must copy the data to the new `/config` layout.

## 10. Risks, caveats and open questions

- **Design blocker (needs a decision from the user):** this nginx frontend cannot serve HumHub alone. The PHP-FPM half (upstream `humhub-phponly`, port 9000) is not a ContainerForge app. Options: (a) build a PHP-FPM app as a second container (`apps/humhub-phponly`) on the ubuntu base with `php8.5` (sibling pattern: `apps/bookstack`), then point `NGINX_UPSTREAM` at it; (b) ship a single all-in-one `humhub` app. The brief allows one image per folder, so (a) is the default plan. Choose before implementation.
- Version mismatch: nginx and PHP-FPM must be the same HumHub version (draft caveat, plausible; UNVERIFIED exact rule). Pin both to `VERSION`.
- The draft's image `1.17.2` is not reproducible from the tag check; this plan uses `1.19.4`, so HumHub's own migrations apply on first start (UNVERIFIED for the upgrade path from an existing 1.17 database).
- Asset build needs node and composer during the build stage: long build and large cache. Accept or drop the build stage if HumHub publishes built assets (UNVERIFIED).
- Upload, config and theme paths must be mounted the same way in both containers or the halves disagree (draft caveat, plausible; section 9 remap must match the PHP-FPM app).
- The `sed` placeholder in `start.sh` (section 7) writes under `/etc`; replace before testing with `--read-only`.
- Difficulty stays `hard`: two containers, unpinned SPDX, no published checksum, read-only rework.

## 11. Build and test steps

```sh
cd apps/humhub
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name humhub-probe --read-only --tmpfs /tmp \
  -v humhub-probe-config:/config humhub:1.19.4
docker logs -f humhub-probe
forgetool containers test --image humhub:1.19.4 --config ./apps/humhub/container-test.yaml
docker rm -f humhub-probe; docker volume rm humhub-probe-config
```

Expected readiness signal: nginx logs `start worker process` and no `[emerg]` line, and port 8080 accepts connections. Upstream fetch alone does not prove the app works: a full check needs the PHP-FPM companion and a database, which this single-container run cannot provide (narrowed test, section 8). Run once more with the same `/config` volume to confirm restart keeps uploads. arm64: build only when the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-humhub`, commit and PR title `feat(humhub): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the PHP-FPM half (not in this PR unless the user chooses option (a)), the database connection, the upgrade from 1.17 databases, the arm64 build, and the `/` HTTP status code until a run confirms it.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; the SHA-256 check is recorded; narrowed tests are commented.
