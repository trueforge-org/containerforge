# poznote — implementation plan
> Source: ./draft.md · Target: apps/poznote/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release `6.159.0`, published 2026-11-24T22:31:38Z (https://api.github.com/repos/timothepoznanski/poznote/releases/latest). The chart's tag `6.153.0` exists (published 2026-11-19T19:28:24Z). Pin `6.159.0`, the latest stable release. The chart's build (6.153.0) is the version the draft traced. Release has no assets. |
| Renovate | `datasource=github-releases depName=timothepoznanski/poznote versioning=semver`. |
| License | MIT (GitHub SPDX `MIT`; the license file in the repo is named `LICENCE`). Default branch `develop`. |
| Source URL | https://github.com/timothepoznanski/poznote |
| Download | Source tarball `https://github.com/timothepoznanski/poznote/archive/refs/tags/${VERSION}.tar.gz`. Interpreted PHP: no compiled binary. The upstream image copies `./src` into the web root. |
| Checksum source | None published on the release page (no assets). Tarball is tag-addressed; record the SHA-256 we compute at build time in a comment (UNVERIFIED whether upstream publishes checksums). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/timothepoznanski/poznote/5db51e94dfa0f6f204f267505153cf5fd143feb2/Dockerfile (the draft's commit). |
| Upstream base | `php:8.5.12-fpm-alpine3.23` (Alpine, musl). Not usable on ContainerForge (glibc Ubuntu). Replace with Ubuntu apt packages. |
| Upstream process model | `CMD ["/bin/sh","-c","/usr/local/bin/init.sh && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]`. supervisord runs nginx, php-fpm, and the reminder worker. |
| Upstream stages | `base`, `rootless` (USER poznote, uid/gid 1000, `EXPOSE 8080`, nginx patched to 8080), `default` (root, `EXPOSE 80`). We follow `rootless`. |
| Upstream paths | App in `/var/www/html` (`COPY ./src`); data in `/var/www/html/data` (SQLite and uploads); `version.php` written at build. |
| Ports | 8080 (rootless stage). |
| Env vars | None set in the upstream Dockerfile (`ENV: None`). Upstream `init.sh` contents are UNVERIFIED (not fetched); read it in the build step before writing `start.sh`. |
| Volumes | None declared upstream (`VOLUME: None`). |
| Dependencies | None. Data is SQLite (bundled file). |
| arm64 | UNVERIFIED (upstream multi-arch not checked). Ubuntu php8.5 packages for arm64 to be confirmed by the build. |

## 2. Target layout

- `apps/poznote/Dockerfile`
- `apps/poznote/docker-bake.hcl`
- `apps/poznote/settings.yaml`
- `apps/poznote/container-test.yaml`
- `apps/poznote/start.sh`
- `apps/poznote/etc/` only for the nginx and php-fpm config files that must be changed for an unprivileged, non-root run on port 8080 (reason: the upstream `rootless` sed patches must become committed files, not runtime `sed`). Not `root/`.

No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Reason: PHP is installed from the Ubuntu archive, as `apps/bookstack` does (`php8.5-*` packages). No PHP base exists for this app in ContainerForge.
- Closest sibling: `apps/bookstack` (PHP 8.5 from apt on ubuntu, `USER root` for install, `USER apps` at the end, symlinks into `/config`).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install runtime packages (the list is a starting point; confirm each name in the 26.04 archive during the build):
   - `nginx`, `php8.5-fpm`, `php8.5-sqlite3`, `php8.5-curl`, `php8.5-mbstring`, `php8.5-zip`, `php8.5-xml`, `supervisor`, `ca-certificates`.
   - Do not install packages the base already has (`curl`, `tar` are in the base).
   - Pin the PHP packages to the `php8.5` series, as `apps/bookstack` does.
3. Fetch source: `curl -fL https://github.com/timothepoznanski/poznote/archive/refs/tags/${VERSION}.tar.gz -o /tmp/poznote.tar.gz && mkdir -p /tmp/poznote && tar xf /tmp/poznote.tar.gz -C /tmp/poznote --strip-components=1`.
4. Copy the app: `mkdir -p /app/poznote && cp -r /tmp/poznote/src/. /app/poznote/`. Upstream `./src` is the web root.
5. Config: copy the upstream nginx (`default.conf`), php-fpm (`www.conf`), `php.ini`, and supervisord config from the source tree. Apply the changes that the upstream `rootless` stage makes, but as committed files under `apps/poznote/etc/`:
   - nginx listens on 8080; no `user` directive; pid and temp paths under `/tmp`.
   - php-fpm pool: no `user`/`group`; listen on `127.0.0.1:9000` or a socket in `/tmp` (TCP is simpler; confirm it is not exposed externally).
   - supervisord: no `user` lines; logs under `/tmp`.
6. Data path: the app's `data/` must live in `/config`. Use a symlink from the app folder to `/config/data`, as `apps/bookstack` does (`/app/poznote/data -> /config/data`). The link target is created by `start.sh`. `/app` stays read-only.
7. `chown -R apps:apps /app/poznote` only if the app needs write access to its own tree (UNVERIFIED; the goal is read-only `/app`; prefer no chown and `/config`-based writes).
8. License: `install -D /tmp/poznote/LICENCE /usr/share/licenses/poznote/LICENSE`.
9. Clean up: `rm -rf /tmp/* /var/lib/apt/lists/*`.
10. Tail, same as `apps/bookstack`:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

`CMD` is set in `start.sh` (exec supervisord with the `etc/` config), not in the Dockerfile.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "poznote"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=timothepoznanski/poznote versioning=semver
  default = "6.161.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/timothepoznanski/poznote"
}
```

Then the default group and the four standard targets copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/poznote/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/timothepoznanski/poznote"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules check: no env vars are read from upstream (none declared), so only `TZ` (ContainerForge standard) is listed. Do not invent app variables. Add any found in upstream `init.sh` during the build.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /tmp/nginx /tmp/php /tmp/supervisor

# init.sh (upstream) logic to be ported here after reading it: version.php, database create if missing.
# Only create state that is missing; never overwrite existing data in /config/data.

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
```

- Idempotent: `mkdir -p` runs on every start and creates nothing that exists.
- Never writes into `/app`. The `/app/poznote/data -> /config/data` symlink is created in the Dockerfile (step 6), as `apps/bookstack` does, so `start.sh` does not touch `/app`.
- `exec` supervisord so signals reach PID 1 handling.
- Read-only rootfs: nginx pid, temp, and logs must be in `/tmp`; supervisord logs in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
```

- One TCP probe for the single port in `settings.yaml`.
- Optional: an HTTP probe on `/` if the forgetool schema accepts it (confirm the schema in the build).
- Empty environment is supported (no env vars upstream), so no `filePaths` needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Our version | Reason |
| --- | --- | --- |
| `rootless` stage: `USER poznote` (uid 1000) | `USER apps` | Base image user. Port 8080 is unprivileged. |
| `default` stage: root, port 80, `www-data` | Not used | We follow the rootless stage. |
| Runtime `sed` patches | Committed `etc/` config files | Reviewable and idempotent. |
| `/run`, `/var/lib/nginx`, `/var/log` emptyDir (chart) | `/tmp` | Read-only rootfs; `/tmp` is the ephemeral scratch space. |
| `/var/www/html/data` (SQLite, uploads) | Symlink to `/config/data` | Persistent state in `/config`. |
| `prepare-runtime` root init container (chart) | Not needed | We do not need root to chown; ownership is set at build time. |

Chart reconciliation: the chart's main container inherits `readOnlyRootFilesystem: true`, `runAsUser 568`, `privileged: false`. Our image matches. The root init container in the chart is a chart-only concern and is not ported.

## 10. Risks, caveats and open questions

- Ubuntu PHP package names are not confirmed. Check `php8.5-fpm` and `php8.5-sqlite3` exist in the 26.04 archive (bookstack uses `php8.5-*` so the series exists; the individual names are UNVERIFIED).
- nginx: upstream is an Alpine build; the Ubuntu nginx package differs in default paths. Confirm the config paths during the build.
- `init.sh` content is UNVERIFIED (not fetched). It may create `version.php`, the database, or directories. Read it before writing `start.sh`.
- The draft listed only php-fpm; nginx and supervisord are required (confirmed by the upstream `CMD`).
- Upstream publishes release `6.159.0`, but the chart tag is `6.153.0`. Confirm `6.159.0` builds before the PR.
- Data: uploads and SQLite move under `/config`. The data layout must survive an upgrade (verify with a second start on the same volume).
- arm64: UNVERIFIED.
- Blockers: none confirmed. Stop and report if the nginx or php-fpm config cannot run unprivileged on port 8080.

## 11. Build and test steps

Run from `apps/poznote/`, in this order:

1. `docker buildx bake --print`: must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`: must build.
3. Probe with an empty config volume:
   ```sh
   docker volume create poznote-probe-config
   docker run --rm -d --name poznote-probe --read-only --tmpfs /tmp \
     -v poznote-probe-config:/config poznote:<version>
   docker logs -f poznote-probe
   ```
   Expected readiness signal: nginx and php-fpm report started under supervisord, and port 8080 answers (exact log text UNVERIFIED; confirm in the build). The container must stay running.
   Cleanup: `docker rm -f poznote-probe; docker volume rm poznote-probe-config`.
4. Test suite: `forgetool containers test --image poznote:<version> --config ./apps/poznote/container-test.yaml`.

## 12. PR checklist

- Branch: `feat/add-poznote` from `main`.
- Commit: `feat(poznote): add new container`.
- PR title: `feat(poznote): add new container`.
- PR description: fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and tick only what was done. Note the pinned version (6.159.0) and that the chart uses 6.153.0.
- Notes section: `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user when the PR opens.
- Not tested (state in the PR if it applies): arm64, the upstream web UI in a browser, the upgrade path from the chart's data layout, and any run that has not been executed.
