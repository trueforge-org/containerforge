# tasmoadmin — implementation plan
> Source: ./draft.md · Target: apps/tasmoadmin/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v5.0.0 (latest release per GitHub API, published 2026-03-09). Source: https://api.github.com/repos/TasmoAdmin/TasmoAdmin/releases/tags/v5.0.0 . Chart image `ghcr.io/tasmoadmin/tasmoadmin:v5.0.0` matches. |
| Renovate | `datasource=github-releases depName=TasmoAdmin/TasmoAdmin versioning=semver` (best judgement; no renovate config checked for this app). |
| License | GPL-3.0 (GitHub API `spdx_id`). Source: https://api.github.com/repos/TasmoAdmin/TasmoAdmin |
| Source URL | https://github.com/TasmoAdmin/TasmoAdmin |
| Download | `https://github.com/TasmoAdmin/TasmoAdmin/releases/download/v5.0.0/tasmoadmin_v5.0.0.tar.gz` (1946749 bytes). Also `tasmoadmin_v5.0.0.zip` (2753191 bytes). Architecture-independent PHP source, so one URL serves amd64 and arm64. |
| Checksum source | UNVERIFIED: none. No checksum asset and no digest in the release API. Plan: record the sha256 of the tarball in the Dockerfile at build time and check it on rebuild, but do not claim it is upstream-published. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/TasmoAdmin/TasmoAdmin/81271a076cacecb1e8d4e8723af35e61510276de/.docker/Dockerfile.alpine-tmpl : node:22.22.1-slim (npm ci, npm run build), composer:2.9.5 (`composer install --optimize-autoloader --no-dev`), final `amd64/alpine:3.23` with nginx, PHP 8.5 FPM, bash, curl, s6-overlay v3.1.6.2 (no checksum). `ENTRYPOINT ["/init"]`, no CMD, no USER (root), `VOLUME ["/data"]`, `EXPOSE 80 443`, `ENV SSL=false`, app at `/var/www/tasmoadmin`, HEALTHCHECK on 127.0.0.1. |
| Ports | 80 and 443 (upstream EXPOSE). Draft's `80/http` is confirmed for the container side. |
| Env vars | Only `SSL` (default `false`) is confirmed, from the Dockerfile. UNVERIFIED: any other runtime env var, since the s6 rootfs scripts were not fetched. |
| Data write path | Upstream declares `/data`. UNVERIFIED: how TasmoAdmin's PHP code picks its data directory (device list and credentials). Needs a check of the app source before the remap in section 9. |
| arm64 | UNVERIFIED: the GHCR image platforms were not checked. The tarball itself is arch-independent. |
| copy-from | Not applicable. The upstream image is Alpine/musl, so `COPY --from` is not an option. |

## 2. Target layout

- `apps/tasmoadmin/Dockerfile`
- `apps/tasmoadmin/docker-bake.hcl`
- `apps/tasmoadmin/settings.yaml`
- `apps/tasmoadmin/container-test.yaml`
- `apps/tasmoadmin/start.sh`
- `apps/tasmoadmin/defaults/` for the nginx and php-fpm config templates, only if the templates are not written in the Dockerfile. Reason: start.sh must render them into `/tmp` at each start (nginx and php-fpm cannot write into `/etc` on a read-only rootfs run as non-root).
- No `root/` (reserved). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the app is PHP source served by a web server, and no ContainerForge PHP base exists in the table. The `nginx` base is an alternative, but it adds a pinned nginx version the draft does not need. The brief lists `apps/bookstack` as the PHP stack sibling; read its Dockerfile and reuse its PHP apt install pattern. UNVERIFIED: that PHP 8.x packages (`php-fpm`, `php-xml`, `php-mbstring`, `php-curl`) exist in the Ubuntu 26.04 archive under the names in the draft; check with `apt-cache policy` in the build before pinning.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install `nginx` and PHP-FPM with the CLI extensions the app needs, using `--no-install-recommends`, then `rm -rf /var/lib/apt/lists/*`. Nothing from the base is re-installed. Pin the PHP packages against the sibling's version approach, and only after verifying the names (see section 3).
3. Download the release tarball:
   `curl -fsSL -o /tmp/tasmoadmin.tar.gz "https://github.com/TasmoAdmin/TasmoAdmin/releases/download/v${VERSION}/tasmoadmin_v${VERSION}.tar.gz"`
   Then `sha256sum -c` against a value recorded in the Dockerfile (see section 1 checksum note). Extract to `/var/www/tasmoadmin`.
4. Run `composer install --no-dev --optimize-autoloader` only if the release tarball does not already contain `vendor/`. UNVERIFIED: whether the tarball ships `vendor/`. If it does not, composer is needed in a build stage, not the final stage.
5. `chown -R apps:apps /var/www/tasmoadmin && chmod -R 755 /var/www/tasmoadmin`, and do not write to it at runtime.
6. License: `/usr/share/licenses/tasmoadmin/LICENSE` from the tarball, since upstream ships it.
7. Set `ENV HOME=/config` as the sibling `adguardhome-sync` does, and keep caches in `/tmp`.
8. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080` (see section 9 for the port choice), `VOLUME /config`, `ENTRYPOINT ["/start.sh"]` or `CMD`, following the sibling's convention.

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG VERSION
USER root
# apt install nginx + php-fpm + extensions, tarball download, sha256 check, extract to /var/www/tasmoadmin
USER apps
COPY --chmod=0755 . /
EXPOSE 8080
VOLUME /config
```

## 5. docker-bake.hcl

