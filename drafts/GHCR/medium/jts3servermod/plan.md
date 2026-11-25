# jts3servermod — implementation plan
> Source: ./draft.md · Target: apps/jts3servermod/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No application release exists upstream. The only GitHub release on `galexrt/container-jts3servermod` is the Helm chart `jts3servermod-0.1.3` (2025-03-29). The draft tag `v20240301-172535-248` is a Docker image tag with no matching GitHub release (404). UNVERIFIED: which JTS3ServerMod version the vendor zip contains. Pin the image tag below as `VERSION`. |
| Renovate | UNVERIFIED: no release datasource for the application. Options to confirm before porting: `datasource=docker depName=ghcr.io/galexrt/jts3servermod versioning=loose` (tags not confirmed on a fetched page). |
| License (wrapper) | Apache-2.0 (GitHub SPDX, https://api.github.com/repos/galexrt/container-jts3servermod). UNVERIFIED: license of the JTS3ServerMod zip from stefan1200.de, which is the software actually shipped. Use the wrapper license for `LICENSE` until the zip license is confirmed. |
| Source URL | https://github.com/galexrt/container-jts3servermod |
| Download | Vendor zip `https://www.stefan1200.de/dlrequest.php?file=jts3servermod&type=.zip` (no version in the URL; used by upstream Dockerfile at commit `4ecf611553251cdafcb9176aeff42c2edaa609e0`). |
| Checksum source | None for the zip. Upstream verifies only Tini (`sha256sum -c` against Tini's `.sha256sum`). UNVERIFIED: a checksum for the zip, so the plan pins one after downloading it once and recording it in the Dockerfile (see section 4). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/galexrt/container-jts3servermod/4ecf611553251cdafcb9176aeff42c2edaa609e0/Dockerfile |
| Upstream base | `FROM openjdk:8-jre-buster` (Debian buster). ContainerForge uses its own `java8` sibling instead. |
| Upstream runtime | ENTRYPOINT `["/tini", "--"]`, CMD `["/entrypoint.sh"]`, USER `3000`, WORKDIR `/jts3servermod`, VOLUME `/jts3servermod/config`. No EXPOSE. |
| Upstream env (real) | `JTS3_DIR=/jts3servermod`, `JTS3_JAVA_ARGS=-Xmx256M`, `TINI_VERSION=v0.19.0`, `JTS3_USER=3000`, `JTS3_GROUP=3000`, `TINI_ARCH` (build arg, amd64), `ARCH` (build arg, empty). |
| Upstream layout | Unzips the vendor zip into `/jts3servermod`, removes `tools/`, `readme*`, `documents/`, `changelog.txt`, copies `config/` to `default_config/`, touches `JTS3ServerMod_InstanceManager.log`. |
| Ports | Draft: 9987/udp (voice), 10011/tcp (ServerQuery), 30033/tcp (file transfer). UNVERIFIED for this image: the upstream Dockerfile has no EXPOSE; the ports come from TeamSpeak 3 defaults and the draft. Confirm in the vendor docs before the settings file lists them. |
| Dependency | An external TeamSpeak 3 server. Not a ContainerForge app. No database. |
| arm64 | UNVERIFIED. Upstream Tini is arch-aware (`TINI_ARCH`). The vendor zip is a Java archive, so it is architecture-neutral, but the TeamSpeak plugin behaviour on arm64 is not tested. Treat as amd64-only until tested. |

## 2. Target layout

- `apps/jts3servermod/Dockerfile`
- `apps/jts3servermod/docker-bake.hcl`
- `apps/jts3servermod/settings.yaml`
- `apps/jts3servermod/container-test.yaml`
- `apps/jts3servermod/start.sh` (replaces upstream `entrypoint.sh`)
- `apps/jts3servermod/defaults/` only if a default `config/` seed is needed (reason: upstream ships `default_config`; copy it into `/config` only when missing). No `etc/`, `health/`, `root/`.
- No `DOWNSTREAM_CHANGES.md`: nothing uses this image as `FROM`.

## 3. Base image

`FROM ghcr.io/trueforge-org/java8:8@sha256:a245de24c11e3e79eec8dc598429a951c5bc71011f38a649d076816159b25ff5` (copied from an existing `apps/*/Dockerfile`). Fits because the app is a Java 8 jar plugin, and the java8 sibling already provides the JRE. Closest sibling: `apps/nzbhydra2` (Java app zip, USER apps, `/config` data) and `apps/java8` (the base itself, ubuntu-built).

Note: upstream runs on Debian buster `openjdk:8`, which is EOL. The java8 sibling is the ContainerForge choice; record that in section 10.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG ZIP_SHA256` (pinned checksum, see section 10).
2. `USER root`.
3. `apt-get install -y --no-install-recommends unzip` (not in java8 base; verify with `dpkg -l` in the build). Clean apt lists.
4. `mkdir -p /app/jts3servermod /defaults /tmp_download`.
5. Download the zip to `/tmp_download/jts3servermod.zip` with `curl -fsSL`, verify with `echo "${ZIP_SHA256}  /tmp_download/jts3servermod.zip" | sha256sum -c -`, then `unzip -q` into `/app/jts3servermod`.
6. Mirror the upstream cleanup: `rm -rf /app/jts3servermod/tools /app/jts3servermod/readme* /app/jts3servermod/documents /app/jts3servermod/changelog.txt`.
7. Move the seed: `mv /app/jts3servermod/config /defaults/jts3servermod-config`. Start-time seeding copies it into `/config` only when missing (section 7).
8. License: copy any `license`/`LICENSE` file from the zip (if present) to `/usr/share/licenses/jts3servermod/`. If none, write the wrapper license text from the upstream repo to the same path and note it in section 10.
9. `chown -R root:root /app /defaults && chmod -R 755 /app /defaults` (read-only at runtime).
10. `rm -rf /tmp_download/*`.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]
```

Set `ENV JTS3_JAVA_ARGS="-Xmx256M"` only if the app reads it; start.sh passes it to `java`. Do not copy upstream Tini or the `TINI_*` args: `exec` in start.sh handles PID 1 signals.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jts3servermod"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/galexrt/jts3servermod versioning=loose
  default = "v20240301-172535-248"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/galexrt/container-jts3servermod"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Renovate line is UNVERIFIED (section 1). `ARG VERSION` in the Dockerfile must match. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/galexrt/container-jts3servermod"
ports:
  - port: 9987
    protocol: udp
    required: true
  - port: 10011
    protocol: tcp
    required: false
  - port: 30033
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: JTS3_JAVA_ARGS
    default: "-Xmx256M"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: ✅ none
```

Port protocols: 9987 is UDP (voice), 10011 and 30033 are TCP. The `dependencies` entry is not a real dependency: remove it, and state in the summary that the TeamSpeak 3 server is external and not a ContainerForge app. Only list env vars that `start.sh` reads: `TZ` and `JTS3_JAVA_ARGS` (if start.sh uses it). Do not invent others. UNVERIFIED: whether the plugin reads any env var beyond these; check the vendor docs.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/logs

# seed default config only when missing
if [[ ! -d /config/config || -z "$(ls -A /config/config 2>/dev/null)" ]]; then
    cp -a /defaults/jts3servermod-config /config/config
fi

# the plugin writes its instance log in the app dir; point it at /config
touch /config/JTS3ServerMod_InstanceManager.log

cd /app/jts3servermod
exec java ${JTS3_JAVA_ARGS:--Xmx256M} -jar JTS3ServerMod.jar
```

Points to verify (UNVERIFIED): the jar name inside the zip, and whether the plugin writes into its own directory. If it does, symlink those paths to `/config` (for example `/app/jts3servermod/config` -> `/config/config`) so `/app` is never written at runtime. Bind 0.0.0.0 only if the plugin exposes a bind setting; the plugin connects outward to TeamSpeak, so this may not apply.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '10011'
filePaths:
- /app/jts3servermod
- /defaults/jts3servermod-config
- /usr/share/licenses/jts3servermod
```

Every settings port needs a probe, so the UDP port 9987 is not covered by `tcp`. UNVERIFIED: whether forgetool supports a `udp` probe; if not, record a narrowed assertion with the comment `# narrowed: udp probe not supported by container-test schema` and check 9987 manually in section 11. Port 30033 needs its own `tcp` probe only if the plugin listens on it at start. Test runs with no env vars, so the plugin should start without a TeamSpeak server; if it fails without one, narrow to a process-alive check with the protocol's DB-style comment (this is not a DB dependency, so the narrowing rule may not apply; confirm first).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/jts3servermod/config` (default_config copy, plugin config) | `/config` (seeded from `/defaults` only when missing) |
| `/jts3servermod/JTS3ServerMod_InstanceManager.log` | `/config/JTS3ServerMod_InstanceManager.log` (symlink or path change, see section 7) |
| `/jts3servermod/logs` (draft extra-persistence) | `/config/logs` |
| Java temp files | `/tmp` via `JAVA_OPTS`/`-Djava.io.tmpdir=/tmp` (add to start.sh) |

Draft expectations reconciled: the chart runs non-root with UID/GID 3000. This image runs as `apps` (568) per ContainerForge rules, so `/config` ownership must allow that UID (the entrypoint should not chown as root). `readOnlyRootFilesystem: false` in the chart is not required by this image; the target is `--read-only --tmpfs /tmp`. Not privileged.

## 10. Risks, caveats and open questions

- The application version is not pinned upstream. The vendor zip URL is unversioned, so a later upstream change would silently change the content. Pin a SHA-256 of the downloaded zip in the Dockerfile (`ZIP_SHA256`), and check it on every rebuild. UNVERIFIED: the checksum value, which needs one download to record.
- The zip comes from a third-party site with an old 2024 tag. The URL can vanish or change; keep a note in the PR.
- The base is Java 8 (java8 sibling). Upstream Debian buster openjdk:8 is EOL; the sibling is ours to maintain.
- Licensing: the wrapper is Apache-2.0; the vendor zip license is UNVERIFIED. Do not set `LICENSE` to a value the zip does not carry without confirming.
- arm64: UNVERIFIED. The TeamSpeak plugin may not run on arm64. Mark arm64 as untested in the PR.
- The plugin needs a TeamSpeak 3 server to do anything useful. The container can start without one, but the functional test is narrow.
- UDP 9987 must be exposed to clients; an HTTP probe does not apply.
- Blockers: none confirmed. No musl-only build, no GPU, no privileged need in the draft. The vendor download is the main risk.

## 11. Build and test steps

```sh
cd apps/jts3servermod
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name jts3servermod-probe --read-only --tmpfs /tmp \
  -v jts3servermod-probe-config:/config jts3servermod:v20240301-172535-248
docker logs -f jts3servermod-probe
forgetool containers test --image jts3servermod:v20240301-172535-248 --config ./apps/jts3servermod/container-test.yaml
docker rm -f jts3servermod-probe; docker volume rm jts3servermod-probe-config
```

Expected readiness signal: the plugin logs its startup banner and keeps running without a TeamSpeak server (UNVERIFIED wording; confirm from the first run). Check that `/config/config` is seeded on the first run and kept on restart. Check that UDP 9987 is reachable from outside the container with `-p 9987:9987/udp`, as a manual check because `tcp` probes do not cover it.

## 12. PR checklist

- Branch `feat/add-jts3servermod`, commit and PR title `feat(jts3servermod): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: arm64, UDP port reachability, the vendor zip checksum (until recorded), functional TeamSpeak connection, and the `--read-only` start if not run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
