# mindustry — implementation plan
> Source: ./draft.md · Target: apps/mindustry/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `160.8` (tag `v160.8`, published 2026-11-18, not prerelease). TrueCharts runs the ich777 wrapper with `GAME_V=latest` (floating). Source: https://api.github.com/repos/Anuken/Mindustry/releases/latest |
| Renovate | `datasource=github-releases depName=Anuken/Mindustry versioning=loose` (tags are `vNNN.N`; the `v` is added in the download URL, as in `releases/download/v${VERSION}/...`) |
| License | GPL-3.0 (SPDX, GitHub API). Source: https://api.github.com/repos/Anuken/Mindustry |
| Source URL | https://github.com/Anuken/Mindustry |
| Binary | `server-release.jar`, https://github.com/Anuken/Mindustry/releases/download/v160.8/server-release.jar. Size 19353710 bytes. |
| Checksum | sha256 `faeaf247a8b622de940181a96cb21cb20692d3c3da4e8ac3f79cb4af5059aa6c` (GitHub asset digest, https://api.github.com/repos/Anuken/Mindustry/releases/latest). The release has no `checksums.txt`, so the digest from the API is the checksum source. |
| Other release assets | `assets.jar`, `dependencies.jar`, `Mindustry.jar` (desktop client). Not needed for the server. |
| Java | JDK 17 only: "make sure you have JDK 17 ... Other JDK versions will not work" (https://raw.githubusercontent.com/Anuken/Mindustry/master/README.md). `build.gradle` sets source and target 17 (https://raw.githubusercontent.com/Anuken/Mindustry/master/build.gradle). The draft's "java17 or java21" is reduced to java17. |
| Launch | Upstream README gives no launch command in the fetched text; the server is started as `java -jar server-release.jar`. The ich777 wrapper passes `config name <SRV_NAME>,host,<GAME_PARAMS>` (https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start-server.sh). The exact argument semantics are UNVERIFIED, so keep the form the wrapper uses and confirm it on the first run. |
| Port | 6567. TrueCharts maps `main` port 6567 tcp and `udpgameport` 6567 udp (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mindustry/values.yaml). The TCP side is from the chart only (UNVERIFIED for the protocol). |
| Upstream image | ich777 wrapper. Dockerfile https://raw.githubusercontent.com/ich777/docker-mindustry/master/Dockerfile: `FROM ich777/debian-baseimage`, apt `curl screen default-jre`, gotty v1.0.1 amd64 tarball from GitHub (no checksum), `ENTRYPOINT ["/opt/scripts/start.sh"]`, `UID=99 GID=100 UMASK=000 DATA_DIR=/mindustry`. |
| Wrapper start script | https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start.sh: root `usermod`/`groupmod`, `chown -R UID:GID /mindustry`, then `su mindustry -c start-server.sh`. |
| Wrapper server script | https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start-server.sh: resolves the latest version from the GitHub API at runtime, downloads `server-release.jar` with `wget` (no checksum), runs `screen ... java -jar ${DATA_DIR}/server-release.jar ...`, starts gotty when `ENABLE_WEBCONSOLE=true`. |
| Wrapper env (real) | `DATA_DIR`, `GAME_V`, `SRV_NAME`, `GAME_PARAMS`, `EXTRA_PARAMS`, `ENABLE_WEBCONSOLE`, `GOTTY_PARAMS`, `UMASK`, `UID`, `GID`, `DATA_PERM`, `USER`. |
| Gotty web console | Port not confirmed: `start-gotty.sh` was not fetched. The draft's 8080 is UNVERIFIED. Gotty is a shell-style console, so it is excluded from this plan (section 9). |
| Data write paths | `${DATA_DIR}` (`/mindustry` in the chart): `server-release.jar`, `masterLog.0`, `mindustryinstalled-v*` marker, and the world/save directory (UNVERIFIED location: Mindustry's default data dir on Linux is under `$HOME`, which the wrapper sets to `/mindustry` via the `mindustry` user; confirm on first run). |
| TrueCharts chart | `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Persistence `serverfiles` at `/mindustry`. Env `GAME_V`, `SRV_NAME`, `GAME_PARAMS` (values file above). |
| arm64 | The JAR is Java bytecode and runs on any JDK 17 (arm64 yes). The wrapper image is amd64-only (gotty `linux_amd64` binary); ich777 image arm64 is not published (draft). The ContainerForge build does not use the wrapper, so arm64 is possible. |
| Dependencies | None. |

## 2. Target layout

- `apps/mindustry/Dockerfile`
- `apps/mindustry/docker-bake.hcl`
- `apps/mindustry/settings.yaml`
- `apps/mindustry/container-test.yaml`
- `apps/mindustry/start.sh`

No `defaults/` needed: the server creates its own config on first start. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`. It is ubuntu-26.04 based, multi-arch (`TARGETARCH` maps to `aarch64` and `x64`), and ends with `USER apps`.
- Closest sibling: `apps/java17` (its Dockerfile is the base) and the Java server apps `apps/nzbhydra2` and `apps/airsonic-advanced` (for `start.sh` and `container-test.yaml` shape). Reuse the java17 base; do not install a second JDK.
- The ich777 image is not reused as a base: it is `debian-baseimage`, runs as root, and adds gotty and screen.

## 4. Dockerfile

1. `ARG VERSION=160.8` (must match `docker-bake.hcl`), `ARG TARGETARCH`, `ARG MINDUSTRY_SHA256=faeaf247a8b622de940181a96cb21cb20692d3c3da4e8ac3f79cb4af5059aa6c`.
2. `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b8...` (the base digest from section 3).
3. `USER root`.
4. Download and verify the JAR:

```dockerfile
RUN set -eux; \
    mkdir -p /app/mindustry; \
    curl -fL -o /app/mindustry/server-release.jar \
      "https://github.com/Anuken/Mindustry/releases/download/v${VERSION}/server-release.jar"; \
    echo "${MINDUSTRY_SHA256}  /app/mindustry/server-release.jar" | sha256sum -c -; \
    chmod 0644 /app/mindustry/server-release.jar
```

   The checksum is the GitHub asset digest for `v160.8`; it must change with `VERSION` (see section 10).
5. Licence: `mkdir -p /usr/share/licenses/mindustry && curl -fL -o /usr/share/licenses/mindustry/LICENSE "https://raw.githubusercontent.com/Anuken/Mindustry/v${VERSION}/LICENSE"` (URL pattern from the repo tag; UNVERIFIED that the file exists at that path for `v160.8`, check on the build). GPL-3.0 needs the licence shipped.
6. `chown -R root:root /app && chmod -R 755 /app` (the JAR is read-only at runtime; no write to `/app`).
7. ENV: `HOME=/config`, `DATA_DIR=/config/mindustry` (used only by `start.sh`), `SRV_NAME=DockerMindustry`, `GAME_PARAMS=` (empty), `EXTRA_PARAMS=` (see section 7), `JAVA_TOOL_OPTIONS` not set (no default unless the heap needs one; open question, section 10).
8. `EXPOSE 6567/tcp`, `EXPOSE 6567/udp`, `VOLUME /config`.
9. Tail: `USER apps`, `COPY --chmod=0755 . /`.

Note: no `apt-get` step. The java17 base is a JRE and already has `java` on `PATH`. No `screen`, no `gotty`, no `curl` install needed (curl is in the ubuntu base).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mindustry"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Anuken/Mindustry versioning=loose
  default = "160.8"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Anuken/Mindustry"
}
```

`LICENSE` is GPL-3.0 per GitHub; confirm `-only` or `-or-later` from the `LICENSE` header before committing. Four standard targets and the default group as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `cd apps/mindustry && docker buildx bake --print`.

Renovate note: a version bump also needs the new sha256 in the Dockerfile. Renovate cannot update that ARG on its own from the bake annotation; see section 10.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Anuken/Mindustry"
ports:
  - port: 6567
    protocol: tcp
    required: true
  - port: 6567
    protocol: udp
    required: true
env:
  - name: SRV_NAME
    default: "DockerMindustry"
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Only `SRV_NAME` and `GAME_PARAMS` are kept from the wrapper because `start.sh` reads them. `GAME_V`, `ENABLE_WEBCONSOLE`, `GOTTY_PARAMS`, `UID`, `GID`, `UMASK`, `DATA_PERM`, `USER`, `DATA_DIR` are not listed: the first two and the gotty/user settings do not apply to this image, and `DATA_DIR` is fixed to `/config/mindustry`.
- `required: true` for the UDP and TCP 6567 ports matches the game needing both (chart evidence). If the TCP side is not confirmed on the first run, drop the tcp entry (section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash

DATA_DIR="${DATA_DIR:-/config/mindustry}"
SRV_NAME="${SRV_NAME:-DockerMindustry}"
GAME_PARAMS="${GAME_PARAMS:-}"

mkdir -p "${DATA_DIR}"
cd "${DATA_DIR}"

# Same argument shape as the ich777 wrapper: config name <name>,host,<extra>.
# UNVERIFIED semantics; confirm on the first run and record the result here.
exec java -jar /app/mindustry/server-release.jar \
  config name "${SRV_NAME}",host,${GAME_PARAMS}
```

- Idempotent: `mkdir -p` only. Nothing is seeded (the server writes its own config on first start). If a save or config file must be seeded, use `cp -n` only when missing.
- Never writes to `/app` (the JAR is read-only). Saves go under `/config`.
- `exec java` so the JVM is PID 1 and gets SIGTERM directly. Caveat: the wrapper runs the server in `screen`; ContainerForge does not, so the console is not reachable (a deliberate removal, section 9).
- Bind: the server listens on all interfaces by default (UNVERIFIED, confirm with `ss -ltn` in the run step).
- `EXTRA_PARAMS` is not in the env list: the wrapper's default is `config ` and the plan folds it into the argument line above. If a user needs more args, add them to `GAME_PARAMS`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '6567'
filePaths:
- /app/mindustry/server-release.jar
- /usr/share/licenses/mindustry/LICENSE
runners:
- entrypoint: java -version
```

- Every settings port has a probe: TCP 6567 is tested. There is no UDP probe in this plan. Check whether forgetool supports a UDP probe; if not, state it in the PR as untested (section 10).
- No `http` probe: the game has no HTTP server.
- `timeoutSeconds: 180` because the first start loads the game assets (a guess; confirm from the run, then lower to the sibling value if it is quicker).
- `runners` checks the JVM runs (`java -version`), which catches a JRE mismatch. The `java17` base's own test has the same shape (`apps/java17/container-test.yaml`).
- The test runs with no env, so `SRV_NAME` and `GAME_PARAMS` take their defaults.

## 9. Rootless and read-only-rootfs adaptations

| Upstream (ich777 wrapper) | ContainerForge change |
| --- | --- |
| Runs as root; `usermod`/`groupmod` to UID 99 / GID 100 | Removed. Runs as `apps` (568) from the base. |
| `chown -R ${UID}:${GID} ${DATA_DIR}` and `chmod ${DATA_PERM}` | Removed. `/config` is owned by the base user; `start.sh` does not change permissions. |
| `su mindustry -c start-server.sh` | Removed. `start.sh` runs the JVM directly as `apps`. |
| `DATA_DIR=/mindustry` | `/config/mindustry` (persistent state). |
| gotty web console (port UNVERIFIED, default 8080), `screen`, `watchdog`, `start-watchdog.sh` | Dropped. The web console gives shell-style access. The draft's security note agrees: "must be protected or left unexposed". Not reproduced. |
| `wget` of `server-release.jar` at runtime with `GAME_V=latest` | Replaced by a build-time download pinned by `VERSION` and checked by sha256. The image is reproducible; `latest` is not used. |
| `ulimit -n 2048` in the Dockerfile | Not reproduced. The JVM needs a few hundred file handles; the base default is expected to be enough (UNVERIFIED for a loaded server; check `ulimit -n` in the run). |
| `UMASK=000` | Not set. Default umask from the base. |
| `/tmp` | Not used by the server. |

Security expectations from the draft (`runAsUser 0`, `readOnlyRootFilesystem false`) are the chart's values and are not reproduced by this image. This image is rootless and read-only compatible.

## 10. Risks, caveats and open questions

- Checksum upkeep: the sha256 in the Dockerfile is for `v160.8` only. A version bump must update `MINDUSTRY_SHA256` with the digest from the new release (the GitHub API `digest` field). Renovate can update `VERSION` from the bake annotation; the checksum needs a manual or scripted step. Open question: whether to keep the checksum in the Dockerfile or move it to a bake variable.
- Wrapper argument semantics: `config name <SRV_NAME>,host,<GAME_PARAMS>` is taken from the wrapper. Confirm what the server does with `config`, `name` and `host` on the first run (Mindustry server console commands are UNVERIFIED as argv). Adjust `start.sh` to match, but keep the wrapper's values.
- Save path: the wrapper runs with `HOME` for the `mindustry` user at `/mindustry`. This image sets `HOME=/config`, so the save directory may be `/config/.local/share/...` rather than `/config/mindustry`. Confirm on the first run and, if needed, set the data location explicitly (UNVERIFIED how the server picks its data dir; do not invent a flag).
- TCP 6567: only the chart says the server listens on TCP as well as UDP. Confirm with `ss -ltn` and `ss -lun` in the run. If TCP is not open, remove the tcp port from `settings.yaml` and `container-test.yaml`.
- UDP probe: `forgetool` may not have a UDP probe. The UDP port is listed in settings but untested unless it does. Say so in the PR.
- Web console: excluded. If someone needs it, it is a separate, opt-in app or a separate PR with an explicit access policy. Not in this plan.
- Heap: the JVM default heap is set by the container memory limit on the host. Open question whether to add `JAVA_TOOL_OPTIONS` or `-Xmx`; not in this plan.
- The draft's network caveat (UDP forwarding through NAT/firewall) stays: clients must reach UDP 6567 directly.
- arm64: the JAR runs on arm64 JDK 17, so arm64 should build. Build and run it only if amd64 fails for an arch reason (protocol rule). The draft's "arm64 no" was about the wrapper image, not the JAR.

## 11. Build and test steps

```sh
cd apps/mindustry
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker volume create mindustry-probe-config
docker run --rm -d --name mindustry-probe --read-only --tmpfs /tmp \
  -v mindustry-probe-config:/config mindustry:160.8
docker logs -f mindustry-probe          # wait for the server to load and bind 6567
docker exec mindustry-probe ss -ltn     # check TCP 6567
docker exec mindustry-probe ss -lun     # check UDP 6567
docker rm -f mindustry-probe; docker volume rm mindustry-probe-config

forgetool containers test \
  --image mindustry:160.8 \
  --config ./apps/mindustry/container-test.yaml
```

- Expected readiness signal: the process stays up, the log shows the server starting and binding, and TCP 6567 is open. The exact log line is UNVERIFIED; record it from the first run.
- Also test a second start on the same `/config` volume (restart the container with the same volume) to confirm the save path persists.
- `ss` may not exist in the base image; if not, use the forgetool tcp probe and a log check.

## 12. PR checklist

- Branch `feat/add-mindustry` from `main`; commit `feat(mindustry): add new container`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user the CLA is required before merge: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what is not tested: UDP probe (if forgetool lacks it), arm64 (unless built), a real multiplayer connection, the save path if not confirmed.
- Confirm `docker buildx bake --print` ran and passed before pushing.
