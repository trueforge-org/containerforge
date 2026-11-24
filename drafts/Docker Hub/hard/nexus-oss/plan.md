# nexus-oss — implementation plan
> Source: ./draft.md · Target: apps/nexus-oss/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `3.98.3` (build `3.98.3-01`). Draft says 3.98.3, matches the Sonatype download page and Docker Hub tag `sonatype/nexus3:3.98.3` (verified). |
| Renovate | `datasource=docker depName=sonatype/nexus3 versioning=loose`. The `sonatype/nexus-public` GitHub releases/tags lag behind (latest tag seen: `release-3.98.1-01`), so they cannot drive the bump. The `-01` build suffix is not in the Docker tag, see section 10. |
| License | `EPL-1.0`. The tarball ships `OSS-LICENSE.txt` (Eclipse Public License v1.0) and `NOTICE.txt`; GitHub reports EPL-1.0 for `sonatype/nexus-public`. The download page also says it ships Sencha Ext JS under GPLv3 with a FLOSS exception. |
| Source URL | https://github.com/sonatype/nexus-public |
| amd64 download | https://download.sonatype.com/nexus/3/nexus-3.98.3-01-linux-x86_64.tar.gz (525 MB, HTTP 200) |
| arm64 download | https://download.sonatype.com/nexus/3/nexus-3.98.3-01-linux-aarch_64.tar.gz (523 MB, HTTP 200) |
| Checksum source | `<url>.sha256` next to each archive. Values seen: amd64 `498caf64f28538d1875abf2db2365273ff4a6abc55b37b29ded7d33e634f0d74`, arm64 `7d09e894505fdabb31fb1a748c06f81fe4844cd861c8967b73a5047bc8247c1b`. |
| Bundled runtime | The tarball contains `nexus-3.98.3-01/jdk/temurin_21.0.13_9_linux_x86_64/` (Temurin 21 JDK). Sonatype requires Java 21 since 3.87.0. The `java17` base from the draft is therefore wrong and not needed. |
| Archive layout | `nexus-3.98.3-01/{bin,etc,deploy,jdk,...}` plus a sibling `sonatype-work/nexus3/{tmp,log,clean_cache}`. |
| Launcher | `bin/nexus run`; JVM flags come from `bin/nexus.vmoptions` (`-Xms2703m -Xmx2703m`, `-Dkaraf.data=../sonatype-work/nexus3`, `-Dkaraf.log=../sonatype-work/nexus3/log`, `-Djava.io.tmpdir=../sonatype-work/nexus3/tmp`, `-XX:LogFile=../sonatype-work/nexus3/log/jvm.log`). |
| Port / bind | `etc/nexus-default.properties`: `application-port=8081`, `application-host=0.0.0.0`, `nexus-context-path=/`. Customisations belong in `<data-dir>/etc/nexus.properties`. |
| Upstream Dockerfile reviewed | `sonatype/docker-nexus3` `Dockerfile.java21` at `aa22a3b`: UBI9 base, user `nexus` uid 200, `NEXUS_DATA=/nexus-data`, `NEXUS_CONTEXT`, `INSTALL4J_ADD_VM_PARAMS` (javaprefs root under `/nexus-data/javaprefs`), `EXPOSE 8081`, `VOLUME /nexus-data`, `CMD bin/nexus run`, moves `sonatype-work/nexus3` to `/nexus-data` and symlinks it back. |
| Admin password | First start writes a generated password to `<data-dir>/admin.password` (draft caveat; UNVERIFIED in this review, taken from Sonatype docs knowledge). |
| Community Edition limits | Sonatype publishes usage limits for the free edition; the figures conflict between sources, UNVERIFIED (see section 10). |

## 2. Target layout

```
apps/nexus-oss/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/` needed: Nexus seeds its own `/config` content. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: the tarball carries its own Temurin 21 JDK for both architectures, so no `java*` base is required (and `java17` would be too old for 3.98). Using `java21` as base would duplicate a JDK. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu), with `apps/nzbhydra2` for a JVM app.

## 4. Dockerfile

