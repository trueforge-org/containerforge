# organizr — implementation plan
> Source: ./draft.md · Target: apps/organizr/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | Tag `1.90` (release text date "26 Feb", year not shown) | https://github.com/causefx/Organizr/releases/latest |
| Release assets | UNVERIFIED: the page says "Assets 2" but names are not listed. The source archive `https://github.com/causefx/Organizr/archive/refs/tags/1.90.tar.gz` is the expected asset but was not fetched | same page |
| Renovate (proposed) | `datasource=github-releases depName=causefx/Organizr versioning=loose` (tag `1.90` is not strict semver with a patch number; use loose per the bake rules; the full tag pattern is UNVERIFIED) | release page |
| License (SPDX) | UNVERIFIED: not shown on the release page; repo LICENSE not fetched | same |
| Checksums | UNVERIFIED: none found | — |
| Upstream image Dockerfile | Reviewed at commit 53b8b05 of https://github.com/Organizr/docker-organizr | https://raw.githubusercontent.com/Organizr/docker-organizr/53b8b05/Dockerfile (fetch was via raw URL pinned to that commit) |
| Upstream FROM | `FROM ${BASE_IMAGE:-ghcr.io/organizr/base:2026-11-20_10}-${ARCH:-linux-amd64}`. `ARG BASE_IMAGE` and `ARG ARCH` have no defaults in the file. The base is an untraced wrapper | same |
| Upstream build steps | `COPY root/ /` only | same |
| Upstream LABEL / ENV | `maintainer="christronyxyocum,Roxedus"`; `ENV fpm="false" branch="v2-master"` | same |
| Upstream EXPOSE / VOLUME | `EXPOSE 80`; `VOLUME /config` | same |
| Upstream USER / ENTRYPOINT | not set in this file (inherited from the untraced base, UNVERIFIED) | same |
| PHP and nginx versions | UNVERIFIED: they come from the untraced `ghcr.io/organizr/base` image | — |
| Organizr env vars beyond `fpm` and `branch` | UNVERIFIED: docs.organizr.app was not fetched | — |
| Ports | 80 (HTTP, web UI). The draft's 9000/tcp for php-fpm is an inference and UNVERIFIED | Dockerfile |
| Data path | `/config` (VOLUME). Exact file layout under `/config` UNVERIFIED | Dockerfile |
| Dependencies | none | draft |

The upstream image is PHP source, so there is no compile step. The `fpm` variable in the upstream image suggests a php-fpm mode switch, but its meaning is UNVERIFIED.

## 2. Target layout

- `apps/organizr/Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `etc/`: needed for the nginx and php-fpm config that runs from `/tmp`-safe paths. Reason: config is baked into the image, and `etc/` is on the allow-list.
- `defaults/`: needed only if a first-run seed of the Organizr config into `/config` is used (see section 7). Reason: seed only when missing.
- `root/`: never used.
- `DOWNSTREAM_CHANGES.md`: not applicable.

Sibling patterns: `apps/nginx` (web server config, `docker-entrypoint.d`, `defaults/`) and `apps/bookstack` (PHP stack on ubuntu). Use bookstack as the PHP reference for the apt-installed php packages and the php-fpm process model.

## 3. Base image

Choice to make before coding (see section 10):
- Option A (recommended): `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, with php-fpm and nginx installed via apt. Reason: the upstream runtime is untraced, so the versions must be set by us. The ubuntu base is the default for PHP apps (see bookstack).
- Option B: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`, adding php-fpm via apt. Reason: nginx is already provided. Check that php-fpm installs on top of this base without a new process model.

Either way, do not copy the untraced `ghcr.io/organizr/base` image; the plan does not reuse it.

## 4. Dockerfile

Steps (Option A):
1. `ARG VERSION=1.90` (must equal the bake default). Keep the version as a plain string, since the tag is not semver.
2. `USER root` for installs: `php-fpm`, `php-curl`, `php-xml`, `php-mbstring`, `php-sqlite3`, `nginx` (apt, `--no-install-recommends`). The package versions are UNVERIFIED for ubuntu 26.04: check `apt-cache policy` at build time, then pin them as the Dockerfile rules require, and check the result against `VERSION`.
3. Download the Organizr 1.90 source archive from the tag. Verify the checksum (UNVERIFIED, none exists; if there is no upstream checksum, record that and rely on the HTTPS source). Extract to `/app/organizr/`, not to `/app/` root.
4. Ship the license to `/usr/share/licenses/organizr/` once confirmed.
5. Move every write path off `/app`. Organizr writes its config, its database (sqlite) and its logs. These paths are UNVERIFIED and must be found in the source tree at build time (grep for writes in `/app/organizr`). Each one must point to `/config` through a symlink created in `start.sh`, or through the Organizr config option if one exists.
6. `ENV HOME=/tmp`, and PHP session path `/tmp/php-sessions` (created at build time, owned by `apps`).
7. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, final `USER apps`.

Note on the port: nginx must listen on 80 as a non-root user. Ports below 1024 need `net.ipv4.ip_unprivileged_port_start` or a higher port. Use 8080 internally (repo rule: no bind below 1024 as non-root) and document the choice in settings.yaml; the upstream image's `EXPOSE 80` is therefore not carried over.

## 5. docker-bake.hcl

- `APP = "organizr"`.
- `VERSION` with `// renovate: datasource=github-releases depName=causefx/Organizr versioning=loose` and `default = "1.90"`.
- `LICENSE`: BLOCKED until confirmed. Do not guess.
- `SOURCE = "https://github.com/causefx/Organizr"`.
- Standard targets as in the sibling apps (`docker-metadata-action`, `image`, `image-local`, `image-all` for amd64 and arm64, `group "default"`).
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header and `schema_version: 1`; `upstream_env_url: https://github.com/causefx/Organizr`.
- `ports`: `protocol: tcp`, `required: true`. The repo rule forbids binding below 1024 as non-root, so use 8080 (not 80) for nginx unless `ip_unprivileged_port_start` is confirmed, and keep the port consistent in the Dockerfile `EXPOSE`, `start.sh`, settings and container-test.
- `env`: only variables `start.sh` reads. The upstream `fpm` and `branch` variables are upstream image variables. Do not list them unless the app itself reads them (UNVERIFIED).
- `volumes`: `/config`.
- `dependencies`: none.

