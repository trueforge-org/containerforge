# booklore — implementation plan
> Source: ./draft.md · Target: apps/booklore/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.4.0`, published 2026-09-19 (GitHub latest release). Matches the chart image `ghcr.io/booklore-app/booklore:v2.4.0`. Source: https://api.github.com/repos/booklore-app/booklore/releases/latest |
| Renovate | `// renovate: datasource=github-releases depName=booklore-app/booklore versioning=semver` (proposed) |
| License | GitHub reports AGPL-3.0. The upstream Dockerfile OCI label says GPL-3.0 (https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/Dockerfile). UNVERIFIED: conflict. Read the repo `LICENSE` file before setting `LICENSE` in bake. |
| Source URL | https://github.com/booklore-app/booklore. Tag archive: `https://github.com/booklore-app/booklore/archive/refs/tags/v2.4.0.tar.gz` |
| Prebuilt app binary | None. The v2.4.0 release has no assets (https://api.github.com/repos/booklore-app/booklore/releases/latest). Must compile. |
| Per-arch | Compile on both arches. The jar is arch-neutral bytecode. The `unrar` helper is per-arch (`docker/unrar/unrar-amd64`, `docker/unrar/unrar-arm64`, both present in the repo: https://api.github.com/repos/booklore-app/booklore/contents/docker/unrar). |
| Checksum source | None for the build. The tag archive is content-addressed. UNVERIFIED: the `unrar` binary has no published checksum source in the repo. |
| Upstream Dockerfile reviewed | Blob `f397e98c5ab021b02e8930ce278583af11637238` (https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/Dockerfile). Stage 1: `node:24-alpine`, Angular build `npm run build --configuration=production` from `booklore-ui/`. Stage 2: `gradle:9.3.1-jdk25-alpine`, `gradle clean build -x test --no-daemon --parallel` in `booklore-api/`, `APP_VERSION` injected into `application.yaml` with `yq`. Stage 3: `eclipse-temurin:25-jre-alpine`, `ENTRYPOINT ["entrypoint.sh"]`, `CMD ["java","-jar","/app/app.jar"]`. UNVERIFIED: this blob is the draft's pinned version; the `v2.4.0` tag may differ. Re-read at the tag before implementing. |
| Entrypoint reviewed | https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/entrypoint.sh. Creates user `USER_ID`/`GROUP_ID` (default 1000), `mkdir -p /app/data /bookdrop`, `chown`, then `exec su-exec "$USER_ID:$GROUP_ID" "$@"`. Starts as root. |
| App config | `application.yaml` (https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/booklore-api/src/main/resources/application.yaml): `path-config: '/app/data'`, `bookdrop-folder: '/bookdrop'` (both hard-coded, no env override shown), `server.port: ${BOOKLORE_PORT:6060}`. |
| Port | 6060/tcp (confirmed: `EXPOSE ${BOOKLORE_PORT}` with default 6060 and `server.port`). |
| Env vars (real) | `BOOKLORE_PORT` (default 6060), `DATABASE_URL`, `DATABASE_HOST` or `DB_HOST` (default `mariadb`), `DATABASE_PORT` (3306), `DATABASE_NAME` (booklore), `DATABASE_USERNAME` (root), `DATABASE_PASSWORD` or `MYSQL_ROOT_PASSWORD`, `ALLOWED_ORIGINS`, `REMOTE_AUTH_ENABLED` (false) and `REMOTE_AUTH_*` headers, `FORCE_DISABLE_OIDC` (false), `DISK_TYPE` (LOCAL), `USER_ID`, `GROUP_ID` (entrypoint, not Spring), `JAVA_TOOL_OPTIONS` (set in image). |
| Data and config write paths | `/app/data` (app data; hard-coded). `/bookdrop` (import folder; the app reads and removes files there; hard-coded). |
| Dependencies | MariaDB, hard. `application.yaml` defaults the host to `mariadb`. `apps/mariadb` exists. |
| Blockers | (1) Upstream entrypoint runs as root and switches with `su-exec`; ContainerForge needs `USER apps` and a start that works read-only. (2) Gradle plus Angular build is slow and needs a JDK 25 build image. (3) Spring Boot needs a sizeable heap. |

## 2. Target layout

- `apps/booklore/Dockerfile`
- `apps/booklore/docker-bake.hcl`
- `apps/booklore/settings.yaml`
- `apps/booklore/container-test.yaml`
- `apps/booklore/start.sh`: replaces upstream `entrypoint.sh` (the upstream script is not copied as-is).
- `apps/booklore/defaults/`: not needed. The app creates its own data.
- `apps/booklore/docker/unrar/`: not needed if the binaries are copied from the build context. Instead copy the source tree in the build stage. See section 4.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`. Sibling pattern: `FROM java25` in the repo. The base is a JRE (Temurin), which is enough for `java -jar`.
- Build stage: the JRE base has no `javac`, and Gradle needs a JDK. Two options, to be decided before implementing:
  - A (preferred, check first): `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, then `apt-get install openjdk-25-jdk-headless` and Node 24 (from the archive or NodeSource). UNVERIFIED: the package names and their presence in the 26.04 archive. Run `apt-cache policy` in the base first.
  - B (fallback): `gradle:9.3.1-jdk25-alpine` pinned by digest, as upstream. This is not a ContainerForge base. It is build-only (musl), and its output is a jar and static files, so it does not reach the runtime. Needs maintainer agreement under the base-image rule.
- Closest siblings: `apps/nzbhydra2` (Java app built from a release), `apps/java25` (runtime).

## 4. Dockerfile

1. Build stage (option A): `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:... AS builder`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends openjdk-25-jdk-headless nodejs npm` (UNVERIFIED package names), then `rm -rf /var/lib/apt/lists/*`. Do not install packages the base already has.
3. Fetch the source at the tag: `curl -fsSL https://github.com/booklore-app/booklore/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /src --strip-components=1`. Use `ENV HOME=/tmp GRADLE_USER_HOME=/tmp/gradle` and `npm_config_cache=/tmp/npm`. Keep caches in `/tmp`, not `/config`.
4. Angular: `cd booklore-ui && npm ci --force && npm run build -- --configuration=production`. Copy the output (`dist/booklore/browser`) to `booklore-api/src/main/resources/static`, as upstream does.
5. Version: `ARG APP_VERSION` (set from `VERSION` without the `v`) and inject into `booklore-api/src/main/resources/application.yaml`. Upstream uses `yq`. Use the same tool in the build stage, not the runtime.
6. Gradle: `cd booklore-api && gradle clean build -x test --no-daemon --parallel`. Output: `build/libs/booklore-api-*.jar`. Copy the jar to `/build/app.jar`. Do not compile in the runtime stage.
7. Final stage `FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:..., ARG VERSION`, `USER root`.
8. `COPY --from=builder /build/app.jar /app/app.jar`. Ship license and notices: `COPY --from=builder /src/LICENSE /usr/share/licenses/booklore/LICENSE`.
9. unrar helper: `ARG TARGETARCH` and `COPY --from=builder /src/docker/unrar/unrar-${TARGETARCH} /usr/local/bin/unrar`, then `chmod 0755`. UNVERIFIED: the unrar license terms allow redistribution in this image. Check before shipping.
10. Remap the two hard-coded write paths with build-time symlinks: `RUN ln -s /config/data /app/data && ln -s /config/bookdrop /bookdrop`. The targets are created by `start.sh`, so the link is dangling until first start. The symlinks are made at build time, so they are not runtime writes to `/app`.
11. Environment: `ENV JAVA_TOOL_OPTIONS="-XX:+UseG1GC -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError" BOOKLORE_PORT=6060 DATABASE_HOST=mariadb DATABASE_PORT=3306 DATABASE_NAME=booklore DATABASE_USERNAME=root`.
12. Tail:

```dockerfile
EXPOSE 6060
VOLUME /config
USER apps
COPY --chmod=0755 . /
```

`ENTRYPOINT`/`CMD`: use `CMD ["/start.sh"]` (start script runs the Java process with `exec`).

Note: `UID`/`GID` are not needed. The `apps` user from the base is used, so the upstream `USER_ID` logic is dropped.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "booklore" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=booklore-app/booklore versioning=semver
  default = "v2.4.0"
}
variable "LICENSE" { default = "AGPL-3.0-only" }   // UNVERIFIED: see section 1
variable "SOURCE" { default = "https://github.com/booklore-app/booklore" }
```

Keep the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/it-tools/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/booklore-app/booklore"
ports:
  - port: 6060
    protocol: tcp
    required: false
env:
  - name: BOOKLORE_PORT
    default: "6060"
    required: false
  - name: DATABASE_HOST
    default: "mariadb"
    required: false
  - name: DATABASE_PORT
    default: "3306"
    required: false
  - name: DATABASE_NAME
    default: "booklore"
    required: false
  - name: DATABASE_USERNAME
    default: "root"
    required: false
  - name: DATABASE_PASSWORD
    default: ""
    required: true
  - name: REMOTE_AUTH_ENABLED
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```

`DATABASE_PASSWORD` is required, so `start.sh` must refuse to start without it, with a clear message. Do not invent a default password. `DATABASE_URL` is accepted by the app, but do not list it unless the start script sets it. The `dependencies` entry matches the `apps/hedgedoc/settings.yaml` format.

## 7. start.sh

Idempotent, `exec`s Java, writes only to `/config`:

```bash
#!/bin/sh
set -eu

: "${DATABASE_PASSWORD:?DATABASE_PASSWORD is required (set it to the MariaDB password)}"

mkdir -p /config/data /config/bookdrop /tmp/booklore-tmp
exec java -jar /app/app.jar
```

Rules: `/config/data` (app state) and `/config/bookdrop` (import folder) are created only if missing, never overwritten. The symlinks from section 4 make `/app/data` and `/bookdrop` point into `/config`. `/tmp` is used for Java temp (`-Djava.io.tmpdir=/tmp` is the JVM default). Set `DATABASE_PASSWORD` as the env, do not write it to a file or to the command line (keep it out of `ps`).

UNVERIFIED: upstream `application.yaml` does not show whether `MYSQL_ROOT_PASSWORD` must be honored too. Keep to `DATABASE_PASSWORD` unless the app's docs say otherwise.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
filePaths:
- /app/app.jar
- /usr/local/bin/unrar
- /usr/share/licenses/booklore/LICENSE
- /start.sh
```

Narrowed, per the database-dependent exception in `build-test-protocol.instructions.md`. Add a comment near the narrowed block: `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`.

Rules: the test runs with no env vars, so `DATABASE_PASSWORD` is unset. Per the protocol, the container is allowed to exit in this case, so the `tcp` probe on 6060 is not used here. Run the probe by hand (section 11) with a real MariaDB. Do not add a `tcp` or `http` probe that will fail without the DB, and do not remove the port from `settings.yaml`. Coverage rule (every port has a probe) is met only by the narrowed file checks plus the manual run, and that gap must go into the PR notes.

UNVERIFIED: whether forgetool supports a DB sidecar. If it does, add a mariadb runner and real `tcp` + `http` probes instead of the narrowed block.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (hard-coded `path-config`) | Build-time symlink to `/config/data` |
| `/bookdrop` (hard-coded `bookdrop-folder`; files are read and removed by the app) | Build-time symlink to `/config/bookdrop` |
| `/tmp` (JVM temp, unrar extraction) | Runtime `--tmpfs /tmp` |
| Upstream root start (`chown`, `su-exec`) | Dropped. The image runs as `apps` (UID 568). The `/config` volume must be writable by 568, documented in the PR. |

Draft security expectations reconciled: the chart runs as UID 0 and `readOnlyRootFilesystem: false`. In ContainerForge the target is non-root (`USER apps`) and read-only rootfs. Chart values that set UID 0 are not carried over. The draft's `extra-persistence` (`/bookdrop`, `/app/data`) maps to the `/config` volume (see table above).

Run check: `docker run --read-only --tmpfs /tmp` with an empty `/config` must reach the DB connection step and fail clearly, not with a write error.

## 10. Risks, caveats and open questions

- Build time: the Gradle plus Angular build is slow on both architectures. Budget for it in CI.
- Heap: `JAVA_TOOL_OPTIONS` caps the heap at 75% of the cgroup memory. Small hosts may hit `ExitOnOutOfMemoryError`.
- License conflict: AGPL-3.0 (GitHub) vs GPL-3.0 (Dockerfile label). Resolve from the LICENSE file before setting `LICENSE`.
- `unrar` redistribution: check the license before shipping the binary.
- Build base decision (section 3): Option A (ubuntu + apt JDK and Node) needs package verification. Option B (upstream `gradle` alpine image) needs maintainer agreement.
- Upstream version drift: the Dockerfile was reviewed at blob `f397e98`. The `v2.4.0` tag must be re-read before the build.
- Test coverage: the narrowed test does not prove a running server, see section 8.
- Upstream root start is removed. This changes file ownership of `/config` for existing users (their data was written as the upstream user). Document it in the PR.
- No blockers beyond these: no GPU, no privileged, no musl-only binary in the final image (the jar runs on any JRE; `unrar` per arch is glibc).

## 11. Build and test steps

```sh
cd apps/booklore
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create booklore-net
docker run -d --name mariadb-probe --network booklore-net -e MARIADB_ROOT_PASSWORD=test-root-pw \
  -e MARIADB_DATABASE=booklore <mariadb-image-built-from-apps/mariadb>   # use the image built from apps/mariadb, not a floating tag
docker run --rm -d --name booklore-probe --network booklore-net --read-only --tmpfs /tmp \
  -e DATABASE_HOST=mariadb-probe -e DATABASE_PASSWORD=test-root-pw \
  -p 6060:6060 -v booklore-probe-config:/config booklore:v2.4.0
docker logs -f booklore-probe
curl -sI http://127.0.0.1:6060/ | head -1
forgetool containers test --image booklore:v2.4.0 --config ./apps/booklore/container-test.yaml
docker rm -f booklore-probe mariadb-probe; docker network rm booklore-net; docker volume rm booklore-probe-config
```

Replace the mariadb image with the repo's pinned `apps/mariadb` build. Expected readiness signal: Spring Boot banner, `Tomcat started on port 6060` (or `Started`), and no `Access denied` or `Communications link failure`. Confirm `/config/data` exists after start and survives a restart. Run arm64 separately.

## 12. PR checklist

- Branch `feat/add-booklore`, commit and PR title `feat(booklore): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Document the downstream `/config` ownership change (upstream root start removed) in the PR.
- `docker buildx bake --print` passes; `VERSION` in bake equals `ARG VERSION` in the Dockerfile.
- Untested to state honestly: the full Gradle and Angular build, arm64, the running app with a real MariaDB (narrowed CI test only), the `unrar` license, and the LICENSE conflict.