1. `ARG VERSION`, `ARG BUILD=01`, `ARG TARGETARCH`; map arch: `amd64 -> x86_64`, `arm64 -> aarch_64`.
2. `USER root` only for the install `RUN`. No apt packages needed (curl and tar are in the base; verify with `docker run ... which curl tar` during build, add `ca-certificates` only if missing).
3. Download, verify, extract:
   ```dockerfile
   RUN set -eux; \
     case "${TARGETARCH}" in amd64) A=x86_64 ;; arm64) A=aarch_64 ;; *) exit 1 ;; esac; \
     U="https://download.sonatype.com/nexus/3/nexus-${VERSION}-${BUILD}-linux-${A}.tar.gz"; \
     curl -fsSL -o /tmp/nexus.tar.gz "${U}"; \
     echo "$(curl -fsSL "${U}.sha256" | awk '{print $1}')  /tmp/nexus.tar.gz" | sha256sum -c -; \
     tar -xzf /tmp/nexus.tar.gz -C /app; \
     mv "/app/nexus-${VERSION}-${BUILD}" /app/nexus; \
     rm -rf /app/sonatype-work/nexus3 /tmp/nexus.tar.gz; \
     ln -s /config /app/sonatype-work/nexus3
   ```
   The symlink makes every relative path in `nexus.vmoptions` (`../sonatype-work/nexus3/...`) land in `/config`, so `/app` is never written.
4. Licenses: `mkdir -p /usr/share/licenses/nexus-oss && cp /app/nexus/OSS-LICENSE.txt /app/nexus/NOTICE.txt /usr/share/licenses/nexus-oss/` (the files stay in `/app/nexus` too; copy is cheap).
5. `chown -R root:root /app && chmod -R a+rX /app` (read-only at runtime; `apps` only needs read and execute). Ensure `bin/nexus` and `jdk/*/bin/*` keep the executable bit.
6. `ENV` : `HOME=/config`, `LANG=en_US.UTF-8`. Keep JVM temp and prefs out of `/config` via `start.sh` (section 7).
7. `USER apps`, then `COPY --chmod=0755 . /` (final steps, as in `apps/adguardhome-sync`).
8. `EXPOSE 8081`, `VOLUME /config`, `WORKDIR /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "nexus-oss" }

variable "VERSION" {
  // renovate: datasource=docker depName=sonatype/nexus3 versioning=loose
  default = "3.98.3"
}

variable "BUILD" { default = "01" }
variable "LICENSE" { default = "EPL-1.0" }
variable "SOURCE" { default = "https://github.com/sonatype/nexus-public" }
```