## 7. start.sh

- Idempotent. If `/config` is empty, seed the default Organizr config file from `defaults/` (or the upstream default, UNVERIFIED) only when it is missing. Never overwrite an existing config.
- Create the symlinks from `/app/organizr` writable paths (config, sqlite database, logs) to `/config/...`, only when they are missing.
- Start php-fpm listening on a unix socket in `/tmp` (for example `/tmp/php-fpm.sock`), then start nginx in the foreground. Two processes: nginx is the long-running process and `exec`s last; php-fpm is started in the background with its own pid file in `/tmp`. Note that the process model needs a supervisor or a clear reason if php-fpm dies (UNVERIFIED need).
- Bind nginx to `0.0.0.0` on the chosen port.
- Read env vars defined in settings.yaml only.

## 8. container-test.yaml

- Forgetool schema header.
- `tcp` probe on the web port, and `http` probe on `/`.
- `timeoutSeconds` from `apps/bookstack` or `apps/nginx`.
- `filePaths`: `/app/organizr/` (source present), `/config` (seeded config, when the config path is known).
- No DB dependency, so no narrowing exception applies.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (chart `runAsUser 0`). Target: `USER apps`. php-fpm and nginx must not run as root: set `user` and `group` to `apps` in their configs, or use the non-root php-fpm pool config that ubuntu already provides (UNVERIFIED for the 26.04 package layout).
- Read-only rootfs: nginx temp paths (`client_body_temp_path`, `proxy_temp_path`, `fastcgi_temp_path`, `uwsgi_temp_path`, `scgi_temp_path`) and the pid file (`pid /tmp/nginx.pid`) must point to `/tmp`. Check the nginx config inside `etc/`.
- php-fpm: pid file, error log and the socket must be in `/tmp`. Session path set to `/tmp/php-sessions`.
- `--read-only --tmpfs /tmp` must be enough for every runtime write except `/config`.
- Draft security expectations: `runAsNonRoot false`, `readOnlyRootFilesystem false`, no privileged mode. Target: non-root, read-only rootfs, no privileged mode.

## 10. Risks, caveats and open questions

- Blocker, base image: the upstream runtime is the untraced `ghcr.io/organizr/base`. Its PHP and nginx versions are unknown. Option A (ubuntu + apt) builds a new runtime, which is a design decision that needs review.
- Two processes: nginx and php-fpm must both run. This adds process-supervision work. This is the main reason for the hard rating.
- Writable paths: Organizr's writes to `/app` are not traced. Until a build-time grep is done, the config, database and log paths are UNVERIFIED.
- Upstream activity: the draft flags that the project may be slow-moving; this was not checked. Check the repo's latest commit date before starting, since the latest release is 1.90 (date year not shown).
- Ports: nginx on port 80 as a non-root user needs a non-privileged port (see section 4). Choose and document.
- License and asset names: UNVERIFIED.
- Admin account setup happens in the web UI after first start (manual step, per the draft; not verified here).
- arm64: the apt PHP packages and the source are arch-neutral, but arm64 is not validated. Plan is amd64 first.

## 11. Build and test steps

1. `cd apps/organizr && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run on an empty `/config` volume with `--read-only --tmpfs /tmp`:
   ```sh
   docker volume create organizr-probe-config
   docker run --rm -d --name organizr-probe --read-only --tmpfs /tmp \
     -v organizr-probe-config:/config organizr:1.90
   docker logs -f organizr-probe
   ```
   Expected readiness signal: nginx logs that it is listening on the chosen port, and php-fpm reports ready. No PHP fatal errors.
4. `forgetool containers test --image organizr:1.90 --config ./apps/organizr/container-test.yaml`, or check the probes by hand if forgetool is not available.
5. Clean up: `docker rm -f organizr-probe; docker volume rm organizr-probe-config`.

## 12. PR checklist

- Branch `feat/add-organizr`, commit `feat(organizr): add new container`, target `main`.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Say what was not tested: the untraced upstream base, arm64, the UNVERIFIED license and asset checksums, and the first-run admin setup.
- Do not check "Built container locally" unless the image was built and run.
