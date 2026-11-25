# metabase — implementation plan
> Source: ./draft.md · Target: apps/metabase/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.65.6`. Latest GitHub release `v0.65.6` (published 2026-11-18). Docker Hub also has `v0.65.7` and `v0.65.7.1` (pushed 2026-11-24), but no GitHub release for `v0.65.7` was found and its jar is UNVERIFIED, so this plan does not use it. The draft tag `v0.65.6` matches. |
| Renovate | `datasource=github-releases depName=metabase/metabase versioning=loose` (tags are `vX.Y.Z`, and Docker Hub shows 4-part tags such as `v0.65.7.1`, so `semver` is not safe). UNVERIFIED that Renovate handles the `v` prefix without a custom `extractVersion`; check on first run. |
| License | Draft says AGPL-3.0 for the OSS code. GitHub API reports `NOASSERTION` for the repo. The repo `LICENSE` file was not fetched, so AGPL-3.0 is UNVERIFIED on a fetched page. Use `AGPL-3.0` only after the file is read. |
| Source URL | https://github.com/metabase/metabase |
| Download (amd64 and arm64) | `https://downloads.metabase.com/v${VERSION}/metabase.jar`. HTTP 200, `application/java-archive`, content-length 714024897 (about 714 MB) for v0.65.6. The jar is architecture-neutral, so the same URL serves both arches. The GitHub release has no assets. |
| Checksum source | UNVERIFIED: no checksum file was found. The plan pins a SHA-256 computed from the first download (see section 4). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/metabase/metabase/v0.65.6/bin/docker/Dockerfile. Single stage on `eclipse-temurin:25-jre-alpine`. Installs packages and CA certs, then `COPY ./metabase.jar ./run_metabase.sh /app/`. Downloads the RDS CA bundle with curl at build time. `ENTRYPOINT ["/app/run_metabase.sh"]`, no CMD, no USER, no VOLUME, `EXPOSE 3000`. ENV `FC_LANG=en-US LC_CTYPE=en_US.UTF-8`, `GIT_COMMIT_SHA` ARG. No arch-specific logic. |
| Port | 3000 (upstream `EXPOSE 3000`, and the Metabase Docker docs). |
| Env vars (real) | From the Metabase Docker docs: `MB_DB_TYPE`, `MB_DB_DBNAME`, `MB_DB_PORT`, `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_HOST`, `MB_DB_CONNECTION_URI`, with `*_FILE` variants of the user and password. `JAVA_TIMEZONE` also exists. `FC_LANG`/`LC_CTYPE` are set by the upstream image. Any other name is UNVERIFIED. |
| Data path | Default app database is embedded H2 in the data path (`/metabase.db/metabase.db.mv.db` per the docs as recorded in the facts file). The draft's `/app/containername` layout does not match upstream, which uses `/app`. |
| Java | Upstream base is Temurin 25 JRE. The docs do not state the Java version. |
| Dependency | postgresql in ContainerForge: `apps/postgresql` exists (✅). It is optional, because H2 works without it. |
| Chart and tag | `docker.io/metabase/metabase:v0.65.6` (draft). |

## 2. Target layout

