# humhub — implementation plan
> Source: ./draft.md · Target: apps/humhub/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft image `ghcr.io/mriedmann/humhub-phponly:1.17.2` wraps upstream `v1.17.2` (released 2025-04-07). Latest stable upstream is `v1.19.4` (published 2026-11-09). Plan targets `v1.19.4`, subject to the PHP requirement check in section 10. Sources: https://api.github.com/repos/humhub/humhub/releases/tags/v1.17.2 and `releases/latest` (via `gh api`). |
| Renovate | `datasource=github-releases depName=humhub/humhub versioning=semver` (tags are `vX.Y.Z`; UNVERIFIED against repo renovate config) |
| License | GitHub API reports `NOASSERTION` (`Other`) for `humhub/humhub`. UNVERIFIED: the LICENSE file was not fetched. Read `LICENSE` at the pinned tag before setting `LICENSE` in bake. |
| Source URL | https://github.com/humhub/humhub |
| Binary | No release assets on `v1.17.2` or `v1.19.4`. The artifact is the source tarball `https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz`. It is PHP plus JS sources, so it is arch-neutral. |
| Checksum source | None published by upstream. Pin the tag and record the sha256 of the downloaded tarball as `ARG HUMHUB_SHA256` in the Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile. Alpine 3.19.4 (`apk`, not `apt`), `php82-*`, nginx 1.27.2-alpine for the nginx variant, builder stage runs composer `--no-dev --optimize-autoloader` and grunt, `ADD` of an unpinned `master` php-fpm healthcheck script, no `USER` (runs as root), `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["supervisord","-n","-c","/etc/supervisord.conf"]`. |
| Ports | 9000/tcp (php-fpm FastCGI, phponly). The nginx sibling listens on 80 in the upstream allinone build (`EXPOSE 80`). |
| Env vars the upstream image sets | `PHP_POST_MAX_SIZE=16M`, `PHP_UPLOAD_MAX_FILESIZE=10M`, `PHP_MAX_EXECUTION_TIME=60`, `PHP_MEMORY_LIMIT=1G`, `PHP_TIMEZONE=UTC`. Whether the upstream entrypoint applies these is UNVERIFIED (its `docker-entrypoint.sh` was not fetched). |
| Write paths (upstream VOLUME) | `/var/www/localhost/htdocs/uploads`, `/var/www/localhost/htdocs/protected/config`, `/var/www/localhost/htdocs/protected/modules`. The draft also lists `assets` and `themes`. |
| Database | External MariaDB or MySQL, set up through the browser installer (per draft; UNVERIFIED on a fetched page). |
| arm64 | UNVERIFIED: the upstream image manifest was not checked. The app is arch-neutral PHP and JS. |
| Dependencies | mariadb (hard, apps/mariadb exists), valkey (optional, apps/valkey exists), humhub-nginx (missing, see section 10) |

## 2. Target layout

