# minecraft-java — implementation plan
> Source: ./draft.md · Target: apps/minecraft-java/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest stable | `2026.11.1` (published 2026-11-23), https://github.com/itzg/docker-minecraft-server/releases/tag/2026.11.1 |
| Draft tags | `2024.6.1-java17-jdk` and `2026.11.0-java11/java16` are stale. Hub shows `2026.11.1-java21` and `2026.11.1-java25-graalvm` (https://hub.docker.com/v2/repositories/itzg/minecraft-server/tags). Java 16/17 tags for 2026.11.x: UNVERIFIED (not in the newest page). |
| renovate | `datasource=github-releases depName=itzg/docker-minecraft-server versioning=loose` (CalVer tags, not semver) |
| License | Apache-2.0 (GitHub API, itzg/docker-minecraft-server). Minecraft server jar itself is Mojang EULA, not shipped in the image. |
| Source URL | https://github.com/itzg/docker-minecraft-server |
| Upstream Dockerfile reviewed | Pinned commit 1ccd6a0954f6 (draft link): `ARG BASE_IMAGE=eclipse-temurin:21-jre`; `build/run.sh install-packages` and `setup-user`; easy-add downloads of restify, rcon-cli, mc-monitor, mc-server-runner; mc-image-helper tgz from GitHub releases; `VOLUME ["/data"]`, `WORKDIR /data`; `ENV TYPE=VANILLA VERSION=LATEST EULA="" UID=1000 GID=1000`; `ENTRYPOINT ["/start"]`; `HEALTHCHECK CMD mc-health`. Latest master/2026.11.1 Dockerfile: UNVERIFIED (not re-fetched; the pins in the commit above are old). |
| Helper versions to use | easy-add `0.8.19` (assets `easy-add_linux_amd64`, `easy-add_linux_arm64`, checksums.txt); rcon-cli `1.7.9` (`rcon-cli_1.7.9_linux_amd64.tar.gz`, `_linux_arm64.tar.gz`, `rcon-cli_1.7.9_checksums.txt`); mc-monitor `1.18.3` (`mc-monitor_1.18.3_linux_amd64.tar.gz`, `_linux_arm64.tar.gz`, `checksums.txt`); mc-image-helper `1.76.0` (`mc-image-helper-1.76.0.tgz` + `.sha256`). These are the pins in the current itzg/mc-proxy Dockerfile; the server image's own pins for restify and mc-server-runner at 2026.11.1: UNVERIFIED. |
| Env vars (real) | `TYPE`, `VERSION`, `EULA` (must be `TRUE`), `UID`, `GID` (Dockerfile); `MEMORY` (default 1G), `INIT_MEMORY`, `MAX_MEMORY` (https://raw.githubusercontent.com/itzg/docker-minecraft-server/master/docs/configuration/jvm-options.md); RCON enabled by default (misc-options.md). `RCON_PASSWORD` name and default, RCON port: UNVERIFIED (not re-read). |
| Ports | `25565/tcp` (EXPOSE). RCON port: UNVERIFIED. |
| Data path | `/data` is the single volume for world and config (https://raw.githubusercontent.com/itzg/docker-minecraft-server/master/docs/data-directory.md). |
| arm64 | Base `eclipse-temurin` is multi-arch and Hub lists arm64 images for `itzg/minecraft-server`. |
| Dependencies | None. The server jar is downloaded at runtime (needs internet on first start). |
| Blockers | Mojang EULA must be accepted (`EULA=TRUE`). |

## 2. Target layout

- `apps/minecraft-java/Dockerfile`
- `apps/minecraft-java/docker-bake.hcl`
- `apps/minecraft-java/settings.yaml`
- `apps/minecraft-java/container-test.yaml`
- `apps/minecraft-java/start.sh` (the upstream `scripts/start*` wrapper is ported here, see section 7)
- `apps/minecraft-java/files/` is not needed unless the upstream `files/` templates are copied; add `defaults/` or `etc/` only when a file has to be seeded into `/config`, with the reason written in the PR.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Use the ContainerForge Java 21 runtime, matching the upstream default Java 21 image: `ghcr.io/trueforge-org/java21:21.0.8+9@sha256:<digest>`. The tag comes from `apps/java21/docker-bake.hcl` `VERSION`. The digest is UNVERIFIED: the brief's digest list has no java21 entry, so take it from the registry when the image is published. Alternative: `ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d` (matches upstream `2026.11.1-java25-graalvm`). Closest sibling: `apps/nzbhydra2` (Java runtime with `/config` and `USER apps`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG TARGETVARIANT`, `ARG EASY_ADD_VERSION=0.8.19`, `ARG RCON_CLI_VERSION=1.7.9`, `ARG MC_MONITOR_VERSION=1.18.3`, `ARG MC_HELPER_VERSION=1.76.0` (each with `// renovate:` / `# renovate:` annotation for github-releases).
2. `FROM` java21 line from section 3, `USER root` only for installs.
3. Install helpers with `easy-add` exactly like the upstream file, using the arch map `TARGETARCH${TARGETVARIANT}` (amd64, arm64 supported; armv7 not targeted). Verify each download against the release `checksums.txt` (`sha256sum -c`), and verify the mc-image-helper tgz against its `.sha256`.
4. Install mc-image-helper: `tar -C /usr/share -zxf` then `ln -s /usr/share/mc-image-helper-${MC_HELPER_VERSION}/bin/mc-image-helper /usr/bin/`.
5. Do NOT copy `setup-user` or `gosu`. The image runs as `apps` (568) and never changes user. Drop the upstream UID/GID remapping.
6. Copy upstream `files/` (for `/image`) and `scripts/` only if the port needs them; Log4jPatcher-1.0.1.jar comes from `https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar`. Checksum: none published on the page reviewed (UNVERIFIED). Pin the sha256 in the Dockerfile and check it with `sha256sum -c`, or drop the patcher if the server version does not need it (confirm in the readiness run).
7. License: copy the upstream LICENSE to `/usr/share/licenses/minecraft-java/LICENSE`.
8. Tail:

```dockerfile
ENV TYPE=VANILLA VERSION=LATEST EULA="" MEMORY=1G
USER apps
COPY --chmod=0755 . /

EXPOSE 25565
VOLUME /config
WORKDIR /config
```

`WORKDIR /data` in upstream is replaced by `/config` (see section 9). `VERSION` env name clashes with the upstream server VERSION env; keep the image `ARG VERSION` separate (the Dockerfile ARG is the image release, the env is the Minecraft version).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "minecraft-java"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=itzg/docker-minecraft-server versioning=loose
  default = "2026.11.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/itzg/docker-minecraft-server"
}
```

Then the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/java21/docker-bake.hcl`, with `args = { VERSION = "${VERSION}" }`. Validate with `docker buildx bake --print` in `apps/minecraft-java`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/itzg/docker-minecraft-server"
ports:
  - port: 25565
    protocol: tcp
    required: true
env:
  - name: TYPE
    default: "VANILLA"
    required: false
  - name: VERSION
    default: "LATEST"
    required: false
  - name: EULA
    default: ""
    required: true
  - name: MEMORY
    default: "1G"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `EULA` is `required: true` with an empty default: start.sh must refuse to start without `TRUE` and log why (see the open question in section 10).
- `dependencies:` none.
- Only list vars start.sh reads. Do not add RCON vars until they are verified (section 1 UNVERIFIED).

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Check `EULA`: if not `TRUE`, print that the Mojang EULA must be accepted and exit 1 (or keep the open question's decision, section 10).
- Seed: `mkdir -p /config`; copy the image's `/image` templates into `/config` only when the file is missing (never overwrite user state).
- Export `TYPE`, `VERSION`, `MEMORY` defaults from `settings.yaml`.
- Set `HOME=/tmp` and `TMPDIR=/tmp` so helper caches land in `/tmp` (protocol: caches go to `/tmp`).
- Bind the server to all interfaces (default for the server; verify `server.properties` `server-ip` is empty).
- `exec` the upstream wrapper (`/start` logic from `scripts/start`, ported to `/config` as working dir) so SIGTERM reaches Java. The upstream `scripts/start*` has not been read in this run: UNVERIFIED which parts reference `/data`, `/image`, `/auto` and `setup-user`. Port them with `/data` replaced by `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 600
tcp:
- port: '25565'
filePaths:
- /usr/bin/mc-image-helper
- /usr/local/bin/rcon-cli
- /usr/local/bin/mc-monitor
- /usr/share/licenses/minecraft-java/LICENSE
```

- The test runs with no env vars, so `EULA` is unset and the server will not start. The `tcp: 25565` probe only passes if the EULA path runs the server, so either the open question (section 10) is decided first, or the tcp probe is dropped in favour of filePaths only. Do not drop it silently.
- Java download of the server jar needs internet in CI. `timeoutSeconds: 600` covers the first download; confirm with sibling `apps/changedetection` (180) and adjust.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (world, server files, config, logs, helper state) | `/config` (persistent). Build-time symlink `/data -> /config` only if upstream scripts hard-code `/data`; otherwise change the scripts. |
| `/image`, `/auto` (copied templates) | Read-only in the image; start.sh copies to `/config` only when missing. |
| Helper temp, mc-image-helper cache, Log4jPatcher working files | `/tmp` (`HOME=/tmp`, `TMPDIR=/tmp`). |
| `setup-user`, `chown` of `/data` on start | Removed. The image runs as `apps` (568) and must own `/config` through the volume. |
| Upstream `UID`/`GID` env | Not supported: fixed UID 568. Remove from settings. |

Draft security expectations, reconciled: the chart expects runAsUser 568 (matches `USER apps`); `readOnlyRootFilesystem: true` is compatible with `--read-only --tmpfs /tmp`; privileged no; extra persistence `/data` becomes `/config`. Existing users must move their `/data` contents to `/config`.

## 10. Risks, caveats and open questions

- **EULA and tests (decision needed):** the container test runs without env vars, so the server cannot start without `EULA=TRUE`. Options: (a) start.sh stays up and logs "EULA not accepted" so the container runs, then tcp and http probes can not pass, filePaths only; (b) exit 1 and mark the app as a documented exception with the user's agreement. Recommended: (a) with filePaths and a clear log message, but this needs the user to decide.
- Upstream start scripts were not re-read at 2026.11.1 (section 1 UNVERIFIED). Their `/data` and `setup-user` assumptions drive the port work.
- First start downloads the server jar (large, needs internet). Heap needs RAM: `MEMORY=1G` default in upstream is small for modern servers.
- Java: the draft suggested java17, but upstream 2026.11.1 defaults to Java 21 and `java25-graalvm`; java21 chosen.
- Renovate on CalVer tags: the Dockerfile tag and the Minecraft version are separate; do not conflate them.
- Mojang EULA: the operator must accept it; the image must not accept it on the user's behalf.
- No arm64 test run yet (see section 11).

## 11. Build and test steps

```sh
cd apps/minecraft-java
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name minecraft-java-probe --read-only --tmpfs /tmp \
  -e EULA=TRUE -v minecraft-java-probe-config:/config minecraft-java:2026.11.1
docker logs -f minecraft-java-probe

forgetool containers test --image minecraft-java:2026.11.1 --config ./apps/minecraft-java/container-test.yaml

docker rm -f minecraft-java-probe; docker volume rm minecraft-java-probe-config
```

- Expected readiness signal: the server log line `Done (` followed by `For help, type "help"` after the jar download finishes. Also run once without `EULA` to confirm the refusal path behaves as decided in section 10.
- Also run with an empty `/config` volume, a restart on the same volume, and a port check from outside the container (`-p 25565:25565`).
- arm64 not tested unless the build is run with `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch `feat/add-minecraft-java`, commit `feat(minecraft-java): add new container`, PR title the same, target `main`.
- The CLA must be signed at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Notes section contains `🤖 This PR is AI generated.`; fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only boxes that apply.
- Say what was not tested: arm64, full server start if the EULA decision leaves the readiness path untested, upstream 2026.11.1 scripts, Log4jPatcher checksum.
- `docker buildx bake --print` passes; `VERSION` in bake equals the Dockerfile `ARG VERSION`; no assertion weakened.
