# teedy — implementation plan
> Source: ./draft.md · Target: apps/teedy/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v1.12** (published 2026-11-23). The draft pins v1.11 (`docker.io/sismics/docs:v1.11`, tarball v1.11). Use v1.12. |
| Renovate | `datasource=github-releases depName=sismics/docs versioning=loose` (tags are `v1.12`, two-part, so loose). Confirm against a sibling with a two-part tag. |
| License | GPL-2.0 (GitHub license API, `sismics/docs`). |
| Source URL | https://github.com/sismics/docs |
| Release asset | `docs-web-1.12.war`: https://github.com/sismics/docs/releases/download/v1.12/docs-web-1.12.war (architecture-neutral WAR). |
| Checksum source | UNVERIFIED: no checksum asset in the release listing. Pin by version and record the WAR's SHA-256 in the Dockerfile after the first download, or use the GitHub release digest if the API exposes one. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sismics/docs/master/Dockerfile (master, not the draft's pinned commit `5b39c46`; the file at `5b39c46` is UNVERIFIED). |
| Upstream base | `ubuntu:26.04`, single stage. Installs OpenJDK 25 JDK, ffmpeg, mediainfo, many `tesseract-ocr` language packs, and Jetty home 12.1.6 from Maven Central to `/opt/jetty`. Runs as root (the `jetty` user is created but not used). |
| Upstream CMD | `java -jar /opt/jetty/start.jar --add-modules=server,http,ee11-webapp,ee11-deploy` from `/app`, with `docs.war` in `/app/webapps`. |
| Upstream env | `LANG`/`LC_ALL=C.UTF-8`, `JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64/`, `JAVA_OPTIONS=-Dfile.encoding=UTF-8 -Xmx1g`, `JETTY_VERSION=12.1.6`, `JETTY_HOME=/opt/jetty`. |
| Port | 8080 (`EXPOSE 8080`). |
| Data path | UNVERIFIED: the draft says `/data`. `docs.properties` and config keys were not retrievable (raw.githubusercontent 404, GitHub contents 404). Confirm the data directory from the source at v1.12 before writing the start script. |
| Database | PostgreSQL optional per draft. UNVERIFIED in fetched files whether H2 is the default. |
| Blockers | None confirmed. |

Difference from draft: the draft's `java11` runtime is wrong for v1.12. Upstream uses JDK 25. The draft's Maven build step is also unnecessary, because the release provides the built WAR.

## 2. Target layout

- `apps/teedy/Dockerfile`
- `apps/teedy/docker-bake.hcl`
- `apps/teedy/settings.yaml`
- `apps/teedy/container-test.yaml`
- `apps/teedy/start.sh`

