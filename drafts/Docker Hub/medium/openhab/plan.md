# openhab — implementation plan
> Source: ./draft.md · Target: apps/openhab/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.2.5`, latest stable GitHub release (published 2026-11-18). `5.3.0.M5` is a milestone, not stable. Previous stable is `5.2.4`. The draft's chart image `openhab/openhab:5.2.5` matches. |
| Renovate | `datasource=github-releases depName=openhab/openhab-distro versioning=semver`. Proposed. Milestone tags such as `5.3.0.M5` do not parse as semver, so they are skipped. Repo convention is `versioning=loose` (76 uses), but loose may offer milestones. Choice UNVERIFIED against the team's policy. |
| License | `EPL-2.0` (GitHub repo license; upstream image label `org.opencontainers.image.licenses="EPL-2.0"`). |
| Source URL | https://github.com/openhab/openhab-distro |
| Download (noarch, same asset for amd64 and arm64) | https://github.com/openhab/openhab-distro/releases/download/5.2.5/openhab-5.2.5.tar.gz (confirmed in release asset list). Also `openhab-5.2.5.zip`. |
| Checksum source | None published on the release. Upstream Dockerfile downloads a zip from `openhab.jfrog.io` with no verification. UNVERIFIED that the jfrog zip is byte-identical to the GitHub asset. See section 10. |
| Upstream Dockerfile reviewed | https://github.com/openhab/openhab-docker/blob/045c5cfacb270a668f3384990b4dcc91235d109f/debian/Dockerfile (two stages, Debian 13 base, builds `su-exec`, starts as root and drops to `openhab`). |
| Ports (upstream `EXPOSE`) | 8080 (HTTP), 8443 (HTTPS), 8101 (Karaf console), 5007 (LSP). Which of these listen by default in this container is UNVERIFIED (needs a run). |
| Env (upstream `ENV`) | `CRYPTO_POLICY=limited`, `EXTRA_JAVA_OPTS`, `EXTRA_SHELL_OPTS`, `KARAF_EXEC=exec`, `OPENHAB_CONF=/openhab/conf`, `OPENHAB_HOME=/openhab`, `OPENHAB_HTTP_PORT=8080`, `OPENHAB_HTTPS_PORT=8443`, `OPENHAB_LOGDIR=/openhab/userdata/logs`, `OPENHAB_BACKUPS=/openhab/userdata/backup`, `OPENHAB_USERDATA=/openhab/userdata`, `TZ=Etc/UTC`, `USER_ID=9001`, `GROUP_ID=9001`, `LANG`/`LC_ALL`/`LANGUAGE=en_US.UTF-8`. `USER_ID`/`GROUP_ID` belong to the upstream entrypoint and are not used here. |
| Volumes (upstream `VOLUME`) | `/openhab/conf`, `/openhab/userdata`, `/openhab/addons` |
| Upstream start | `WORKDIR /openhab`, `CMD su-exec openhab tini -s ./start.sh`. `tini` is already in the ubuntu base (`ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]`). |
| Runtime dependencies | Java 21 JRE (provided by the `java21` base). Node.js for openHAB 5 (upstream installs it; the ubuntu base already ships Node `26.13.1` in `/usr/local`, per `apps/ubuntu/docker-bake.hcl`). Minimum Node version for openHAB 5 UNVERIFIED. No database. |
| Runtime fetch | Bindings and add-ons are installed from openHAB repositories on first start (draft; UNVERIFIED beyond the draft's note). |
| Architectures | Docker Hub `openhab/openhab:5.2.5` publishes linux/amd64 and linux/arm64 (active). |
| copy-from | `openhab/openhab:5.2.5` is Debian 13 glibc. Not used: the distro zip/tar.gz is noarch and a direct download is simpler. |

## 2. Target layout

- `apps/openhab/Dockerfile`
- `apps/openhab/docker-bake.hcl`
- `apps/openhab/settings.yaml`
- `apps/openhab/start.sh`
- `apps/openhab/container-test.yaml`

No repo `defaults/` folder: the default `conf/` is taken from the distro archive at build time and moved to `/defaults/conf` in the image. No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2` (digest and tag taken from `apps/doplarr/Dockerfile`, the only sibling using this image).

Fits: the draft names java21, and Temurin 21 JRE is what openHAB needs. The java21 image is built on the trueforge ubuntu base, so Node and tini come from the base layers. Closest sibling: `apps/nzbhydra2` (Java distro zip, `USER apps`, `/config` state). Do not reuse the upstream Debian 13 base.