- `APP = "tasmoadmin"`, `LICENSE = "GPL-3.0"`, `SOURCE = "https://github.com/TasmoAdmin/TasmoAdmin"`.
- `VERSION` default `"5.0.0"` with the renovate line `// renovate: datasource=github-releases depName=TasmoAdmin/TasmoAdmin versioning=semver`. Dockerfile uses `v${VERSION}` in the download URL, so the bake default has no `v` prefix. Check the sibling for the convention and keep it consistent.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`.
- Validate with `docker buildx bake --print` in `apps/tasmoadmin`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/TasmoAdmin/TasmoAdmin"`.
- `ports`: `port: 8080`, `protocol: tcp`, `required: true` (the rootless port, see section 9). Upstream 80/443 is not kept unless the container runs as root, which is out of scope.
- `env`: only vars start.sh reads. Include `SSL` only if start.sh honours it; otherwise drop it, because `settings.yaml` must not list env vars the app does not read.
- `volumes`: `/config` (`required: true`).
- `dependencies`: none. Tasmota devices on the LAN are not a ContainerForge dependency.

## 7. start.sh

1. Seed `/config` only when missing: create `/config/data` if absent. Never overwrite existing user data.
2. Render the nginx and php-fpm configs into `/tmp` (for example `/tmp/nginx.conf`, `/tmp/php-fpm.conf`), with the PID, socket and log paths under `/tmp`. Do not write to `/etc` or `/var/www`.
3. Start php-fpm in the background, pointing at a unix socket in `/tmp`, then `exec nginx -c /tmp/nginx.conf -g 'daemon off;'` so nginx is PID 1 after the handoff. UNVERIFIED: whether a single process handoff is cleaner with a tiny supervisor; the brief prefers `exec`, so decide during the build and record it here.
4. Point the app's data directory at `/config/data`. UNVERIFIED: the exact mechanism (env var, config constant or symlink). A build-time symlink from `/var/www/tasmoadmin/data` to `/config/data` is an option (precedent `apps/fenrus` plan: dangling until start.sh creates the target), as is telling the app the path by env or config. Check the app source first.

## 8. container-test.yaml

- Schema header copied from the sibling.
- `tcp` probe on `8080` (every port in settings.yaml needs a probe).
- `http` probe on `/` on `8080` if the app returns 200 without login. UNVERIFIED: login behaviour; if it redirects, assert the redirect code.
- `timeoutSeconds`: take the value from `apps/bookstack/container-test.yaml`.
- `filePaths`: `/config/data` created by the seed step, and `/tmp/nginx.conf`.
- The test runs with no env vars, so no password path is exercised. TasmoAdmin has no DB dependency, so the DB narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root, with s6 and nginx on port 80/443. Rootless needs port 8080 (and no 443 unless TLS is added). Change the EXPOSE, settings.yaml and the probe together.
- Write paths: upstream `/data` becomes `/config/data` (section 7). nginx and php-fpm runtime files (pid, socket, temp, logs) move to `/tmp`.
- `/var/www/tasmoadmin` stays read-only, owned by `apps`, not written at runtime.
- No `privileged`, no extra persistence beyond `/config`. The draft's "non-root: no" and "read-only-rootfs: no" are the upstream state and are not kept.
- The draft's security expectations (runAsUser 0, readOnlyRootFilesystem false, extra persistence `/data`) describe the TrueCharts chart, not this image. The image must not depend on them.

## 10. Risks, caveats and open questions

- UNVERIFIED: checksum source for the release tarball (none published).
- UNVERIFIED: the app's data directory setting and whether `/data` is actually used for device lists and credentials. The draft says so (inferred), and this batch did not confirm it.
- UNVERIFIED: PHP package names and version on Ubuntu 26.04.
- UNVERIFIED: whether the tarball ships `vendor/`, and whether composer is needed.
- Initial admin setup happens in the web UI on first visit (draft, inferred; not confirmed).
- Upstream pins the tarball to v5.0.0. Each upgrade needs a new URL and checksum; renovate with the `github-releases` datasource covers the version, not the URL shape. Check that the URL template in the Dockerfile follows the `v${VERSION}` convention.
- Upstream's Dockerfile title label contains a stray brace (`TasmoAdmin}`). Not copied.
- Blockers: none found that stop a rootless build. The draft's "hard" rating comes from the multi-process nginx + php-fpm layout, not from musl or GPU.

## 11. Build and test steps

```sh
cd apps/tasmoadmin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker rm -f tasmoadmin-probe 2>/dev/null; docker volume rm tasmoadmin-probe-config 2>/dev/null
docker run --rm -d --name tasmoadmin-probe --read-only --tmpfs /tmp \
  -v tasmoadmin-probe-config:/config tasmoadmin:5.0.0
docker logs -f tasmoadmin-probe
forgetool containers test --image tasmoadmin:5.0.0 --config ./apps/tasmoadmin/container-test.yaml
docker rm -f tasmoadmin-probe; docker volume rm tasmoadmin-probe-config
```

- Expected readiness signal: nginx reports it is ready or accepts connections on 8080, and php-fpm reports it is ready. The exact lines are UNVERIFIED until the first build.
- Empty `/config` start must be tested on a fresh volume.
- arm64 is not built locally unless the amd64 build fails in an arm64-specific way (protocol rule).

## 12. PR checklist

- Branch `feat/add-tasmoadmin`, commit `feat(tasmoadmin): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge . Only the user can sign it.
- Say what was not tested in the PR (arm64, the UNVERIFIED items above, and anything not built). Do not tick "Built container locally" unless the build ran.
