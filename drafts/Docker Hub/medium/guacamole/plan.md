# guacamole — implementation plan
> Source: ./draft.md · Target: apps/guacamole/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.6.0, released 2025-06-22 (Apache release page). Draft matches. No newer release was found on the Apache release page; a newer one is UNVERIFIED. |
| Docker Hub | `guacamole/guacamole` tags `1.6.0`, `1.6.0-RC1` to `RC3` (amd64, arm64); `1.6.0` last_updated 2025-06-23. |
| Renovate | Proposed: `datasource=docker depName=guacamole/guacamole versioning=semver`. Inferred: the war is on dlcdn.apache.org, which no Renovate datasource covers, so the Docker tag tracks the release. |
| License | Apache-2.0 expected for `apache/guacamole-client`. UNVERIFIED: the repository license API returned 403 in this run. Confirm from the LICENSE file before committing. |
| Source URL | https://github.com/apache/guacamole-client |
| Download | `https://dlcdn.apache.org/guacamole/1.6.0/binary/guacamole-1.6.0.war`. Architecture-independent: the same file serves amd64 and arm64. |
| Checksum | SHA-256 `b41ceb1e2df010b54db563e0b00edb8d5fe9f073c6168462e4c978df0fc6e716`, from `https://dlcdn.apache.org/guacamole/1.6.0/binary/guacamole-1.6.0.war.sha256`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/apache/guacamole-client/1.6.0/Dockerfile |
| Upstream builder | `maven:3-eclipse-temurin-21 AS builder` (installs Firefox for JS tests; runs `/opt/guacamole/bin/build-guacamole.sh`). |
| Upstream runtime | `tomcat:${TOMCAT_VERSION}-${TOMCAT_JRE}` with TOMCAT_VERSION=9, TOMCAT_JRE=jdk21. Installs XMLStarlet to edit `server.xml`. Copies `/opt/guacamole/` from the builder. |
| Upstream CMD | `["/opt/guacamole/bin/entrypoint.sh"]` (its content is UNVERIFIED for this run). |
| Upstream USER | `guacamole` (UID/GID 1001). |
| Upstream EXPOSE | `8080` (Tomcat). |
| Upstream VOLUME | None. |
| Upstream ENV | `BAN_ENABLED=true`, `ENABLE_FILE_ENVIRONMENT_PROPERTIES=true`, `GUACAMOLE_HOME=/etc/guacamole`. |
| Upstream build args | `MYSQL_JDBC_VERSION=8.3.0`, `PGSQL_JDBC_VERSION=42.7.2`, `MSSQL_JDBC_VERSION=9.4.1`, `MAVEN_ARGUMENTS`. |
| Port | `8080/tcp`. |
| Dependencies | `guacd` is a separate service that does the RDP/VNC/SSH work; the web app cannot proxy those protocols alone. PostgreSQL is optional (the JDBC auth backend). |
| arm64 | Yes: the war is arch-neutral, and Java 21 and Tomcat are available for arm64. |

## 2. Target layout

- `apps/guacamole/Dockerfile`
- `apps/guacamole/docker-bake.hcl`
- `apps/guacamole/settings.yaml`
- `apps/guacamole/container-test.yaml`
- `apps/guacamole/start.sh`
- `apps/guacamole/defaults/guacamole.properties` (seed file, copied to `/config/guacamole` only when missing, see section 7)