No `defaults/` or `etc/` unless the Jetty base needs a seeded file (decide at step 7). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`

Why: it matches the upstream JDK 25 (`java-25-openjdk`), and the WAR and Jetty 12 run on it without a Maven build. The draft's java11 is not the upstream runtime. Closest sibling: `apps/java25` (base) and `apps/nzbhydra2` (Java app with `/config`, `apps` user, and `start.sh` exec pattern).

## 4. Dockerfile

1. `ARG VERSION` (`1.12`), `ARG TARGETARCH` (not needed for the WAR, which is arch-neutral).
2. `USER root`, then one `RUN` layer:
   - `apt-get update && apt-get install -y --no-install-recommends ffmpeg mediainfo tesseract-ocr tesseract-ocr-eng` (add more `tesseract-ocr-<lang>` packages only if the app needs them; upstream installs about 30). None of these is in the base image, so the install is required.
   - `rm -rf /var/lib/apt/lists/*`
   - Apt versions are not pinned to `VERSION` (they are toolchain, not the app). Document the chosen versions in the PR.
3. Jetty: download `jetty-home-12.1.6.tar.gz` from Maven Central (`https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/12.1.6/`), verify it against the `.sha1` (or `.sha512`) file published next to it (UNVERIFIED: checksum URL not fetched; confirm before writing), extract to `/opt/jetty`. Use `ENV JETTY_VERSION=12.1.6` (fine to keep as ARG for renovate).
4. Teedy WAR: `curl -fsSL https://github.com/sismics/docs/releases/download/v${VERSION}/docs-web-${VERSION}.war -o /app/webapps/docs.war` with a SHA-256 check (value recorded in the Dockerfile after the first download). Also fetch `docs.xml` (Jetty context) from the upstream repo tag `v${VERSION}` (UNVERIFIED: the upstream Dockerfile copies it from the repo; pin the tag, not master).
5. License: `COPY` or `install -D` the upstream `LICENSE` to `/usr/share/licenses/teedy/LICENSE` (the draft's GPL-2.0 applies to the WAR).
6. Permissions: `chown -R root:root /app /opt/jetty` and `chmod -R 755 /app /opt/jetty` (read-only at runtime).
7. `ENV` (only real vars): `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`, `JAVA_OPTIONS="-Dfile.encoding=UTF-8 -Xmx1g"`, `JETTY_HOME=/opt/jetty`. Keep `JAVA_HOME` from the base.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

Caches: none expected from Jetty or apt. Set `HOME=/tmp` if the JVM writes to `~/.java` (UNVERIFIED).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "teedy" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=sismics/docs versioning=loose
  default = "1.12"
}
variable "LICENSE" { default = "GPL-2.0" }
variable "SOURCE" { default = "https://github.com/sismics/docs" }
```

Four standard targets and the default group copied from `apps/nzbhydra2/docker-bake.hcl` (or `apps/java25/docker-bake.hcl`). Validate with `docker buildx bake --print`. The Dockerfile consumes `VERSION` through `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sismics/docs"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

Rules: `TZ` is the only env var this plan confirms the image reads. Do not add `JAVA_OPTIONS` as a settings env unless `start.sh` reads it. Dependencies: postgresql is optional (draft and chart), so it goes in `opt_dependencies`, not `dependencies`. Not in `dependencies` (no hard dep). `postgresql` exists in `apps/postgresql` (ready).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/logs

cd /app
exec java ${JAVA_OPTIONS:-} \
  -jar "${JETTY_HOME}/start.jar" \
  --add-modules=server,http,ee11-webapp,ee11-deploy \
  --jpms \
  "jetty.base=/tmp/jetty" \
  "jetty.http.port=8080" \
  "jetty.http.host=0.0.0.0"
```

Notes:
- Use `set -euo pipefail` only if it does not break `exec`; keep the final `exec` for signal handling.
- The teedy data directory (draft says `/data`) must be mapped to `/config/data`. The exact property or env var is UNVERIFIED: confirm at v1.12 before adding it to `start.sh`.
- `jetty.base` must be writable and ephemeral: set it to `/tmp/jetty` and create it in `start.sh` (`mkdir -p /tmp/jetty/webapps && cp -n /app/webapps/* /tmp/jetty/webapps/` or deploy from `/app/webapps` with an explicit `--module`). UNVERIFIED whether Jetty 12 accepts `/app/webapps` read-only. Test it with `--read-only` in step 11.
- Bind 0.0.0.0 (`jetty.http.host=0.0.0.0`).
- Idempotent: no writes to `/app`; `/config` is created only when missing.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/webapps/docs.war
- /usr/share/licenses/teedy/LICENSE
```

- Test runs with no env vars and no PostgreSQL, so the image must start on its own. If the app needs PostgreSQL to serve `/`, this is the DB-dependency exception case, but the dependency is optional, so the exception does NOT apply: the test must still probe the real port. If `/` returns a non-200 without a DB, record that and do not narrow the test; fix the start behaviour instead.
- `timeoutSeconds: 240`: Jetty plus WAR deploy is slower than the sibling `java` apps (`nzbhydra2` has no timeout). Compare with `apps/changedetection` (180) and raise if the first run is slower.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/webapps/` (Jetty deploy, ROOT context) | Read-only in the image. Deploy from `/app/webapps` or copy to `/tmp/jetty/webapps` at start. |
| Jetty base / temp / work dirs | `/tmp/jetty` (`jetty.base`), via `start.sh`. |
| Teedy documents and index (`/data` per draft; UNVERIFIED) | `/config/data`. |
| JVM tmp (`java.io.tmpdir`) | `/tmp` (default). |
| apt, tesseract language data | Installed at build time (`/usr/share/tesseract-ocr`); read-only at runtime. |

Draft expectations reconciled: the chart runs as UID 568 and read-only rootfs (compatible). Upstream runs as root, so the `jetty` user from upstream is ignored; the final stage must run as `apps`. Chart `/data` PVC maps to `/config/data`.

## 10. Risks, caveats and open questions

- The draft's java11 runtime is replaced by java25 (matches upstream). Confirm the teedy WAR runs on java25 in the build test.
- The draft's Maven build is replaced by the release WAR. The release `docs-web-1.12.war` is the artifact the upstream Dockerfile copies.
- Data path is UNVERIFIED (see section 1). This is the main blocker for the empty-`/config` start.
- DB: PostgreSQL optional. UNVERIFIED default DB (H2 vs external). If H2 is the default, the app starts with no DB; otherwise the container starts but `/` may not serve without a DB.
- ffmpeg and tesseract make large OCR and video jobs CPU and memory heavy (draft caveat, inferred). Keep `-Xmx1g` in view.
- Image size: ffmpeg plus tesseract language packs are large; choose the language set deliberately.
- Blockers: none confirmed. arm64: the WAR is arch-neutral and the base is multi-arch, but the java25 arm64 base is not checked in this plan (UNVERIFIED).

## 11. Build and test steps

```sh
cd apps/teedy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name teedy-probe --read-only --tmpfs /tmp \
  -v teedy-probe-config:/config teedy:1.12
docker logs -f teedy-probe
forgetool containers test --image teedy:1.12 --config ./apps/teedy/container-test.yaml
docker rm -f teedy-probe; docker volume rm teedy-probe-config
```

Readiness signals: Jetty logs `Started Server` and the WAR deployment (`docs` context) without exceptions; the port 8080 becomes reachable; `/config/data` is created on first start and survives a restart. Also run from outside the container (`-p 8080:8080`) to confirm the bind is not localhost.

## 12. PR checklist

- Branch `feat/add-teedy`, commit and PR title `feat(teedy): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Jetty `--read-only` start, the data path from v1.12, the PostgreSQL path, the arm64 build, and the Jetty and WAR checksums.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