- `apps/humhub/Dockerfile`
- `apps/humhub/docker-bake.hcl`
- `apps/humhub/settings.yaml`
- `apps/humhub/container-test.yaml`
- `apps/humhub/start.sh`
- `apps/humhub/defaults/` for the php-fpm pool and nginx site files, because `start.sh` seeds them into the image (reason: the upstream `base/` and `nginx/` overlays are copied with `COPY . /`). Use it only for the decided topology in section 10.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The ubuntu base carries apt, so PHP comes from the archive (`php8.5-*`), as in `apps/bookstack/Dockerfile`. Closest sibling: `apps/bookstack` (PHP app on ubuntu with a Composer install, runtime `/config` symlinks, `clear_env = no` for php-fpm).

Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` only if Node is needed for the grunt asset build. Node is in this base. UNVERIFIED whether the ubuntu base has a usable `nodejs`; the python-node base avoids that question.

## 4. Dockerfile

1. Build stage: `FROM <python-node> AS build`, `ARG VERSION`, `ARG HUMHUB_SHA256`, `USER root`.
2. Install `composer` and `php8.5-cli` plus the extensions used by build (`php8.5-xml`, `php8.5-curl`, `php8.5-gd`, `php8.5-intl`, `php8.5-mbstring`, `php8.5-zip`, `php8.5-mysql`). Pin nothing from apt, because the base release provides them. Check against upstream composer requirements at `VERSION` (UNVERIFIED).
3. `curl -fL -o /tmp/humhub.tar.gz https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz`, `echo "${HUMHUB_SHA256}  /tmp/humhub.tar.gz" | sha256sum -c -`, then extract to `/tmp/humhub-src` with `--strip-components=1`.
4. `cd /tmp/humhub-src && composer install --no-dev --optimize-autoloader`, then `npm ci && npx grunt` (asset build, mirrors the upstream builder stage). Remove `node_modules` afterward.
5. Final stage: `FROM <ubuntu> AS final`, `USER root`, apt install the php runtime: `php8.5-fpm php8.5-cli php8.5-mysql php8.5-gd php8.5-intl php8.5-curl php8.5-xml php8.5-mbstring php8.5-zip php8.5-imagick` (plus `imagemagick` if imagick is used). `clean apt lists`. Set `clear_env = no` in the php-fpm pool, as `apps/bookstack` does.
6. Copy the built tree: `COPY --from=build /tmp/humhub-src /app/humhub`. `ln -s /config/uploads /app/humhub/uploads`, `ln -s /config/protected-config /app/humhub/protected/config`, `ln -s /config/modules /app/humhub/protected/modules`, plus `assets`, `themes`, `protected/runtime`. Same pattern as `apps/bookstack` step "create symlinks".
7. `ENV PHP_POST_MAX_SIZE=16M PHP_UPLOAD_MAX_FILESIZE=10M PHP_MAX_EXECUTION_TIME=60 PHP_MEMORY_LIMIT=1G PHP_TIMEZONE=UTC` (mirrors upstream; start.sh applies them to `php.ini`, see section 7).
8. Clean `/tmp/*` and `$HOME/.cache`, `$HOME/.composer`.
9. Tail:

```dockerfile
EXPOSE 8080
VOLUME /config
USER apps
COPY --chmod=0755 . /
```

Use `apps` as the php-fpm and nginx user. Upstream runs everything as root, which is not allowed here; do not copy its `USER` absence.

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
  default = "AGPL-3.0-or-later" // UNVERIFIED: confirm against the LICENSE file at the pinned tag
}

variable "SOURCE" {
  default = "https://github.com/humhub/humhub"
}
```

Then the four standard targets and the `default` group copied from `apps/bookstack/docker-bake.hcl`. `ARG VERSION` in the Dockerfile must equal this default. Run `docker buildx bake --print` from `apps/humhub/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/humhub/humhub"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: PHP_POST_MAX_SIZE
    default: "16M"
    required: false
  - name: PHP_UPLOAD_MAX_FILESIZE
    default: "10M"
    required: false
  - name: PHP_MAX_EXECUTION_TIME
    default: "60"
    required: false
  - name: PHP_MEMORY_LIMIT
    default: "1G"
    required: false
  - name: PHP_TIMEZONE
    default: "UTC"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mariadb
opt_dependencies:
  - valkey
```

Port 8080 assumes the single-container topology in section 10. If the two-container topology is chosen instead, the port is 9000 (php-fpm), and the list is `humhub-nginx` plus 9000 for FastCGI. The DB env vars (host, name, user, password) are entered in the browser installer, so they are not listed (UNVERIFIED; do not invent them).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/uploads /config/protected-config /config/modules /config/assets /config/themes /config/runtime /tmp/php-sessions

# apply PHP settings from env on every start
sed -i "s|^;\?post_max_size.*|post_max_size = ${PHP_POST_MAX_SIZE:-16M}|" /etc/php/8.5/fpm/php.ini
sed -i "s|^;\?upload_max_filesize.*|upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE:-10M}|" /etc/php/8.5/fpm/php.ini
sed -i "s|^;\?max_execution_time.*|max_execution_time = ${PHP_MAX_EXECUTION_TIME:-60}|" /etc/php/8.5/fpm/php.ini
sed -i "s|^;\?memory_limit.*|memory_limit = ${PHP_MEMORY_LIMIT:-1G}|" /etc/php/8.5/fpm/php.ini
sed -i "s|^;\?date.timezone.*|date.timezone = ${PHP_TIMEZONE:-UTC}|" /etc/php/8.5/fpm/php.ini

exec php-fpm8.5 -F
```

Notes: idempotent; writes only to `/config` and `/tmp`, never `/app`. The `sed` writes target `/etc/php`, which is not read-only at runtime only if the image is built that way; with `--read-only`, php.ini changes must be made at build time or passed as `-d` flags to php-fpm instead (preferred: `exec php-fpm8.5 -F -d "memory_limit=${PHP_MEMORY_LIMIT:-1G}" ...`). Choose one approach and record it in the PR. php-fpm is the process that `exec` replaces the shell with, so signals propagate.

Do not seed `protected/config/common.php`. HumHub creates it through the browser installer, so an empty `/config` stays valid.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/humhub/index.php
- /app/humhub/protected/vendor/autoload.php
- /etc/php/8.5/fpm/php-fpm.conf
```

The HTTP check on `/` returns the HumHub installer redirect on a fresh `/config`. Confirm the status code in the run and use the path that returns 200 or 302 as the probe. The DB is needed for a full install, so this is a DB-dependency narrowing: add the comment `# narrowed: requires external mariadb; full functional test not feasible in single-container suite` near the probes, per the build-test protocol. The `valkey` optional dependency is not required, so it does not narrow the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `protected/config` (VOLUME) | `/app/humhub/protected/config` -> `/config/protected-config` symlink |
| `protected/modules` (VOLUME) | `/config/modules` symlink |
| `uploads`, `assets`, `themes` | `/config/uploads`, `/config/assets`, `/config/themes` symlinks |
| `protected/runtime` (logs, cache) | `/config/runtime` symlink |
| php-fpm session and socket | `/tmp/php-sessions` and `/tmp` |
| php-fpm pool `user` | `apps`, not `www-data`; set in the pool file in `defaults/` |

The draft expected `runAsUser 0`, `readOnlyRootFilesystem false`, and `privileged false`. This plan runs as `apps` (non-root), so the expectation changes. It can run `--read-only --tmpfs /tmp` only if every write path above is remapped (verify in section 11).

## 10. Risks, caveats and open questions

- Topology decision (blocker for section 6): the draft has two images (`humhub` php-fpm and `humhub-nginx`), and `humhub-nginx` is missing from ContainerForge (❌). Option A (recommended for a first pass): one container running php-fpm plus nginx under `supervisord` from the ubuntu base, port 8080. Option B: php-fpm only on 9000, plus a separate `humhub-nginx` app first. Ask the user before choosing; Option A changes the start script.
- Version: the draft pins 1.17.2, the plan targets 1.19.4. HumHub's PHP minimum for 1.19 is UNVERIFIED; confirm it is met by `php8.5` on ubuntu 26.04 before pinning.
- License: the upstream API reports NOASSERTION, so the license string in bake is UNVERIFIED until the LICENSE file is read.
- Upstream health script: the upstream `ADD` of an unpinned `master` script must not be copied. Use the http probe in `container-test.yaml` instead.
- Upstream runs as root with no `USER`. The ContainerForge build runs as `apps`.
- arm64: UNVERIFIED.

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

Expected readiness signal: php-fpm logs `fpm is running` (or `ready to handle connections`), the process stays alive, and no `ERROR` lines. Restart the container with the same volume and confirm `/config` content is kept.

## 12. PR checklist

- Branch `feat/add-humhub`, commit and PR title `feat(humhub): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the PHP 8.5 build and run, the topology decision, the read-only run, DB install flow, arm64, and the license string.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