## 4. Dockerfile

1. `FROM` line above. No `ARG TARGETARCH` needed (noarch).
2. `ARG VERSION` and, if section 10 is resolved as pinned hash, `ARG SHA256`.
3. `USER root`, then install the few supporting packages that upstream installs and the base lacks. Check the base first with `dpkg -l` (UNVERIFIED which ones are missing). Candidates from the upstream list: `fontconfig`, `iputils-ping`, `procps`. Do not install `su-exec`, `locales` (the base sets the locale), `tini` (in base) or `libcap2-bin` (`setcap` needs root at runtime; not privileged). These are not the app, so no version pin is needed.
4. Environment, with the upstream paths moved under `/config`:

```dockerfile
ENV \
  OPENHAB_HOME=/app/openhab \
  OPENHAB_CONF=/config/conf \
  OPENHAB_USERDATA=/config/userdata \
  OPENHAB_LOGDIR=/config/userdata/logs \
  OPENHAB_BACKUPS=/config/userdata/backup \
  OPENHAB_HTTP_PORT=8080 \
  OPENHAB_HTTPS_PORT=8443 \
  CRYPTO_POLICY=limited \
  HOME=/config
```

5. Download, verify and extract (tar.gz needs no extra package; the top-level layout of the tarball is UNVERIFIED, so check it before setting `--strip-components`):

```dockerfile
RUN set -eux; \
  mkdir -p /app/openhab /defaults /tmp/openhab; \
  curl -fsSL -o /tmp/openhab/openhab.tar.gz \
    "https://github.com/openhab/openhab-distro/releases/download/${VERSION}/openhab-${VERSION}.tar.gz"; \
  tar -xzf /tmp/openhab/openhab.tar.gz -C /app/openhab; \
  find /app/openhab \( -name '*.bat' -o -name '*.ps1' -o -name '*.psm1' \) -delete; \
  mv /app/openhab/conf /defaults/conf; \
  ln -s /config/addons /app/openhab/addons; \
  chown -R root:root /app/openhab /defaults; \
  chmod -R 755 /app/openhab /defaults; \
  rm -rf /tmp/openhab
```

   `openhab/userdata` is not in the archive (created at runtime). `/app/openhab/conf` is not kept, because `OPENHAB_CONF` points at `/config/conf`.
6. License: copy the archive's `LICENSE` to `/usr/share/licenses/openhab/` if it is present (UNVERIFIED). Otherwise use the repo `LICENSE` from the tag.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/openhab
```

   `EXPOSE` lists only 8080 until section 6 open ports are confirmed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "openhab"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openhab/openhab-distro versioning=semver
  default = "5.2.5"
}

variable "LICENSE" {
  default = "EPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/openhab/openhab-distro"
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

Validate with `docker buildx bake --print` from `apps/openhab`. If a pinned SHA256 is added, it needs its own renovate regex manager, because the github-releases manager does not update hashes.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/openhab/openhab-distro"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: EXTRA_JAVA_OPTS
    default: ""
    required: false
  - name: OPENHAB_HTTP_PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Ports 8443, 8101 and 5007 are not listed. Add each one only after a run with `ss -ltn` shows it listening, and add a matching probe (section 8).
- `OPENHAB_HTTP_PORT` is in the list only if openHAB reads it from the environment (UNVERIFIED; the value is from the upstream `ENV`).
- `CRYPTO_POLICY` is left out because nothing confirms that this image reads it.
- No dependency containers. Only the openHAB process runs, with embedded storage.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/conf /config/userdata/logs /config/userdata/backup /config/addons

# seed the default conf only when it is empty, never overwrite user state
if [ -z "$(ls -A /config/conf 2>/dev/null)" ]; then
  cp -a /defaults/conf/. /config/conf/
fi

cd /app/openhab
exec ./start.sh
```

