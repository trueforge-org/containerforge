# iyuuplus — implementation plan
> Source: ./draft.md · Target: apps/iyuuplus/ · Difficulty: medium on the draft, hard in practice until the blockers in section 10 are resolved · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no GitHub release or tag exists on https://github.com/ledccn/iyuuplus-dev (Releases empty). The only build input is the default branch (HEAD). Docker Hub `iyuucn/iyuuplus` has only the `latest` tag (last_updated 2026-11-20). The upstream Dockerfile labels say `Version 8.3.3`, `Release 20260112`, which are image labels, not a source pin. |
| Renovate | Proposed `datasource=git-refs depName=https://github.com/ledccn/iyuuplus-dev currentValue=master` (precedent: `apps/tvheadend`). The commit SHA to pin is UNVERIFIED: it was not fetched. |
| License | MIT (https://github.com/ledccn/iyuuplus-dev and https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/LICENSE) |
| Source URL | https://github.com/ledccn/iyuuplus-dev |
| Download | Only `https://github.com/ledccn/iyuuplus-dev/archive/HEAD.zip` (unpinned). No release assets. A commit-pinned archive `https://github.com/ledccn/iyuuplus-dev/archive/${VERSION}.tar.gz` is the proposed form (same as `apps/tvheadend`), but the commit is UNVERIFIED. |
| Checksum source | UNVERIFIED: none for a source archive. The pinned commit SHA is the content address. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/docker/Dockerfile. `FROM alpine:3.21` (not Debian or Ubuntu). Installs s6-overlay, PHP 8.3 with extensions, nginx, nginx-mod-http-headers-more, Composer, and mariadb with mariadb-client. Creates `/iyuu`. Optional apk mirror rewrite (`ARG package_url`). `COPY --chmod=755 ./rootfs /`. `ENTRYPOINT ["/init"]` (s6-overlay). No `CMD`. Runs as root. |
| Port | `EXPOSE 8780` (upstream). The draft's `8787` is inferred and conflicts with upstream. Use 8780 unless the app says otherwise (UNVERIFIED). |
| Env (real) | Upstream `ENV`: `LANG=C.UTF-8`, `TZ=Asia/Shanghai`, `S6_SERVICES_GRACETIME=30000`, `S6_KILL_GRACETIME=60000`, `S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0`, `S6_SYNC_DISKS=1`, `COMPOSER_ALLOW_SUPERUSER=1`, `APP_ENV=prod`, `IYUU_REPO_URL` (Gitee). Other app env vars are UNVERIFIED (the `rootfs` tree is not in the facts). |
| Data paths (upstream) | `VOLUME /iyuu` and `VOLUME /data`. The draft's `/IYUU/db` (chart config path) does not match upstream. |
| Runs as | root (no `USER`). |
| Services | Upstream s6 services and their `run` scripts are in `rootfs/`, not in the facts. UNVERIFIED: the exact process list and start commands for PHP, nginx and the app. |

## 2. Target layout

- `apps/iyuuplus/Dockerfile`
- `apps/iyuuplus/docker-bake.hcl`
- `apps/iyuuplus/settings.yaml`
- `apps/iyuuplus/container-test.yaml`
- `apps/iyuuplus/start.sh`
- `apps/iyuuplus/etc/` only if nginx or PHP configuration must be changed. Reason: `etc/` is on the `include/.dockerignore` allow-list, and it is copied to `/etc` by `COPY . /`. Use it for config files only.

Do not use `root/` (rule). No `DOWNSTREAM_CHANGES.md`, because iyuuplus is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the upstream image is PHP-based, and ContainerForge has no PHP base. The closest sibling is `apps/bookstack`, which installs PHP packages with apt on this base and uses `composer`. Upstream PHP is 8.3 on alpine. This base offers `php8.5` (as `apps/bookstack` uses). UNVERIFIED: whether iyuuplus runs on PHP 8.5, since upstream pins 8.3.

## 4. Dockerfile

Blocker first: upstream is an all-in-one image (PHP, nginx, MariaDB, s6). Choose the scope in section 10 before writing this file.

1. `ARG VERSION` (a commit SHA, equal to the bake value), then `USER root`.
2. Install the PHP runtime and Composer. Package names follow `apps/bookstack`. The exact extension list must match upstream and is UNVERIFIED:

```dockerfile
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      composer \
      php8.5-cli \
      php8.5-curl \
      php8.5-mbstring \
      php8.5-xml \
      php8.5-zip \
      php8.5-sqlite3 \
 && rm -rf /var/lib/apt/lists/*
```

   Apt packages are not pinned to `VERSION` (the toolchain, not the app). Pin them only if the app version depends on a PHP version (UNVERIFIED).
3. Fetch the source at the pinned commit and install PHP dependencies at build time:

```dockerfile
ENV COMPOSER_HOME=/tmp/composer COMPOSER_ALLOW_SUPERUSER=1
RUN mkdir -p /app/iyuuplus \
 && curl -fsSL "https://github.com/ledccn/iyuuplus-dev/archive/${VERSION}.tar.gz" \
      | tar xz -C /app/iyuuplus --strip-components=1 \
 && composer install --no-dev --optimize-autoloader -d /app/iyuuplus \
 && rm -rf /tmp/*
```

4. Remap upstream write paths (`/iyuu`, `/data`) to `/config` with build-time symlinks, so they resolve at runtime:

```dockerfile
RUN ln -s /config/iyuu /iyuu \
 && ln -s /config/data /data
```

   Do not create `/config/iyuu` here. `start.sh` creates it, so an empty `/config` still works.
5. License: `install -D /app/iyuuplus/LICENSE /usr/share/licenses/iyuuplus/LICENSE`. The LICENSE path inside the archive is UNVERIFIED: check that it exists.
6. Permissions: `chown -R root:root /app && chmod -R 755 /app`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8780
VOLUME /config
```

   Only the process that serves the web UI and the PHP app runs (see section 7).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "iyuuplus"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ledccn/iyuuplus-dev currentValue=master
  default = "UNVERIFIED-commit-sha-to-pin"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ledccn/iyuuplus-dev"
}
```

`VERSION` must be a real commit SHA before the first build, pinned like `apps/tvheadend`. The placeholder is not buildable. Use the four standard targets and the default group copied from `apps/tvheadend`. Check with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ledccn/iyuuplus-dev"
ports:
  - port: 8780
    protocol: tcp
    required: false
env:
  - name: APP_ENV
    default: "prod"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mariadb   # proposed, pending the decision in section 10; apps/mariadb exists (✅)
```

- `APP_ENV` default comes from upstream `ENV`. `TZ` default is ContainerForge's standard. Upstream uses `Asia/Shanghai`, which is a choice to revisit (UNVERIFIED impact).
- Remove the `dependencies` entry if the bundled-MariaDB option is chosen instead. Do not invent env vars: `IYUU_REPO_URL` is added only if `start.sh` or the app reads it (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/iyuu /config/data /tmp/nginx /tmp/php

cd /app/iyuuplus
exec <app start command>
```

- `<app start command>` is UNVERIFIED. Read the upstream `rootfs/` service `run` scripts and use the one foreground process. A single process is needed, because `exec` must run one long-lived process.
- With the bundled MariaDB option, a process supervisor would be needed. Do not add one. Use the `mariadb` dependency instead.
- No writes to `/app`. Runtime scratch (nginx pid and temp, PHP sessions) goes to `/tmp`.
- Idempotent: creating directories only. Seed nothing into `/config`. Read config from the env vars in `settings.yaml`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8780'
filePaths:
- /app/iyuuplus/composer.json
- /usr/share/licenses/iyuuplus/LICENSE
```

- Port 8780 has a `tcp` probe. An `http` probe is not added yet, because the response to `/` is UNVERIFIED. Add it once confirmed.
- `filePaths` use `composer.json` as a known file in the source tree (UNVERIFIED that it exists at the pinned commit).
- If the `mariadb` dependency is kept and the app needs a database to start, the DB-dependency narrowing rule applies only when all three of its conditions hold. Confirm that before narrowing. Add the required comment: `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/iyuu` (`VOLUME`) | Symlink `/iyuu` to `/config/iyuu`. Confirm the app reads `/iyuu` by that name (UNVERIFIED). |
| `/data` (`VOLUME`) | Symlink `/data` to `/config/data`. |
| Composer cache and home | `COMPOSER_HOME=/tmp/composer`, build time only. |
| nginx temp and pid, PHP sessions | `/tmp`. Confirm the nginx config in `etc/` points at `/tmp` (UNVERIFIED). |
| `/app/iyuuplus` (source, `vendor/`) | Read-only at runtime. Built at build time. |

- Upstream runs as root. This image runs as `apps` (568). `/config` is owned by `apps`.
- Draft security expectations, reconciled: the chart forces `runAsUser 0` and sets `readOnlyRootFilesystem: false`. This image is compatible with `--read-only --tmpfs /tmp` and runs as non-root. Chart changes are out of scope.
- Extra persistence from the draft: `/IYUU/db` (chart config path, not upstream), `/torrents`, `/BT_backup` (PVCs). The upstream image declares none of these. Do not list them in `settings.yaml` unless the app reads them (UNVERIFIED). They are user data mounts, not `/config`.
- Not privileged. No extra security settings.

## 10. Risks, caveats and open questions

- Blocker, version: no tags or releases. Build from a pinned commit SHA (see section 5), with a renovate `git-refs` rule. This is the same pattern as `apps/tvheadend`, and it bumps on every `master` push.
- Blocker, scope: the upstream image is Alpine with s6-overlay, nginx, PHP 8.3 and MariaDB in one container. The draft's "apt php-cli on ubuntu" is a different stack. Decide before writing the Dockerfile:
  - Option A (recommended): depend on `apps/mariadb` (exists), and run only nginx/PHP/app processes. Needs the upstream service list (UNVERIFIED).
  - Option B: bundle MariaDB. Requires a process supervisor, which breaks the one-process model. Not recommended.
- Blocker, services: the exact process list and start commands come from upstream `rootfs/` (not fetched).
- Port: draft 8787 conflicts with upstream `EXPOSE 8780`. Use 8780 unless verified otherwise.
- Data paths: draft `/IYUU/db` conflicts with upstream `/iyuu` and `/data`. Use the upstream paths, remapped to `/config`.
- PHP version: upstream pins PHP 8.3 on alpine. This plan uses the ubuntu `php8.5` packages (UNVERIFIED that the app supports 8.5).
- Upstream `ENV TZ=Asia/Shanghai` is replaced by ContainerForge's `Etc/UTC` default in `settings.yaml`. Confirm this is acceptable.
- Account: pushing and downloader integration need an IYUU account or token from iyuu.cn (draft caveat).
- Composer packages are fetched at build time, so the build needs internet access (draft caveat).
- arm64: the Docker Hub image has amd64 and arm64. The source build is arch-neutral (PHP and Composer), but this build's arm64 is not tested.
- Blockers listed above: a pinned commit, the scope decision, and the upstream service commands.

## 11. Build and test steps

```sh
cd apps/iyuuplus
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name iyuuplus-probe --read-only --tmpfs /tmp \
  -v iyuuplus-probe-config:/config iyuuplus:<commit-sha>
docker logs -f iyuuplus-probe
forgetool containers test --image iyuuplus:<commit-sha> --config ./apps/iyuuplus/container-test.yaml
docker rm -f iyuuplus-probe; docker volume rm iyuuplus-probe-config
```

- Replace `<commit-sha>` with the pinned `VERSION`. The image tag is the bake `VERSION`.
- Expected readiness signal: UNVERIFIED until the upstream service commands are known (for example an nginx `start worker processes` line, or the app's own ready line).
- Confirm `/config/iyuu` and `/config/data` exist after the start, and that a restart keeps them.
- Check that the port answers from outside the container (`-p 8780:8780`).

## 12. PR checklist

- Branch `feat/add-iyuuplus`. Commit and PR title `feat(iyuuplus): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say in the PR what was not tested: the pinned commit, the service start commands, the PHP 8.5 choice, the `--read-only` run, the arm64 build, and the HTTP probe.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion was weakened.
