# notarius — implementation plan
> Source: ./draft.md · Target: apps/notarius/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.1-2` (latest GitHub release, published 2020-08-29). Only three releases exist (1.1-2, 1.1, 1.0). Draft tag `1.1-2`: same. |
| Source pom version | `1.0.3-SNAPSHOT` (not a release). The master Dockerfile expects `target/Notarius-1.0.3-SNAPSHOT.war`. |
| Docker Hub | `agusalex/notarius`: 16 tags, latest last_updated 2020-09-23, amd64 listed. Chart: `docker.io/agusalex/notarius:latest@sha256:ac7f357f...`. |
| Renovate | UNVERIFIED in repo config. Recommended: `datasource=github-releases depName=agusalex/Notarius versioning=loose` (tag `1.1-2` is not strict semver, so `loose` per the bake rule). |
| License | GPL-3.0 (GitHub API SPDX). |
| Source URL | https://github.com/agusalex/Notarius (not archived; last pushed 2023-11-20) |
| Download | `https://github.com/agusalex/Notarius/releases/download/1.1-2/ROOT.war` (only release asset). The WAR is architecture-neutral. |
| Checksum source | None published with the release. Record the sha256 of the downloaded file in the plan at build time; this is not an upstream checksum. |
| Upstream Dockerfile reviewed | https://github.com/agusalex/Notarius/blob/master/Dockerfile: `FROM tomcat:jre8-alpine` (single stage, musl), removes `/usr/local/tomcat/webapps/`, copies `target/Notarius-1.0.3-SNAPSHOT.war` to `webapps/ROOT.war`. Needs a Maven build; there is no WAR in the repo. No USER, EXPOSE, ENTRYPOINT or VOLUME (tomcat image defaults). |
| Port | 8080 is Tomcat's default connector port in the tarball that we ship (verified at build time in `conf/server.xml`). The WAR itself does not declare a port (UNVERIFIED). |
| Env vars | None read by the WAR is verified. No env vars are listed in settings.yaml. |
| Data and log paths | UNVERIFIED: whether the WAR writes data anywhere. Tomcat writes logs, work and temp under its base directory. |
| Chart | TrueCharts `charts/stable/notarius` 11.0.0. Service `main` disabled, probes disabled, `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. |
| Dependencies | None found. |

## 2. Target layout

- `apps/notarius/Dockerfile`
- `apps/notarius/docker-bake.hcl`
- `apps/notarius/settings.yaml`
- `apps/notarius/container-test.yaml`
- `apps/notarius/start.sh`

No `defaults/`, `etc/` or `root/`: Tomcat config comes from the tarball, and `start.sh` builds the Tomcat base in `/tmp`. No `DOWNSTREAM_CHANGES.md`: notarius is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/java8:8@sha256:a245de24c11e3e79eec8dc598429a951c5bc71011f38a649d076816159b25ff5`

Copied from the existing `FROM` lines in `apps/davos/Dockerfile` and `apps/habridge/Dockerfile`. The java8 image provides a JRE 8 on ubuntu (`apps/java8/Dockerfile`), which matches the chart's jre8 intent. The java8 image does not include Tomcat, so Tomcat must be added. Closest siblings: `apps/davos` and `apps/habridge` (java8 consumers). For a WAR served by a bundled server, `apps/airsonic-advanced` is the closest pattern (it runs its WAR directly from `/app`).

## 4. Dockerfile

1. Single stage: `FROM <java8>`. No build stage, because the release `ROOT.war` is prebuilt. No Maven.
2. `ARG VERSION` (`1.1-2`), `ARG TOMCAT_VERSION` (value UNVERIFIED; see section 10). `USER root`.
3. Tomcat install (URL and checksum source UNVERIFIED for this plan; Apache publishes a `.sha512` next to each tarball):

```dockerfile
RUN set -eux; \
    curl -fL -o /tmp/tomcat.tar.gz \
      "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"; \
    curl -fL -o /tmp/tomcat.tar.gz.sha512 \
      "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512"; \
    echo "$(cut -d' ' -f1 /tmp/tomcat.tar.gz.sha512)  /tmp/tomcat.tar.gz" | sha512sum -c -; \
    mkdir -p /app/tomcat; \
    tar -xzf /tmp/tomcat.tar.gz -C /app/tomcat --strip-components=1; \
    rm -rf /app/tomcat/webapps/* /app/tomcat/logs /app/tomcat/temp /app/tomcat/work; \
    rm -f /tmp/tomcat.tar.gz /tmp/tomcat.tar.gz.sha512
```

   Use the tomcat-9 path only if the WAR needs Servlet 3.x/4.x on Java 8 (UNVERIFIED). Confirm before the build.

