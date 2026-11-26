# minecraft-proxy — implementation plan
> Source: ./draft.md · Target: apps/minecraft-proxy/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest stable | `2026.11.2` (published 2026-11-22), https://github.com/itzg/docker-mc-proxy/releases/tag/2026.11.2 |
| Draft tag | `2026.11.1-java17` is older. Hub tags: `latest`, `java8`, `java17`, `java21`, `java25` (https://hub.docker.com/v2/repositories/itzg/mc-proxy/tags). Whether `2026.11.1` still exists: UNVERIFIED. |
| renovate | `datasource=github-releases depName=itzg/docker-mc-proxy versioning=loose` (CalVer) |
| License | Apache-2.0 (GitHub API, itzg/docker-mc-proxy). Velocity itself is GPL-3.0 (gh api, PaperMC/Velocity) and is downloaded at runtime, not shipped in the image. |
| Source URL | https://github.com/itzg/docker-mc-proxy |
| Upstream Dockerfile reviewed | Pinned commit 89a7d3ad7dc6 (draft link): `ARG BASE_IMAGE=eclipse-temurin:25-jre`; `VOLUME ["/server"]`; `WORKDIR /server`; `build/install-packages.sh`; `COPY --from=tianon/gosu /gosu`; `build/setup-user.sh`; easy-add `0.8.19`, mc-monitor `1.18.3`, rcon-cli `1.7.9`, mc-image-helper `1.76.0` (all renovate-annotated); `COPY templates/ /templates/`; `ENV RCON_PORT=25575 MEMORY=512m`; `EXPOSE 25577 25565`; `CMD ["/usr/bin/run-bungeecord.sh"]`; `HEALTHCHECK CMD /usr/bin/health.sh`; `COPY --chmod=755 /scripts/* /usr/bin/`. |
| Env vars (README, https://raw.githubusercontent.com/itzg/docker-mc-proxy/main/README.md) | `TYPE` (BUNGEECORD default; WATERFALL, VELOCITY, CUSTOM); `VELOCITY_VERSION=latest`; `VELOCITY_BUILD_ID=latest`; `MEMORY=512m`, `INIT_MEMORY`, `MAX_MEMORY`; `PUID=1000`, `PGID=1000`; `SKIP_CHOWN_DATA=false`; `SKIP_PRIVILEGE_DROP`; `BUNGEE_HOME` (default `/server`); `ENABLE_RCON`; `RCON_PORT`; `RCON_PASSWORD`; `SERVER_PORT`; `HEALTH_HOST=localhost`; `ONLINE_MODE`; `ICON`; `PLUGINS_FILE`; `DOWNLOAD_EXTRA_CONFIGS`; `ENABLE_JMX=false`; `BUNGEE_JAR_URL`, `BUNGEE_JAR_FILE`. Forwarding secret variable: UNVERIFIED (not located). |
| Paths (README) | `/server` (working dir, holds `config.yml` for Bungee); `/plugins`; `/config` (synced into `/server`, variables replaced unless `REPLACE_ENV_DURING_SYNC=false`). |
| Ports | `25577/tcp` (BungeeCord default), `25565/tcp` (Velocity default). Draft lists 25577 only: the Velocity port is needed for `TYPE=VELOCITY`. |
| Helper asset versions | easy-add `0.8.19` (`easy-add_linux_amd64`, `_arm64`, `checksums.txt`); mc-monitor `1.18.3` (`mc-monitor_1.18.3_linux_amd64.tar.gz`, `_arm64`, `checksums.txt`); rcon-cli `1.7.9` (`rcon-cli_1.7.9_linux_amd64.tar.gz`, `_arm64`, `rcon-cli_1.7.9_checksums.txt`); mc-image-helper `1.76.0` (`.tgz` + `.sha256`). Via `gh api` (unauthenticated REST returned 403). |
| Velocity | Latest `4.3.1` (https://github.com/PaperMC/Velocity/releases/tag/v4.3.1). PaperMC fill API: `https://fill.papermc.io/v3/projects/velocity/versions/4.3.1/builds/latest` gives `velocity-4.3.1-45.jar`, sha256 `0844bcabdcdb4f5b875906fd4c3365bc1bb76918e42bc595ed88ad195258dd75`, 42342611 bytes, from `https://fill-data.papermc.io/v1/objects/0844bcabdcdb4f5b875906fd4c3365bc1bb76918e42bc595ed88ad195258dd75/velocity-4.3.1-45.jar`. `api.papermc.io/v2` is sunset (HTTP 410): do not use. |
| Java tags | README table: `java25` amd64, arm64; `java21` amd64, arm64; `java17` amd64, arm64, armv7; `java8` amd64, arm64, armv7. Deprecated: java11, java24. |
| arm64 | Yes: listed in the README table and Hub. |
| Dependencies | None inside ContainerForge. Needs backend Minecraft servers (external). |

## 2. Target layout

- `apps/minecraft-proxy/Dockerfile`
- `apps/minecraft-proxy/docker-bake.hcl`
- `apps/minecraft-proxy/settings.yaml`
- `apps/minecraft-proxy/container-test.yaml`
- `apps/minecraft-proxy/start.sh` (replaces `run-bungeecord.sh`, `health.sh` port logic is folded in when needed)
- `templates/` is NOT copied into the image: `include/.dockerignore` is an allow-list without `templates/`. If the upstream templates are needed, place them under `defaults/` (copied to `/defaults`) and seed from there; add `defaults/` only when a file must be seeded into `/config`, with the reason in the PR.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Use `ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`. It matches upstream's `eclipse-temurin:25-jre` base for the pinned commit. Alternative `ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a` (draft's first choice): fine if Velocity 4.3.1 runs on Java 17 (UNVERIFIED; check the Velocity docs before choosing it). Closest sibling: `apps/nzbhydra2` (Java runtime, `/config`, `USER apps`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG TARGETVARIANT`, `ARG GITHUB_BASEURL=https://github.com`, and the renovate-annotated pins: `EASY_ADD_VERSION=0.8.19`, `MC_MONITOR_VERSION=1.18.3`, `RCON_CLI_VERSION=1.7.9`, `MC_HELPER_VERSION=1.76.0`.
2. `FROM` java25 line from section 3. `USER root` only for installs (apt, easy-add, mc-image-helper), then `USER apps`.
3. Install the helpers with easy-add (same as upstream), arch map `TARGETARCH${TARGETVARIANT}`, and check each against the release `checksums.txt`.
4. Install mc-image-helper with `tar -C /usr/share -zxf -`, then symlink to `/usr/bin/mc-image-helper`. Verify the tgz against its `.sha256` first.
5. Drop `gosu` and `setup-user.sh`. The image runs as `apps` (568); the upstream UID switch is not used.
6. Velocity and Bungee jars are downloaded at runtime by mc-image-helper, so no jar is baked in. Record the Velocity sha256 above in the PR for review; the helper's own check is UNVERIFIED.
7. License: copy upstream `LICENSE.md` to `/usr/share/licenses/minecraft-proxy/LICENSE`.
8. Tail:

```dockerfile
ENV RCON_PORT=25575 MEMORY=512m BUNGEE_HOME=/config
VOLUME ["/config"]
WORKDIR /config
USER apps
COPY --chmod=0755 . /

EXPOSE 25577 25565
```

`BUNGEE_HOME=/config` uses the documented variable (README: `$BUNGEE_HOME`, default `/server`), so the working dir and jars live in the writable volume. Also set `SKIP_CHOWN_DATA=true` in `start.sh` (non-root cannot chown).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "minecraft-proxy"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=itzg/docker-mc-proxy versioning=loose
  default = "2026.11.2"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/itzg/docker-mc-proxy"
}
```

Then the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/java21/docker-bake.hcl`, with `args = { VERSION = "${VERSION}" }`. Run `docker buildx bake --print` in `apps/minecraft-proxy`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/itzg/docker-mc-proxy"
ports:
  - port: 25577
    protocol: tcp
    required: true
  - port: 25565
    protocol: tcp
    required: false
env:
  - name: TYPE
    default: "BUNGEECORD"
    required: false
  - name: VELOCITY_VERSION
    default: "latest"
    required: false
  - name: VELOCITY_BUILD_ID
    default: "latest"
    required: false
  - name: MEMORY
    default: "512m"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only list env vars `start.sh` actually reads. Add `RCON_PASSWORD`/`ENABLE_RCON` only after the README default is verified.
- `dependencies:` none.
- The draft's `/server` and `/plugins` volumes map to `/config` (section 9); do not list them as separate volumes unless the port keeps them.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `export SKIP_CHOWN_DATA=true SKIP_PRIVILEGE_DROP=true` (no root, no chown), `export TYPE="${TYPE:-BUNGEECORD}"`, `VELOCITY_VERSION`, `VELOCITY_BUILD_ID`, `MEMORY` defaults from `settings.yaml`.
- `export HOME=/tmp TMPDIR=/tmp` so helper caches stay in `/tmp`.
- `mkdir -p /config`; seed `/config` from `/defaults` (see section 2) only when missing (never overwrite).
- Validate `TYPE` against `BUNGEECORD|WATERFALL|VELOCITY|CUSTOM`; exit with a clear message otherwise.
- `exec` the upstream `run-bungeecord.sh` (or the equivalent `/usr/bin/run-bungeecord.sh` for the chosen `TYPE`) so SIGTERM reaches the JVM. The upstream script was not re-read at 2026.11.2: UNVERIFIED which paths it hard-codes (`/server`, `/plugins`, `/config`) and whether `BUNGEE_HOME` covers all of them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '25577'
filePaths:
- /usr/bin/mc-image-helper
- /usr/bin/mc-monitor
- /usr/bin/rcon-cli
- /usr/share/licenses/minecraft-proxy/LICENSE
```

- Default `TYPE=BUNGEECORD` downloads the BungeeCord jar at start, so the tcp probe on 25577 needs network in CI. Add a second tcp probe on 25565 only when the test sets `TYPE=VELOCITY`, which the test cannot do (no env). Velocity is covered by the local run in section 11, not by CI, and the PR says so.
- Keep `tcp` probes against every port in `settings.yaml` that the default config opens. The 25565 port is not opened by Bungee: list it as `required: false` and do not probe it in CI (document why).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/server` (working dir, `config.yml`, jars, world/proxy data) | `/config` through `BUNGEE_HOME=/config`. |
| `/plugins` (plugin jars) | `/config/plugins` (under `/config`; the separate upstream volume is not kept). |
| `/config` (upstream sync source, README) | Seed from `/defaults` into `/config` only when missing. Keep one writable volume. |
| helper temp, `HOME`, cache | `/tmp` (`HOME=/tmp`, `TMPDIR=/tmp`). |
| chown and UID remap (`PUID`, `PGID`, `SKIP_CHOWN_DATA`) | Disabled. Fixed UID 568 (`apps`). |

Draft security expectations, reconciled: runAsUser 568 (matches `USER apps`); `readOnlyRootFilesystem: true` compatible with `--read-only --tmpfs /tmp`; privileged no. Extra persistence `/server` and `/plugins` become `/config`; existing users must move them to `/config`.

## 10. Risks, caveats and open questions

- **Target port:** Velocity uses 25565 and Bungee uses 25577. The draft listed only 25577; the settings list both.
- **Java version:** draft asked for java17 or java25; java25 matches the pinned upstream base. Confirm Velocity 4.3.1 runs on the chosen Java (section 3).
- **Forwarding secret:** must match on the proxy and each backend, a manual setup step. The variable and the template location were not verified.
- **Runtime downloads:** the proxy jar is downloaded on first start: needs network and no checksum check by the helper (UNVERIFIED).
- **Backends:** the proxy is useless without reachable backend servers, which are external to this container.
- **Drafts `/server` vs `/config`:** upstream README calls `/server` the working dir; the port uses `/config` (section 9). Confirm with a readiness run.
- No blockers: not musl-only, no GPU, not privileged, arm64 supported.

## 11. Build and test steps

```sh
cd apps/minecraft-proxy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name minecraft-proxy-probe --read-only --tmpfs /tmp \
  -v minecraft-proxy-probe-config:/config minecraft-proxy:2026.11.2
docker logs -f minecraft-proxy-probe

forgetool containers test --image minecraft-proxy:2026.11.2 --config ./apps/minecraft-proxy/container-test.yaml

docker rm -f minecraft-proxy-probe; docker volume rm minecraft-proxy-probe-config
```

- Expected readiness signal: the container still running after the jar download, the port open on 25577, and a BungeeCord "listening" line (exact wording UNVERIFIED).
- Run again with `-e TYPE=VELOCITY` on a fresh volume and check `Listening on 0.0.0.0:25565` (UNVERIFIED exact wording).
- Test an empty `/config` volume, then a restart on the same volume.
- arm64 not tested unless run with `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch `feat/add-minecraft-proxy`, commit `feat(minecraft-proxy): add new container`, PR title the same, target `main`.
- CLA: sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Notes section contains `🤖 This PR is AI generated.`; fill in `.github/PULL_REQUEST_TEMPLATE.md`, check only applicable boxes.
- State what was not tested: Velocity mode in CI, arm64, backend connection and forwarding secret, the upstream 2026.11.2 scripts, Velocity jar checksum.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