- `apps/metabase/Dockerfile`
- `apps/metabase/docker-bake.hcl`
- `apps/metabase/settings.yaml`
- `apps/metabase/container-test.yaml`
- `apps/metabase/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed: Metabase creates its own state on first start. No `root/` (never used). No `DOWNSTREAM_CHANGES.md`, because this image is not a `FROM` base for other apps (checked: no `apps/*/Dockerfile` uses `metabase`).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`

Fits because the app is a plain JVM jar, and the java25 sibling provides a JRE on the Ubuntu base. Upstream uses Temurin 25 on Alpine, so the Java major matches. Do not use the Alpine upstream base. Closest sibling: `apps/airsonic-advanced` (Java war on a java base, port, `/config` state, optional postgres as `opt_dependencies`).

## 4. Dockerfile

1. Single stage, `FROM` the java25 base above.
2. `ARG VERSION`. No `TARGETARCH`: the jar is architecture-neutral, and the arch-specific upstream logic is absent. Drop the ARG unless the build needs it.
3. `USER root` for the install step only.
4. Install apt packages only if the jar needs them at runtime. Upstream installs packages and CA certs in the Alpine image, which may not be needed on Ubuntu (UNVERIFIED which packages Metabase needs). Check first; do not add `apt-get` lines without a failure to justify them. If added, pin versions and check them against `VERSION`.
5. Download and verify the jar:

```dockerfile
RUN echo "*** Installing Metabase ***" && \
  mkdir -p /app/metabase && \
  curl -fL -o /app/metabase/metabase.jar \
    "https://downloads.metabase.com/v${VERSION}/metabase.jar" && \
  echo "${METABASE_JAR_SHA256}  /app/metabase/metabase.jar" | sha256sum -c - && \
  chown -R apps:apps /app && chmod -R 755 /app
```

   `METABASE_JAR_SHA256` is an `ARG` with no published source. The value has to be computed from a verified download (download twice from the same URL, compare, then pin). This is a caveat, not a verified checksum.
6. Optional RDS CA bundle (upstream downloads it for AWS RDS SSL): include only if a user needs RDS SSL. Not needed for the default H2 path. UNVERIFIED that the download URL still works.
7. License: `/usr/share/licenses/metabase/` with the upstream `LICENSE` file, fetched from `https://raw.githubusercontent.com/metabase/metabase/v${VERSION}/<license file>` (file name UNVERIFIED).
8. Caches and home: `ENV HOME=/config` as the other apps do. Java temp: `JAVA_TOOL_OPTIONS` must not point to `/config`. Use `-Djava.io.tmpdir=/tmp` in `start.sh`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /config
```

Do not add `CMD`: the entrypoint is in `start.sh`, run by the `COPY` rootfs layout.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "metabase"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=metabase/metabase versioning=loose
  default = "0.65.6"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/metabase/metabase"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

The `VERSION` default is `0.65.6` without the `v`, following `apps/adguardhome-sync`. The Dockerfile adds `v` in the URL. `LICENSE` stays `AGPL-3.0` only after the LICENSE file is read (section 1). Validate with `docker buildx bake --print`. `VERSION` in the Dockerfile `ARG` must equal this default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/metabase/metabase"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: JAVA_TIMEZONE
    default: "UTC"
    required: false
  - name: MB_DB_TYPE
    default: "h2"
    required: false
  - name: MB_DB_HOST
    default: ""
    required: false
  - name: MB_DB_PORT
    default: ""
    required: false
  - name: MB_DB_DBNAME
    default: ""
    required: false
  - name: MB_DB_USER
    default: ""
    required: false
  - name: MB_DB_PASS
    default: ""
    required: false
  - name: MB_DB_CONNECTION_URI
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

- `MB_DB_TYPE` default `h2` is the upstream default. Set it in `start.sh` only if the variable is unset.
- Do not list `*_FILE` variants unless `start.sh` reads them. If it does, add them with `default: ""`.
- `TZ` is a convention in sibling apps. Metabase's timezone variable is `JAVA_TIMEZONE`, so `TZ` is listed only if `start.sh` maps it to `JAVA_TIMEZONE`. Otherwise drop `TZ` (no invented env vars).
- `opt_dependencies` lists postgresql (✅, `apps/postgresql` exists). Use `opt_dependencies` (not `dependencies`), because H2 works without it.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/plugins

export MB_DB_TYPE="${MB_DB_TYPE:-h2}"
export JAVA_TIMEZONE="${JAVA_TIMEZONE:-UTC}"

cd /app/metabase
exec java \
  -Djava.io.tmpdir=/tmp \
  -jar /app/metabase/metabase.jar
```

- Idempotent: `mkdir -p` only creates what is missing, and no existing state is overwritten.
- Writes only under `/config` and `/tmp`. Nothing is written to `/app`.
- The H2 database file must go to `/config`. Set the path with the Metabase variable for the H2 file (UNVERIFIED name, not in the facts file; confirm against the docs before use). Without that, the default path is outside `/config`, and the container fails under `--read-only`.
- `plugins/` is a symlink target (section 9), so `/config/plugins` must exist.
- `JAVA_OPTS` is not in the facts file. Do not rely on it unless the upstream `run_metabase.sh` is read and confirmed (UNVERIFIED).
- Bind address: Metabase listens on the Jetty default (all interfaces, UNVERIFIED for this version). Check with the readiness log and a probe from outside the container.
- `exec` the java process so signals reach PID 1.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/metabase/metabase.jar
- /usr/share/licenses/metabase/LICENSE
```

- `timeoutSeconds: 300`: Metabase starts slowly (the draft says several minutes on first start). Siblings use 180 and 240. Measure the first start and adjust (UNVERIFIED value).
- `http path: /` may return a redirect to the setup page on first start. Use the status the probe sees; if a non-200 is returned, keep the probe but confirm the status (UNVERIFIED). Do not loosen the probe to pass.
- The test runs without env vars, so the H2 path is tested. The PostgreSQL path is not tested here (see section 11 for a manual check with a sidecar). `opt_dependencies` does not trigger the DB exception, because postgres is not a hard dependency and H2 starts on its own, so no narrowing is needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| H2 database (upstream default in the data path, `/metabase.db/...` per docs) | Set the H2 path to `/config` with the H2 variable (section 7). |
| `plugins/` (chart `/plugins` PVC; path UNVERIFIED for the jar) | Build-time symlink `/app/metabase/plugins` -> `/config/plugins`, created in `start.sh` if missing. Same pattern as `apps/fenrus`. |
| Java temp | `/tmp` via `-Djava.io.tmpdir=/tmp`. |
| `HOME` | `/config` as in sibling apps (UNVERIFIED that Metabase writes to `HOME`). |
| Anything else | UNVERIFIED: check the logs on `--read-only --tmpfs /tmp` and fix any further write path with a symlink into `/config`. |

Draft expectations, reconciled:
- Non-root: `apps` (UID 568), not the chart's default; the chart sets `runAsUser` to the common default, which matches.
- Read-only rootfs: compatible in principle, verified by the `--read-only --tmpfs /tmp` run (section 11). The chart's `readOnlyRootFilesystem` setting is not checked here.
- Privileged: no.
- Extra persistence: `/plugins` (draft) maps to `/config/plugins`. One PVC at `/config` is enough. Existing chart users must move their data into `/config`.

## 10. Risks, caveats and open questions

- Checksum: no published checksum for the jar. The pinned SHA-256 is computed from our own download, so it proves only that the file did not change after pinning.
- Version: `0.65.6` is the latest GitHub release. Docker Hub has `0.65.7` and `0.65.7.1`, with no matching GitHub release. Their jars and checksums are UNVERIFIED, so the plan does not use them. Renovate may propose them later; verify before merging.
- Jar size: about 714 MB. The image is large and the build is slow on the first pull. The jar is copied into the image, so the build needs the download to finish.
- H2 variable name and default path: UNVERIFIED in this plan (section 7).
- Startup time: several minutes on first start (draft, inferred). Timeout is a guess until measured.
- Setup wizard: admin account is created in the UI on first visit (draft, inferred). The test does not complete it.
- RDS CA bundle: not needed for the default path. Include only if RDS SSL is required.
- License: AGPL-3.0 is UNVERIFIED until the repo LICENSE file is read. `NOASSERTION` from the API.
- Blockers: none confirmed. Not musl-only (the upstream Alpine base is replaced by Ubuntu), no GPU, no privileged needs, arm64 image exists upstream (Docker Hub arm64 for the same tags).

## 11. Build and test steps

```sh
cd apps/metabase
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name metabase-probe --read-only --tmpfs /tmp \
  -v metabase-probe-config:/config metabase:0.65.6
docker logs -f metabase-probe
forgetool containers test --image metabase:0.65.6 --config ./apps/metabase/container-test.yaml
docker rm -f metabase-probe; docker volume rm metabase-probe-config
```

- Readiness signal: a Metabase startup line such as `Metabase Initialization COMPLETE` (UNVERIFIED: not taken from the facts; confirm from the first real log) plus the Jetty listen line on port 3000. The container must stay up.
- The protocol's DB exception does not apply. Run the full functional test.
- Optional manual check with PostgreSQL: start `apps/postgresql` on the same network and set `MB_DB_TYPE=postgres`, `MB_DB_HOST`, `MB_DB_DBNAME`, `MB_DB_USER`, `MB_DB_PASS`. Report this as a manual step, not a CI test.
- Check from outside the container (`-p 3000:3000`) that the port is reachable.

## 12. PR checklist

- Branch `feat/add-metabase`, commit and PR title `feat(metabase): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: the jar checksum (computed, not published), the H2 variable name, `plugins/` path, the RDS CA bundle, the PostgreSQL path, arm64 (unless built), and any Renovate behaviour for `v`-prefixed tags.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