`image` passes `args = { VERSION = "${VERSION}", BUILD = "${BUILD}" }` plus OCI labels `source` and `licenses`. Targets: `docker-metadata-action`, `image`, `image-local` (`output=["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print` in `apps/nexus-oss`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sonatype/nexus-public"
ports:
  - port: 8081
    protocol: tcp
    required: false
env:
  - name: INSTALL4J_ADD_VM_PARAMS
    default: "-Xms1g -Xmx2g"
    required: false
  - name: NEXUS_CONTEXT
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`INSTALL4J_ADD_VM_PARAMS` and `NEXUS_CONTEXT` are the names used by the upstream Docker image; `start.sh` implements both. No `dependencies:` (none; Nexus uses embedded H2/OrientDB data). Nothing to mark with a checkmark.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/etc /config/log /config/javaprefs

# Optional context path, written once per start without touching other settings
if [[ -n "${NEXUS_CONTEXT:-}" ]]; then
  touch /config/etc/nexus.properties
  grep -v '^nexus-context-path=' /config/etc/nexus.properties > /tmp/nexus.properties.new || true
  printf 'nexus-context-path=/%s\n' "${NEXUS_CONTEXT#/}" >> /tmp/nexus.properties.new
  cat /tmp/nexus.properties.new > /config/etc/nexus.properties
fi

# Later -D / -Xmx flags win over bin/nexus.vmoptions; temp and JVM log go to /tmp
export INSTALL4J_ADD_VM_PARAMS="${INSTALL4J_ADD_VM_PARAMS:--Xms1g -Xmx2g} -Djava.io.tmpdir=/tmp -XX:LogFile=/tmp/jvm.log -Djava.util.prefs.userRoot=/config/javaprefs"

cd /app/nexus
exec /app/nexus/bin/nexus run
```

Binding: `application-host=0.0.0.0` is the shipped default, so no override is needed. Nothing is written to `/app`. The admin password file `/config/admin.password` is created by Nexus itself.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8081'
http:
- port: '8081'
  path: /
filePaths:
- /app/nexus/bin/nexus
- /usr/share/licenses/nexus-oss/OSS-LICENSE.txt
```

Port 8081 has both a tcp and an http probe. Timeout is higher than `changedetection` (180) because Nexus takes minutes to boot. The `http`, `tcp`, `filePaths` and `timeoutSeconds` fields exist in the forgetool schema (verified). No env vars are needed for start-up. No DB dependency, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `sonatype-work/nexus3` (data, blobs, DB, `log`, `tmp`, `admin.password`, `etc/nexus.properties`) | symlink `/app/sonatype-work/nexus3 -> /config` (volume). |
| `java.io.tmpdir` (`../sonatype-work/nexus3/tmp`) | `/tmp` via `INSTALL4J_ADD_VM_PARAMS`. |
| `-XX:LogFile=.../log/jvm.log` | `/tmp/jvm.log`. |
| Java prefs (`~/.java`) | `HOME=/config`, plus `-Djava.util.prefs.userRoot=/config/javaprefs`. |
| `etc/` and `deploy/` under the install dir | Read at runtime; if Nexus tries to write into them, test fails in step 3 of the protocol, see section 10. |

Draft reconciliation: UID 200 from the chart does not matter, the image runs as `apps`; `/nexus-data` becomes `/config` (document the mount change for chart migration); read-only rootfs is achievable because all writes are in `/config` and `/tmp`; not privileged.

## 10. Risks, caveats and open questions

- Heap: the shipped `-Xms2703m -Xmx2703m` is overridden by the default `-Xms1g -Xmx2g`; small hosts still struggle (draft caveat).
- JVM flag precedence (later `-Xmx`/`-D` wins) is standard HotSpot behaviour but UNVERIFIED for the install4j launcher with `INSTALL4J_ADD_VM_PARAMS`; if it is ignored, copy `nexus.vmoptions` to `/tmp` and edit it, or run `java` directly.
- Whether Nexus writes anywhere else under `/app/nexus` (e.g. `etc/karaf`, `.install4j`) is UNVERIFIED; the read-only run in section 11 settles it.
- First-run admin password in `/config/admin.password`; document in the PR.
- Build suffix `-01`: the download URL needs the full `3.98.3-01`, but renovate tracks only `3.98.3`. A new release may bump the suffix; a failed download will show it. Keep `BUILD` as a separate bake variable.
- Community Edition usage limits (component/request caps) apply; the exact numbers conflict between Sonatype sources, UNVERIFIED. The bundled license text is EPL-1.0 but Sonatype may add Community Edition terms, UNVERIFIED.
- Large (about 525 MB) download per architecture; arm64 build is untested.
- Readiness log line expected around `Started Sonatype Nexus` (exact text UNVERIFIED); the HTTP probe on 8081 is the authority.

## 11. Build and test steps

```sh
cd apps/nexus-oss
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nexus-oss-probe --read-only --tmpfs /tmp \
  -v nexus-oss-probe-config:/config nexus-oss:3.98.3
docker logs -f nexus-oss-probe   # wait for the Started line, no stack traces
forgetool containers test --image nexus-oss:3.98.3 --config ./apps/nexus-oss/container-test.yaml
docker rm -f nexus-oss-probe; docker volume rm nexus-oss-probe-config
```

Expected: process stays up for several minutes, log shows the Nexus start banner, `curl http://localhost:8081/` answers, `/config/admin.password` exists. Test the second start on the same volume as well. Round limit 10.

## 12. PR checklist

- Branch `feat/add-nexus-oss`, commit and PR title `feat(nexus-oss): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; never sign for them).
- Untested until the build runs: arm64 build, JVM-flag precedence, read-only rootfs behaviour, readiness log text, community edition limits. Do not tick "Built container locally" unless it was built.
- Mention the `/nexus-data` to `/config` mount change.