- Idempotent. Writes only under `/config`. Nothing is written to `/app`.
- `exec` hands PID 1 to the distro `start.sh` (tini is the base ENTRYPOINT, so signals reach it).
- Whether the distro `start.sh` runs Karaf in the foreground and whether it reads `EXTRA_JAVA_OPTS` are UNVERIFIED. Confirm with the first run.
- Readiness signal: the Karaf "started" line is UNVERIFIED wording. The HTTP probe in section 8 is the reliable check.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/openhab/runtime/bin
- /app/openhab/start.sh
- /defaults/conf
- /usr/share/licenses/openhab
```

- `timeoutSeconds: 300` is a proposal. Siblings use 180 to 300; openHAB's first Karaf boot is slow.
- The `http` status the probe expects is UNVERIFIED. The upstream healthcheck uses `/`, but the first-run wizard may answer with a redirect. Use the path that returns the status forgetool accepts, and note it in the PR.
- `/app/openhab/runtime/bin` is listed because upstream copies its `update` script there (the directory exists in the distro).
- Probes for 8443, 8101 and 5007 are added only when section 6 lists those ports.
- No environment variables are needed to start, so no required-env paths exist.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this image |
| --- | --- |
| `/openhab/conf` | `/config/conf` through `OPENHAB_CONF`; seeded from `/defaults/conf` |
| `/openhab/userdata` (logs, backup, runtime data) | `/config/userdata` through `OPENHAB_USERDATA`, `OPENHAB_LOGDIR`, `OPENHAB_BACKUPS` |
| `/openhab/addons` | symlink `/app/openhab/addons -> /config/addons` (no env var for it) |
| Upstream `chown -R openhab` of `/openhab` at start | Not done. `/app` stays root-owned and read-only. |
| `su-exec` drop from root | Removed. The image runs as `apps` (568). |
| `setcap` on Java for `cap_net_raw` and `cap_net_admin` | Removed. The image is not privileged. Features that need raw sockets (ping-based discovery) may not work (UNVERIFIED). |
| `HOME` and caches | `HOME=/config`. Java temp files use the default `/tmp`. |

Draft security expectations reconciled:
- The chart runs as UID 0 and `readOnlyRootFilesystem: false`. The image is built for UID 568 and works with `--read-only --tmpfs /tmp`, so the chart values need a change (outside this app; tell the chart owner).
- The chart's two extra persistence paths (`/openhab/addons` and `/openhab/userdata`) both live under `/config` here, so one `/config` volume is enough.
- Privileged is not needed.
- The chart's `/etc/cont-init.d/enable-console-logging.sh` configmap has no target in this image (no s6). Drop it in the chart port.

## 10. Risks, caveats and open questions

- **Checksum.** GitHub publishes no checksum for the archive. Options: (a) pin a SHA256 that the implementer computes from the release asset and records in `docker-bake.hcl` with a custom renovate regex manager; (b) run without verification and say so in the PR. Decide before the PR. Default in this plan: (a).
- **Archive layout.** The top-level directory of `openhab-5.2.5.tar.gz` is UNVERIFIED. Check before the `tar` step.
- **Path env vars outside `OPENHAB_HOME`.** Upstream keeps conf and userdata under `/openhab`. Pointing them to `/config` is UNVERIFIED for this openHAB version. The read-only test will show it.
- **Hidden writes.** Karaf may write under `runtime/` or other paths in `/app/openhab`. Not verified. The `--read-only` run in section 11 is the check.
- **Node version.** The ubuntu base ships Node 26.13.1. The Node version required by openHAB 5 is UNVERIFIED. Confirm it is met.
- **First start.** Bindings and add-ons are installed at runtime, so the first start needs internet and is slow (draft note, UNVERIFIED).
- **Onboarding.** Setup happens in the web UI wizard, not through config files.
- **Karaf console.** Port 8101 must not be exposed without restriction. The default console credential is UNVERIFIED; change it before any exposure.
- **Ports.** 8443, 8101 and 5007 are open questions (section 6).
- **Blockers.** None found. The upstream Debian package set is not needed because the java21 base provides Temurin.

## 11. Build and test steps

```sh
cd apps/openhab
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openhab-probe --read-only --tmpfs /tmp \
  -v openhab-probe-config:/config openhab:5.2.5
docker logs -f openhab-probe
forgetool containers test --image openhab:5.2.5 --config ./apps/openhab/container-test.yaml
docker rm -f openhab-probe; docker volume rm openhab-probe-config
```

- Expected readiness: the first line from `start.sh`, then the openHAB start line (wording UNVERIFIED), then HTTP on 8080 with the status from section 8. Confirm that `/config/conf` is seeded and that a restart keeps it.
- Build arm64 only if the amd64 build fails for an arm64-only reason.
- Round limit: 10 (protocol). Do not weaken assertions.

## 12. PR checklist

- Branch `feat/add-openhab`, commit and PR title `feat(openhab): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- State as untested: arm64, the `--read-only` run (until done), first start with bindings, the HTTP status, ports 8443/8101/5007, and the checksum decision.
- `docker buildx bake --print` passes. `VERSION` in `docker-bake.hcl` equals `ARG VERSION` in the Dockerfile.
- No assertion weakened.
