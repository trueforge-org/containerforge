# plant-it — implementation plan
> Source: ./draft.md · Target: apps/plant-it/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart pins `msdeluise/plant-it-server:0.10.0`. 0.10.0 is the only release with a confirmed `server.jar` and `client.tar.gz` (published 2024-12-10). Latest release is `1.0.1` (2026-01-07), whose assets list only `app-release.apk`; a 1.x server jar is UNVERIFIED. Plan pins 0.10.0 (see section 10). |
| Renovate | `// renovate: datasource=github-releases depName=MDeLuise/plant-it versioning=semver` (tags have no `v` prefix) |
| License | GPL-3.0 (https://api.github.com/repos/MDeLuise/plant-it/license, LICENSE.txt) |
| Source URL | https://github.com/MDeLuise/plant-it |
| Release page | https://github.com/MDeLuise/plant-it/releases/tag/0.10.0 |
| Download URLs (0.10.0) | `https://github.com/MDeLuise/plant-it/releases/download/0.10.0/server.jar` and `https://github.com/MDeLuise/plant-it/releases/download/0.10.0/client.tar.gz`. Both architecture-neutral (JAR and static files). `app-release.apk` is not needed. |
| Checksum source | None published (release API has no digest). UNVERIFIED for both files. Record the sha256 of each file as computed at build time and state in the PR that upstream publishes none. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/MDeLuise/plant-it/0.10.0/deployment/Dockerfile. Single stage `FROM alpine:3.20.2`; `ARG JAVA_VERSION=21`; `apk add bash wget nginx openjdk${JAVA_VERSION}-jre`; downloads `wait-for-it.sh`; copies `backend/app.jar`, `deployment/start.sh`, `frontend/build/web`, `deployment/nginx.conf` to `/etc/nginx/nginx.conf`; `WORKDIR /opt/app/frontend`; `CMD ["/bin/sh","-c","/opt/app/start.sh"]`; no USER (root); no VOLUME; no ENV; `EXPOSE 8080` and `EXPOSE 3000`. |
| Java version | Upstream uses JRE 21, not 17 (draft assumed java17 as default). This plan uses java21 (see section 3). |
| Env vars | None defined in the Dockerfile. UNVERIFIED: runtime variables for DB host, Redis host, JWT or secrets. Needs `deployment/start.sh`, `application.properties` in the backend, or docs (not fetched). |
| Ports | 8080 (backend, EXPOSE). 3000 is also exposed upstream; the nginx listen port is UNVERIFIED (nginx.conf not fetched). |
| Data and config paths | Not in the Dockerfile. Upload path (draft: `/uploads`) and certificates path (draft: `/certificates`) are UNVERIFIED. |
| arm64 | Docker Hub `msdeluise/plant-it-server:0.10.0` has amd64 and arm64 images (https://hub.docker.com/v2/repositories/msdeluise/plant-it-server/tags). The jar itself is arch-neutral. |
| copy-from | no (upstream image is alpine/musl, so COPY --from is not usable; source is the release jar). |

## 2. Target layout

- `apps/plant-it/Dockerfile`
- `apps/plant-it/docker-bake.hcl`
- `apps/plant-it/settings.yaml`
- `apps/plant-it/container-test.yaml`
- `apps/plant-it/start.sh` (starts the backend and the static client web server, `exec` on the foreground process)
- `apps/plant-it/etc/nginx/nginx.conf` only if nginx is kept (reason: upstream serves the client with nginx; `etc/` is on the `.dockerignore` allow-list). Do not use `root/`.

No `DOWNSTREAM_CHANGES.md` (nothing uses this app as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2` (copied from `apps/doplarr/Dockerfile`, which uses the same java21 base). The java21 image is itself built on the ubuntu base, so apt packages work.

Why: upstream runs on JRE 21 (`ARG JAVA_VERSION=21`). Closest sibling: `apps/nzbhydra2` (Java jar on a java base, `/config` data, USER apps) and `apps/doplarr` (java21 base).

Note: the draft proposed java17. Upstream says 21, so java21 is the faithful choice. Switch to java17 only if the 1.x line needs it and the 0.10.0 version is dropped.

## 4. Dockerfile

1. Build stage not needed (no compile). Single runtime stage on the java21 base.
2. `ARG VERSION` (must match `docker-bake.hcl`), `USER root`.
3. Install nginx (client web server) with a pinned apt version, checked against upstream's unpinned `nginx` from alpine. Run `apt-cache policy nginx` at build time to choose the version; record it. Use `apt-get install -y --no-install-recommends nginx=<pinned> && rm -rf /var/lib/apt/lists/*`.
4. Fetch and verify the release files:
   - `curl -fL -o /tmp/server.jar https://github.com/MDeLuise/plant-it/releases/download/${VERSION}/server.jar`
   - `curl -fL -o /tmp/client.tar.gz https://github.com/MDeLuise/plant-it/releases/download/${VERSION}/client.tar.gz`
   - Verify against a sha256 computed from the first verified download, committed as a second ARG, because no upstream checksum exists (UNVERIFIED for the value; compute it during the build round and note it).
5. Lay out `/app/plant-it/`:
   - `mkdir -p /app/plant-it/backend /app/plant-it/frontend/build/web`
   - `mv /tmp/server.jar /app/plant-it/backend/app.jar`
   - `tar xzf /tmp/client.tar.gz -C /app/plant-it/frontend/build/web`
   - `chown -R apps:apps /app && chmod -R 755 /app`
6. Licence: `mkdir -p /usr/share/licenses/plant-it && curl -fL -o /usr/share/licenses/plant-it/LICENSE https://raw.githubusercontent.com/MDeLuise/plant-it/0.10.0/LICENSE.txt`. The tag must be pinned to `${VERSION}` (not `main`).
7. Clean `/tmp` downloads.
8. Env defaults (only the ones the image itself sets): `ENV HOME=/config`. Caches and temp in `/tmp` (`JAVA_TOOL_OPTIONS=-Xmx512M` optional, decide from memory tests; `-Djava.io.tmpdir=/tmp` needed with read-only rootfs).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
```

`WORKDIR /config` is optional (sibling pattern). Do not `USER` back to root after this.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "plant-it"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MDeLuise/plant-it versioning=semver
  default = "0.10.0"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/MDeLuise/plant-it"
}
```

Use the same `group "default"`, `image`, `image-local`, `image-all` targets as `apps/adguardhome-sync/docker-bake.hcl`, with `args = { VERSION = "${VERSION}" }` and the two OCI labels. Use `GPL-3.0-only` only if the LICENSE header confirms "only"; otherwise `GPL-3.0-or-later` (check the upstream LICENSE.txt header before writing). Run `docker buildx bake --print` from `apps/plant-it`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MDeLuise/plant-it"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 3000
    protocol: tcp
    required: false   # UNVERIFIED which port serves the client; keep only if start.sh binds it
dependencies:
  - mariadb            # hard dependency (draft), exists in apps/mariadb
  - valkey             # optional dependency (draft), exists in apps/valkey
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Env: only TZ is confirmed. Add DB and Redis variables once `start.sh` and the backend config are read (UNVERIFIED names; do not invent). Dependencies: mark `mariadb` and `valkey` as present (both exist under `apps/`).

## 7. start.sh

- `mkdir -p /config/uploads /config/certificates /tmp/nginx` (paths UNVERIFIED; adjust after reading upstream start.sh).
- Seed nothing into `/config` unless a file is required and missing (`cp -n` pattern from `apps/adguardhome-sync/start.sh`).
- Start the backend in the background (`java -Djava.io.tmpdir=/tmp -jar /app/plant-it/backend/app.jar`), start nginx in the foreground with a config that writes its pid and temp files under `/tmp`, bind `0.0.0.0`.
- Use `exec` for the final process only; trap TERM to stop the backend (tini is not present in the java base unless the ubuntu base provides it; check `apps/java21` PID 1 handling).
- Read env from settings.yaml names only (defaults match settings.yaml).

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
- /app/plant-it/backend/app.jar
- /app/plant-it/frontend/build/web/index.html
- /usr/share/licenses/plant-it/LICENSE
```

Timeout: 180 is the sibling Java value (most common timeout among siblings). Every port in settings.yaml gets a probe; add a tcp probe for 3000 if it is kept. The `http /` probe may return non-200 until the DB is reachable; the DB-dependency exception (build-test-protocol) applies: `# narrowed: requires external mariadb and valkey; full functional test not feasible in single-container suite`. Narrowing must keep real assertions (port open, file existence).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Upstream runs as root (no USER) | `USER apps` in the final stage; nginx listens on a port above 1024 and writes pid/temp under `/tmp`. |
| nginx default temp and pid paths (`/var/lib/nginx`, `/run/nginx.pid`) | `/tmp/nginx/*` via `pid` and `*_temp_path` directives in the custom nginx.conf |
| Uploads and certificates (draft: `/uploads`, `/certificates`) | `/config/uploads`, `/config/certificates` (UNVERIFIED paths) |
| Java temp | `-Djava.io.tmpdir=/tmp` |
| Draft security expectations (runAsUser 0, readOnlyRootFilesystem false, privileged false, extra persistence) | Reconciled: target UID is `apps` (rootless), read-only rootfs must work with `--read-only --tmpfs /tmp`; extra persistence moves under `/config` (single volume). |

## 10. Risks, caveats and open questions

- **Version**: chart pins 0.10.0 (2024). Latest is 1.0.1 (2026) with no jar on the release page. Decide: keep 0.10.0 (confirmed) or verify a 1.x jar before switching.
- **Client serving**: the upstream runs a separate nginx. Confirm whether the backend can serve `frontend/build/web` itself; if not, nginx stays (apt-pinned, see section 4).
- **Checksums**: no upstream checksum (UNVERIFIED).
- **Env vars**: DB and Redis variable names UNVERIFIED (not in the Dockerfile).
- **Ports**: 3000 purpose UNVERIFIED.
- **Draft caveats**: first run needs a user created in UI or API (inferred); the client is served by a second web server (confirmed by upstream Dockerfile).
- **Blockers**: none confirmed. No musl-only binary (jar). No GPU or privileged needs found. arm64 image upstream exists, jar is neutral.

## 11. Build and test steps

From `apps/plant-it`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create plant-it-probe-config`
4. `docker run --rm -d --name plant-it-probe --read-only --tmpfs /tmp -v plant-it-probe-config:/config plant-it:0.10.0`
5. `docker logs -f plant-it-probe` until a readiness line appears (expected: Spring Boot "Started ..." or nginx start with no fatal). The DB is not running, so the container may log connection retries; this counts as positive only with the process still alive (protocol exception).
6. `forgetool containers test --image plant-it:0.10.0 --config ./container-test.yaml`
7. Clean up: `docker rm -f plant-it-probe; docker volume rm plant-it-probe-config`.

Arm64 only if an amd64-specific failure appears.

## 12. PR checklist

- Branch `feat/add-plant-it`, commit `feat(plant-it): add new container`, PR title the same, target `main`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; only tick what was done.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- State what is untested: DB-dependent full functional test (narrowed), arm64 build, checksum (none upstream).
- Pre-completion checklist from `.github/copilot-instructions.md` (bake print, version alignment, rootless, empty `/config`, no DOWNSTREAM file needed).