No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2`

Fits: Guacamole is a Java war, and ContainerForge has a Java 21 base, which matches the upstream `jdk21` runtime. The Java base is built on ubuntu, so Tomcat installs from apt on the same base. Closest siblings: `apps/airsonic-advanced` (war run on Tomcat from a java base, `USER apps`, `/config` state) and `apps/valkey` (pinned apt package and health dir).

## 4. Dockerfile

1. One stage only: the war is downloaded, not built. `FROM <java21 line>`.
2. `ARG VERSION`, `ARG TARGETARCH` (unused by the war, kept for the sibling pattern), `USER root`.
3. Tomcat 9 (matches the upstream image, `TOMCAT_VERSION=9`):
   - Preferred: `apt-get install -y --no-install-recommends tomcat9` if the ubuntu 26.04 archive ships it (UNVERIFIED). Pin the package version against the expected Tomcat 9 release, as `apps/valkey/Dockerfile` does, once the version is known.
   - Otherwise: download the Tomcat 9 tarball and verify its checksum (source UNVERIFIED).
   - Do not use Tomcat 10 (the draft's `tomcat10`): the upstream image is built on Tomcat 9.
4. Guacamole war, verified against the published SHA-256:

   ```dockerfile
   RUN curl -fL -o /tmp/guacamole.war \
       "https://dlcdn.apache.org/guacamole/${VERSION}/binary/guacamole-${VERSION}.war" && \
     echo "b41ceb1e2df010b54db563e0b00edb8d5fe9f073c6168462e4c978df0fc6e716  /tmp/guacamole.war" | sha256sum -c - && \
     mkdir -p /app/guacamole && \
     mv /tmp/guacamole.war /app/guacamole/guacamole.war
   ```

   The checksum is for 1.6.0 only. Make it an `ARG GUACAMOLE_SHA256` next to `VERSION` and pass it through `docker-bake.hcl`, so a bump cannot slip past the check.
5. JDBC driver for the optional PostgreSQL backend, `PGSQL_JDBC_VERSION=42.7.2`, copied into `/app/guacamole/lib/` (download URL and checksum UNVERIFIED for this run; take them from the upstream Dockerfile). Ship the driver's license file next to it.
6. The upstream image adds the PostgreSQL auth extension (`guacamole-auth-jdbc-postgresql`) only when it is configured. Decide whether to include it (UNVERIFIED: its version and download URL are not in the facts). If excluded, the `postgresql` option is not functional and this must go in the PR notes.
7. Environment:

   ```dockerfile
   ENV BAN_ENABLED=true \
     ENABLE_FILE_ENVIRONMENT_PROPERTIES=true \
     GUACAMOLE_HOME=/config/guacamole \
     CATALINA_BASE=/tmp/tomcat \
     CATALINA_TMPDIR=/tmp
   ```

   `GUACAMOLE_HOME` moves from the upstream `/etc/guacamole` to `/config/guacamole`, so the properties and drivers are persistent and writable under `/config` (section 9). `CATALINA_BASE` is `/tmp` because Tomcat writes `work/`, `temp/` and `logs/` there.
8. Final tail:

   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   ```

9. Clean apt lists and `/tmp/*`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "guacamole"
}

