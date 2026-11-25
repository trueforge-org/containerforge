# pwm — implementation plan
> Source: ./draft.md · Target: apps/pwm/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 2.0.8 (GitHub tag `v2_0_8`, published 2025-02-22). Draft tag matches. Source: https://api.github.com/repos/pwm-project/pwm/releases/latest |
| Renovate | `datasource=github-releases depName=pwm-project/pwm versioning=semver`. Tags use underscores (`v2_0_8`); the build derives the tag from `VERSION` (`2.0.8` -> `v2_0_8`). |
| License | UNVERIFIED: GitHub reports `NOASSERTION` (license name "Other"). Read the repo `LICENSE` file and set `LICENSE` in `docker-bake.hcl` before building. |
| Source URL | https://github.com/pwm-project/pwm |
| Binary assets | https://github.com/pwm-project/pwm/releases/download/v2_0_8/pwm-2.0.8.war (WAR, platform independent), `pwm-onejar-2.0.8.jar`, `pwm-docker-image-2.0.8.tar` (upstream image, not used). |
| Checksum source | UNVERIFIED: no `.sha256` or checksum asset is listed on the release. Record the SHA-256 of the WAR at build time in the plan review, and say so in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/fjudith/pwm-container/master/alpine/Dockerfile (community image, not the pwm project's own). Builder `maven:3-openjdk-11` compiles pwm from source; runtime `tomcat:9-jre8-alpine`. Creates user `pwm` UID/GID 1234, installs JDBC drivers, deploys the WAR to `/` and `/ROOT` via `conf/server.xml` edits, `EXPOSE 8080`, `USER pwm`, `CMD ["catalina.sh","run"]`. ENTRYPOINT is commented out. |
| Port | 8080 (upstream `EXPOSE`). |
| Env vars (real) | `PWM_HOME=${CATALINA_HOME}/webapps/pwm`, `PWM_APPLICATIONPATH=/usr/share/pwm`, and the JDBC driver version pins (`MYSQL_DRIVER_VERSION`, `POSTGRES_DRIVER_VERSION`, `MONGODB_DRIVER_VERSION`, `MARIADB_DRIVER_VERSION`), which are build-time only. No runtime `PWM_*` configuration env was confirmed on a fetched page (UNVERIFIED). |
| Data path | `PWM_APPLICATIONPATH=/usr/share/pwm` (holds the configuration file and the local database). Chowned to the app user in upstream, not a declared `VOLUME`. |
| arm64 | No arm64 image or release asset is published upstream. The WAR and one-jar are platform-independent Java, so a JRE build on arm64 is feasible (inference, not fetched). |
| Docker Hub `fjudith/pwm` | Tags `debian`, `alpine`, `2.0.5-debian` (last updated 2023-04-11), amd64 only. Musl (alpine) build. `copy-from amd64: no`, `copy-from arm64: no`. |

## 2. Target layout

- `apps/pwm/Dockerfile`
- `apps/pwm/docker-bake.hcl`
- `apps/pwm/settings.yaml`
- `apps/pwm/start.sh`
- `apps/pwm/container-test.yaml`
- No `defaults/`, `etc/` or `DOWNSTREAM_CHANGES.md` unless the start script needs a seed file (decide after the Tomcat question in section 10). Never use `root/`.

## 3. Base image

Use the java8 base image as the `FROM` line, with its tag and digest copied from the existing java8 consumers in `apps/` (the `apps/java8` image itself is built from `ghcr.io/trueforge-org/ubuntu`, so do not copy its build). Confirm the exact tag and digest in `apps/java8/docker-bake.hcl` before writing it.

Reason: the upstream WAR needs Java 8 (the draft's tomcat jre8 choice). The java8 sibling is Ubuntu-based Temurin 8 with `JAVA_HOME=/opt/java/openjdk`, so it covers the runtime without the alpine/musl image. Closest sibling for the Java web-app shape: `apps/airsonic-advanced` (WAR deployed under a Tomcat `/run` dir, `USER apps`), which uses java17; the pwm plan uses java8 because the WAR is built for Java 8.

## 4. Dockerfile

1. `FROM <java8 sibling> `, `ARG VERSION`, `ARG TARGETARCH` (unused for the WAR but kept for parity), `USER root`.
2. Install Tomcat 9 without the upstream image. Plan: `apt-get install tomcat9` is not used (the Ubuntu tomcat9 layout differs from `CATALINA_HOME`). Preferred: download an official Apache Tomcat 9 binary tarball, verify its published SHA-512, extract to `/app/tomcat`. UNVERIFIED: exact Tomcat 9 version, the download URL and its checksum (not fetched; verify on archive.apache.org before writing).
3. `curl -fL https://github.com/pwm-project/pwm/releases/download/v${VERSION//./_}/pwm-${VERSION}.war -o /app/tomcat/webapps/pwm.war` (bash substitution, or pass `TAG` as a separate ARG). Record the WAR SHA-256 in a comment and check it in the build (see section 10).
4. Unpack the WAR to `/app/tomcat/webapps/pwm` at build time so `/app` is never written at runtime.
5. Configure Tomcat at build time (not runtime): change the connector to listen on 8080, and deploy `pwm` as the default context (`/`), as upstream's `server.xml` edit does. Keep the edit build-time only.
6. `ENV CATALINA_HOME=/app/tomcat PWM_HOME=/app/tomcat/webapps/pwm PWM_APPLICATIONPATH=/config/pwm CATALINA_TMPDIR=/tmp JAVA_OPTS="-Djava.io.tmpdir=/tmp"`. Note: upstream uses `/usr/share/pwm`; we move the application path to `/config/pwm` (persistent) so the config survives restarts.
7. Apt packages: only `xmlstarlet` if the build edits XML with it. Otherwise do the edit with `sed` or a short script, so no new apt packages. Pin any apt package against `VERSION` (not expected here).
8. `chown -R apps:apps /app` and `chmod -R 755 /app`, then `apt-get clean && rm -rf /var/lib/apt/lists/*`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/tomcat
CMD ["/app/tomcat/bin/catalina.sh", "run"]
```

Use `ENTRYPOINT ["/start.sh"]` (from the copied `start.sh`) if the start script is needed, and `exec` the Tomcat process from it (section 7).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pwm"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pwm-project/pwm versioning=semver
  default = "2.0.8"
}

variable "LICENSE" {
  default = "UNVERIFIED"  // set from the repo LICENSE file before build
}

variable "SOURCE" {
  default = "https://github.com/pwm-project/pwm"
}
```

Then the standard `group "default"` and the `image`, `image-local`, `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/pwm/`. The Dockerfile consumes `VERSION` through `ARG VERSION`, and both must stay `2.0.8`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pwm-project/pwm"
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
dependencies: []
```

Only env vars the app reads go here. No upstream runtime env was confirmed, so do not add `PWM_*` entries unless the fetched pwm docs confirm them (UNVERIFIED). `dependencies: []`: LDAP is an external directory the admin configures, not a required ContainerForge sibling; mark it as an optional note, not a dependency.

## 7. start.sh

- Runs as `apps`. Creates `/config/pwm` only when missing (`mkdir -p`). Does not seed a config file, because pwm's first launch uses its setup UI with a configuration password.
- Writes nothing under `/app`. Tomcat temp and work dirs go to `/tmp` (`CATALINA_TMPDIR`, `-Djava.io.tmpdir=/tmp`).
- Binds `0.0.0.0` (the Tomcat connector default address), so other containers can reach 8080.
- Ends with `exec /app/tomcat/bin/catalina.sh run`.
- UNVERIFIED: whether pwm needs its configuration password on each start (the draft says the setup UI stays locked without one). If so, read it from an env var in `start.sh` and apply it on every start, per the start-script rules. Do not invent the env var name; confirm it in the pwm docs first.

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
- /app/tomcat/webapps/pwm
- /app/tomcat/bin/catalina.sh
```

Every port in `settings.yaml` has a `tcp` probe. The `http` path must return a status the forgetool accepts; UNVERIFIED: pwm may redirect `/` to its setup page, so confirm the status code in the first local run and use the path that returns 200 (do not loosen the check).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/share/pwm` (`PWM_APPLICATIONPATH`, config and local DB) | `/config/pwm` (persistent `/config`). Existing users mounting the old path must move their data into `/config/pwm`. |
| Tomcat `work`, `temp` and `logs` | `/tmp` (`CATALINA_TMPDIR`). Logs go to stdout via Tomcat defaults (confirm in the run). |
| `$CATALINA_HOME` (`/app/tomcat`) | Read-only at runtime. Owned by `apps` for build-time writes only. |

Reconciled with the draft's security expectations: the chart runs as root (UID 0), with `readOnlyRootFilesystem: false`. The image runs as `apps` (non-root) and must pass `--read-only --tmpfs /tmp`. Not privileged. The draft's `/usr/share/pwm` extra persistence becomes `/config/pwm`. The chart's own PVC mount is not carried over.

## 10. Risks, caveats and open questions

- Tomcat 9 vs. the sibling: the upstream image uses `tomcat:9-jre8-alpine`. Tomcat is not in the ContainerForge base, so the Dockerfile installs it from the Apache tarball. Its version and checksum are UNVERIFIED (not fetched). Blocker until they are confirmed.
- Alternative (may be simpler): run `pwm-onejar-2.0.8.jar` directly with `java -jar` on the java8 base, which removes Tomcat entirely. UNVERIFIED: whether the one-jar starts a web server on a port and whether it needs a context path. Decide before writing the Dockerfile; check the pwm docs.
- Checksum: no checksum asset is published. The WAR's SHA-256 must be recorded when the plan is implemented.
- License: `NOASSERTION` upstream. Do not set `LICENSE` until the repo LICENSE file is read.
- The draft's `alpine` upstream image and the chart's `alpine` tag: the rebuilt image is glibc Ubuntu, so the runtime differs. The upstream JDBC drivers (MySQL, PostgreSQL, MongoDB, MariaDB) are only needed for external database backends. Leave them out of the image unless a user needs one, and say so in the PR.
- arm64: no upstream image. The one-jar or WAR path is platform-independent; needs a real arm64 build to confirm (untested).
- The draft's `/usr/share/pwm` path and the chart's `pvc` default are not the same as `/config/pwm`; migrating existing installs is a manual step to state in the PR.
- Startup: pwm's LDAP and configuration are external. The image must start with an empty `/config` and show the setup UI.

## 11. Build and test steps

```sh
cd apps/pwm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pwm-probe --read-only --tmpfs /tmp \
  -v pwm-probe-config:/config ${APP}:${VERSION}   # pwm:2.0.8
docker logs -f pwm-probe
forgetool containers test --image pwm:2.0.8 --config ./apps/pwm/container-test.yaml
docker rm -f pwm-probe; docker volume rm pwm-probe-config
```

Readiness signal: Tomcat logs `Server startup in [...] ms` and the pwm context deploys without errors. Also confirm port 8080 answers from outside the container (`-p 8080:8080`), not only from localhost. Run once more with a pre-populated `/config/pwm` to check the restart path.

## 12. PR checklist

- Branch `feat/add-pwm`, commit and PR title `feat(pwm): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Tomcat install and checksum, the WAR checksum, the license, arm64, the http probe status code, and the upgrade path from `/usr/share/pwm`.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no test assertion weakened.