4. WAR: `mkdir -p /app/notarius && curl -fL -o /app/notarius/ROOT.war "https://github.com/agusalex/Notarius/releases/download/1.1-2/ROOT.war"`, then `sha256sum` recorded in the plan (no upstream checksum).
5. Licenses: `COPY` the Notarius `LICENSE` (file name UNVERIFIED, check the repo root) to `/usr/share/licenses/notarius/LICENSE`, and the Tomcat `LICENSE` from the tarball to `/usr/share/licenses/tomcat/LICENSE`.
6. `chmod -R 755 /app` (root-owned, read-only at runtime).
7. `ENV CATALINA_HOME=/app/tomcat CATALINA_TMPDIR=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "notarius"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=agusalex/Notarius versioning=loose
  default = "1.1-2"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/agusalex/Notarius"
}
```

Then the default group and the four standard targets copied from `apps/adguardhome-sync/docker-bake.hcl`. `ARG VERSION` in the Dockerfile must equal this value. Tomcat version is a separate `ARG` with its own pin, not a bake variable (UNVERIFIED whether a second variable is wanted). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/agusalex/Notarius"
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
```

No dependencies. No env vars beyond TZ, because none is verified. `/config` is declared as the common volume; it is only used if the WAR is shown to persist state (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

# Tomcat base lives in /tmp: it is rebuilt on every start, so /app stays read-only.
base=/tmp/catalina-base
rm -rf "${base}"
mkdir -p "${base}"/conf "${base}"/logs "${base}"/temp "${base}"/webapps "${base}"/work
cp -r /app/tomcat/conf/. "${base}/conf/"
cp /app/notarius/ROOT.war "${base}/webapps/ROOT.war"

export CATALINA_BASE="${base}"
exec /app/tomcat/bin/catalina.sh run
```

- Idempotent: nothing in `/config` is needed, so an empty `/config` works.
- No writes to `/app`. Tomcat's logs, work and temp are all under `/tmp`.
- `exec` hands PID 1 to Tomcat so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/tomcat/bin/catalina.sh
- /app/notarius/ROOT.war
- /usr/share/licenses/notarius/LICENSE
```

- Every settings port has a probe (8080 tcp, plus http).
- The http status for `/` is UNVERIFIED. Check it on the first run. If the WAR returns non-200, use the path it serves with 200. Do not weaken the probe.
- No env vars are set in the test, so no required-env path is needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/local/tomcat/webapps` (WAR deployed here) | `/tmp/catalina-base/webapps` (copied in `start.sh`) |
| `/usr/local/tomcat/logs`, `temp`, `work` | `/tmp/catalina-base/{logs,temp,work}`, `CATALINA_TMPDIR=/tmp` |
| WAR data or state (UNVERIFIED whether any) | Not mapped yet. If the WAR writes state, move it to `/config` and document it. |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem false`. This image runs as `apps` (568) and is compatible with `--read-only --tmpfs /tmp`, so the chart's root override is not needed. Not privileged.

## 10. Risks, caveats and open questions

- Release WAR versus master: the only release asset is `ROOT.war` from 1.1-2 (2020). The master Dockerfile copies `Notarius-1.0.3-SNAPSHOT.war`, which is not a release. The plan uses the release asset, so the image is built from the older source state. Confirm with the author that this is acceptable.
- Tomcat version and Servlet API: the WAR's required Servlet API and Java level are UNVERIFIED. Tomcat 9 is the assumed line for Java 8; confirm that the WAR runs on it.
- Tomcat download URL and checksum source are UNVERIFIED for this plan (Apache publishes `.sha512` files next to each tarball).
- No upstream checksum for `ROOT.war`. Record the sha256 at build time and state that it is not upstream-verified.
- Ports, data paths and the WAR's HTTP root status are UNVERIFIED until the first run.
- Project activity: last push 2023-11-20, last Docker Hub image 2020. Expect little upstream activity (inferred).
- arm64: the WAR is neutral, and the java8 base arm64 status was not checked here. Build amd64 first.
- Licence: GPL-3.0 applies to the WAR; ship its license file.
- No blockers beyond the Tomcat and WAR version checks.

## 11. Build and test steps

```sh
cd apps/notarius
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name notarius-probe --read-only --tmpfs /tmp \
  -v notarius-probe-config:/config notarius:1.1-2
docker logs -f notarius-probe
forgetool containers test \
  --image notarius:1.1-2 \
  --config ./apps/notarius/container-test.yaml
docker rm -f notarius-probe; docker volume rm notarius-probe-config
```

Expected readiness signal: Tomcat's `Server startup in [...] ms` line in the log, and `Deployment of web application archive ... ROOT.war` (standard Tomcat lines, not verified for this WAR). Test from outside the container (`-p 8080:8080`) to confirm the connector binds to all interfaces.

## 12. PR checklist

- Branch `feat/add-notarius`, commit and PR title `feat(notarius): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say honestly what is untested: the Tomcat version choice, the WAR's behaviour under `--read-only`, arm64, the http status, and the ports.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