variable "VERSION" {
  // renovate: datasource=docker depName=guacamole/guacamole versioning=semver
  default = "1.6.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apache/guacamole-client"
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

- `LICENSE` `Apache-2.0` is expected, not confirmed (section 1).
- Add `variable "GUACAMOLE_SHA256"` with the checksum from section 1 and pass it as `args`.
- Copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/apache/guacamole-client"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: BAN_ENABLED
    default: "true"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
  - name: guacd
```

- `BAN_ENABLED` and `ENABLE_FILE_ENVIRONMENT_PROPERTIES` are upstream ENV values; `BAN_ENABLED` is listed because users set it. Do not invent others.
- `opt_dependencies: postgresql` is correct: `apps/postgresql` exists.
- `guacd`: `apps/guacd` does NOT exist in this repo (checked). Listing it under `opt_dependencies` is an open question: it is not a hard dependency (the web UI starts without it), but connections need it. Either add `apps/guacd` first (separate PR, not in this plan) or leave the entry out and state the gap in the PR. Do not list it under `dependencies:`.
- Admin account: `guacadmin` must be changed after first start (UI step). No env var for it is in the facts, so none is added.

## 7. start.sh

```bash
#!/usr/bin/env bash

set -euo pipefail

export GUACAMOLE_HOME="${GUACAMOLE_HOME:-/config/guacamole}"

mkdir -p "${GUACAMOLE_HOME}"/lib "${GUACAMOLE_HOME}"/extensions "${CATALINA_BASE}"/webapps
if [[ ! -f "${GUACAMOLE_HOME}/guacamole.properties" ]]; then
  cp /defaults/guacamole.properties "${GUACAMOLE_HOME}/guacamole.properties"
fi

cp /app/guacamole/guacamole.war "${CATALINA_BASE}/webapps/ROOT.war"
cp -r /usr/share/tomcat9/conf "${CATALINA_BASE}/"   # path UNVERIFIED

exec /usr/share/tomcat9/bin/catalina.sh run         # path UNVERIFIED
```

- Seeds `guacamole.properties` only when missing; never overwrites user state.
- Copies the war to `ROOT.war` so the app is served at `/`. Upstream context path is UNVERIFIED; confirm that `/` is the intended URL, or use `/guacamole`.
- Tomcat's layout under `CATALINA_BASE=/tmp/tomcat` is rebuilt on each start, which is fine because nothing persistent lives there.
- `defaults/guacamole.properties` contains only the guacd settings that are needed, e.g. `guacd-hostname: guacd` and `guacd-port: 4822` (4822 is guacd's usual port, UNVERIFIED for this run); add the JDBC settings only when the PostgreSQL extension is included.
- Bind address: Tomcat's default HTTP connector binds all interfaces; confirm in the probe (the instructions require listening outside localhost).

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
- /app/guacamole/guacamole.war
- /defaults/guacamole.properties
- /usr/share/licenses/guacamole/LICENSE
```

- `timeoutSeconds: 240` is taken from `apps/pwndrop/container-test.yaml`. Tomcat startup is UNVERIFIED for this image; confirm with the probe.
- The http probe on `/` is UNVERIFIED (depends on the `ROOT.war` decision in section 7).
- `/defaults/guacamole.properties` comes from `COPY --chmod=0755 . /` with `defaults/` in the repo folder. The license path needs a matching `COPY --from` or a `LICENSE` file under `defaults/` in the Dockerfile step (section 4 step 5); add it in the Dockerfile, or drop the entry.
- Run with no env vars (the test has none). The guacd-dependent paths are not exercised; document that in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or need | Remap |
| --- | --- |
| `GUACAMOLE_HOME=/etc/guacamole` (properties, drivers) | `/config/guacamole` (persistent, seeded in `start.sh`). |
| Tomcat `work/`, `temp/`, `logs/` | `CATALINA_BASE=/tmp/tomcat`, `CATALINA_TMPDIR=/tmp`. |
| guacd recordings (`/var/lib/guacamole/recordings`) | Written by guacd, not this image (draft, guacd sidecar). Not remapped here. |
| guacd drive (`/var/lib/guacamole/drive`) | Written by guacd, not this image. Not remapped here. |
| Upstream UID 1001 | Not used: ContainerForge `apps` runs the image (UID 568). |

Reconciled draft expectations: the chart runs main as `runAsUser 1001` and sets `readOnlyRootFilesystem: false`. This image runs as `apps` and works with `--read-only --tmpfs /tmp`, because Tomcat writes only under `/tmp`. Privileged: no. Extra persistence: `/var/lib/guacamole/recordings` and `/drive` belong to the guacd service; they are not part of this image.

## 10. Risks, caveats and open questions

- Tomcat version: the draft's `tomcat10` is replaced by Tomcat 9, matching the upstream `TOMCAT_VERSION=9`. The war is not checked against a newer Tomcat; keep 9.
- Tomcat package on ubuntu 26.04 is UNVERIFIED (section 4). If only Tomcat 10 is in the archive, stop and ask rather than switch versions.
- guacd is not in this repo. The main web UI starts without it, but RDP/VNC/SSH connections fail until guacd runs. This is the main blocker for a useful deployment (draft caveat, confirmed by the facts).
- PostgreSQL backend: the JDBC extension is a separate download (UNVERIFIED URL and version, section 4 step 6).
- Default `guacadmin` account must be changed after first start (manual UI step; the draft's caveat).
- arm64: the war is neutral and the base is arm64-capable; not tested in this run.
- Upstream `entrypoint.sh` content is UNVERIFIED. Its XMLStarlet `server.xml` edits (proxy settings) are not reproduced; decide whether they are needed (probably for reverse-proxy setups only).
- No blockers beyond guacd. No GPU, no privileged need, no musl-only binary.

## 11. Build and test steps

```sh
cd apps/guacamole
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name guacamole-probe --read-only --tmpfs /tmp \
  -v guacamole-probe-config:/config guacamole:1.6.0
docker logs -f guacamole-probe
forgetool containers test \
  --image guacamole:1.6.0 \
  --config ./apps/guacamole/container-test.yaml
docker rm -f guacamole-probe
docker volume rm guacamole-probe-config
```

- Readiness signal: Tomcat's "Server startup in ... ms" line (standard Tomcat message, UNVERIFIED for this image) and the process still running. Guacamole's own startup log must show no fatal error.
- Check that `/config/guacamole/guacamole.properties` appears on the empty volume and survives a restart.
- Check that the web UI answers on the declared port from outside the container (`-p 8080:8080`), so the bind is not localhost-only.
- Connection test (RDP/VNC/SSH) needs a running guacd; not covered by this protocol, say so in the PR.

## 12. PR checklist

- Branch `feat/add-guacamole`, commit `feat(guacamole): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required. Tell the user; only they can sign it at https://cla-assistant.io/trueforge-org/containerforge. The `license/cla` check shows the status.
- State honestly what is untested: guacd connections, the PostgreSQL backend, the Tomcat package version, the context path, the http probe status, the license id, and arm64.
- Check: `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
