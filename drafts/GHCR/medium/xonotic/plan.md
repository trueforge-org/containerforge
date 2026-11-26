# xonotic — implementation plan
> Source: ./draft.md · Target: apps/xonotic/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Xonotic 0.8.6 (latest stable on https://xonotic.org/download/; release date not stated on the page, UNVERIFIED exact date). Draft's `0.8.6` matches. Upstream image `ghcr.io/ich777/xonotic:latest` defaults to `GAME_VERSION="0.8.5"` (Dockerfile at https://github.com/ich777/docker-xonotic-server/blob/master/Dockerfile, read via `gh api`), so the upstream image is not a pin to copy. |
| Renovate | Source is on GitLab, not GitHub. Suggested: `datasource=gitlab-tags depName=xonotic/xonotic versioning=loose` (UNVERIFIED that tags are named `0.8.6` with no prefix). Download URL is not a git ref, so the version is also checked against the archive URL. |
| License | UNVERIFIED. The game code and data pack are not one license. The repo's COPYING/license file was not fetched. Set `LICENSE` in `docker-bake.hcl` only after reading it (see section 5). |
| Source URL | https://gitlab.com/xonotic/xonotic (draft and `xonotic.org`). |
| Download (amd64) | `https://dl.xonotic.org/xonotic-0.8.6.zip` (about 1182 MiB; HTTP 200 confirmed by HEAD request). Mirrors on https://xonotic.org/download/: `download.evil-ant-colony.org`, `dl.illwieckz.net`, `dl.unvanquished.net`, `xonotic.au`. Zip contains a `Xonotic/` top-level directory and the prebuilt Linux dedicated binary `xonotic-linux64-dedicated` (binary name confirmed in upstream `start-server.sh`). |
| Download (source) | `https://dl.xonotic.org/xonotic-0.8.6-source.zip` (about 7 MiB, from xonotic.org). Used for the arm64 compile path only. |
| Checksum source | `https://dl.xonotic.org/xonotic-0.8.6.sha512` (lists `xonotic-0.8.6.zip` and `xonotic-0.8.6-source.zip`, 128 hex chars each, so SHA-512 by length). The hash values were not copied in this run (UNVERIFIED value); read the line for `xonotic-0.8.6.zip` at implementation time and verify with `sha512sum -c`. Check the file's line format (`<hash>  <name>`) before scripting. |
| Per-arch | amd64: yes (prebuilt zip). arm64: compile (source zip). The draft's arm64 compile is consistent with the source zip; the build steps, SDL2 and curl library needs are UNVERIFIED (no build script was read). |
| Upstream Dockerfile reviewed | https://github.com/ich777/docker-xonotic-server/blob/master/Dockerfile (decoded from `gh api`). Base `ich777/debian-baseimage`. `apt-get install curl unzip`. ENV: `DATA_DIR=/serverdata`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `BASIC_URL=https://dl.xonotic.org/`, `GAME_VERSION=0.8.5`, `GAME_PARAMS=template`, `GAME_PORT=26000`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=xonotic`. `ADD /scripts/ /opt/scripts/`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No `EXPOSE`, no `VOLUME`. |
| Upstream start scripts | `scripts/start.sh` and `scripts/start-server.sh` (https://github.com/ich777/docker-xonotic-server/tree/master/scripts, read via `gh api`). `start-server.sh` downloads `${BASIC_URL}xonotic-${GAME_VERSION}.zip` at runtime if the version marker is missing or different, unzips it, copies `Xonotic/*` into `SERVER_DIR`, seeds `data/server.cfg` from `server/server.cfg` on first run, then runs `${SERVER_DIR}/xonotic-linux64-dedicated ${GAME_PARAMS}`. |
| Port | `26000/udp` (game server). Upstream ENV `GAME_PORT=26000`. How `GAME_PORT` reaches the server config was not confirmed (UNVERIFIED). |
| Env vars (real) | Upstream image: `GAME_VERSION`, `GAME_PARAMS`, `GAME_PORT`, `UMASK`, `UID`, `GID`, `DATA_PERM`, `DATA_DIR`, `SERVER_DIR`, `BASIC_URL`, `USER` (see above). Only `GAME_PARAMS` and `GAME_PORT` are game-facing; the rest are image plumbing. The plan's settings list is limited to what this ContainerForge image reads (section 6). |
| Data paths | Upstream: `/serverdata/serverfiles` (server files), `/serverdata/serverfiles/data/` (config, maps, `server.cfg`). The engine writes its own state under the game directory (exact user-dir behaviour UNVERIFIED). |
| Dependencies | None. No ContainerForge sibling exists (draft: "No ContainerForge sibling exists", not checked here). |
| arm64 image | UNVERIFIED: `ghcr.io/ich777/xonotic` manifest was not inspected. Build from source for arm64. |

## 2. Target layout

- `apps/xonotic/Dockerfile`
- `apps/xonotic/docker-bake.hcl`
- `apps/xonotic/settings.yaml`
- `apps/xonotic/container-test.yaml`
- `apps/xonotic/start.sh`
- No `apps/xonotic/defaults/` folder: the seed `server.cfg` is extracted from the zip in the build stage and copied to `/defaults/server.cfg` in the image (section 4 step 5; path in the zip UNVERIFIED), so `start.sh` copies it to `/config` only when missing.

No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage and the build stage. The game is a native Linux binary, so ubuntu alone is enough (draft: "Runtime image: none"). `ich777/debian-baseimage` (upstream) is not reused: it is a Debian base with its own user/entrypoint model that ContainerForge does not use.

Closest sibling: no game-server sibling exists. The nearest native-binary pattern is `apps/pwndrop` (build stage, runtime stage, `COPY --from=`), plus `apps/adguardhome-sync` for prebuilt tarball install from a release URL with checksum-free download.

## 4. Dockerfile

1. Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb... AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the amd64 zip and verify it:
   ```sh
   curl -fL -o /tmp/xonotic.zip "https://dl.xonotic.org/xonotic-${VERSION}.zip"
   curl -fL -o /tmp/xonotic.sha512 "https://dl.xonotic.org/xonotic-${VERSION}.sha512"
   grep " xonotic-${VERSION}.zip\$" /tmp/xonotic.sha512 | awk '{print $1"  /tmp/xonotic.zip"}' > /tmp/xonotic.sha512.one
   sha512sum -c /tmp/xonotic.sha512.one
   ```
   The awk line rewrites the published name to the local path. Confirm the file's line format (`<hash>  <name>`) at implementation time (UNVERIFIED).
3. Unzip with `unzip -q /tmp/xonotic.zip -d /app/`. The zip top-level directory is `Xonotic/`, so the game lands in `/app/Xonotic/`. Rename or keep as `/app/xonotic/`; keep one name across the plan (this plan uses `/app/xonotic/` via `mv /app/Xonotic /app/xonotic`).
4. Remove files not needed at runtime from the extracted tree to cut size (for example the `source` directory if present; confirm the tree first). Keep the license and the third-party notice files (section 5).
5. Seed config: copy the zip's `Xonotic/data/server.cfg` (path to confirm in the extracted tree) to `/app/xonotic/defaults/server.cfg` in the build stage, and into the final image at `/defaults/server.cfg` (section 2), so `start.sh` can copy it to `/config` on first run.
6. `chmod +x /app/xonotic/xonotic-linux64-dedicated`; `chown -R apps:apps /app/xonotic` (keeps the game files owned by `apps`; the runtime does not write to `/app`, see section 9).
7. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Runtime apt packages: none expected for amd64 (the prebuilt binary is glibc). Confirm with `ldd /app/xonotic/xonotic-linux64-dedicated` in the build stage (UNVERIFIED for missing libs).
8. `COPY --from=build /app/xonotic/ /app/xonotic/`, `COPY --from=build /app/xonotic/defaults/ /defaults/`, and the license files from the zip copied to `/usr/share/licenses/xonotic/` in the build stage (exact file names to confirm in the extracted tree; section 5).
9. `ENV HOME=/config TMPDIR=/tmp GAME_PARAMS=template`. Keep `GAME_PARAMS` only if the start script uses it (see section 7).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 26000/udp

WORKDIR /config
VOLUME /config

CMD ["/start.sh"]
```

`EXPOSE` uses the UDP suffix so the declared protocol matches the game traffic.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "xonotic"
}

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=xonotic/xonotic versioning=loose
  default = "0.8.6"
}

variable "LICENSE" {
  // UNVERIFIED: set to the license read from the repo's COPYING/license file before the first build
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://gitlab.com/xonotic/xonotic"
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

- `LICENSE` must be the real license before the PR (the bake instructions require it to match the software). The placeholder is a blocker until read.
- `image-all` (arm64) is only valid once the arm64 compile is proven (section 10). Until then, `image-all` may be left with `linux/amd64` only, and this must be stated in the PR.
- Validate with `docker buildx bake --print` from `apps/xonotic/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://gitlab.com/xonotic/xonotic"
ports:
  - port: 26000
    protocol: udp
    required: false
env:
  - name: GAME_PARAMS
    default: "template"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `GAME_PARAMS` is read by the start script (upstream default `template`, verified in the upstream image ENV and `start-server.sh`). Its default must match the start script.
- `GAME_PORT` is NOT listed: its effect on the server is UNVERIFIED (section 1). Add it only after confirming it changes the listening port, otherwise it would be an env var the app does not read (settings rule: do not invent env vars).
- `UMASK`, `UID`, `GID`, `DATA_PERM`, `BASIC_URL`, `GAME_VERSION` are image plumbing and are not listed. `GAME_VERSION` is fixed by the image version (section 5).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/server

if [ ! -f /config/data/server.cfg ]; then
    cp /defaults/server.cfg /config/data/server.cfg
fi

cd /app/xonotic
exec /app/xonotic/xonotic-linux64-dedicated "${GAME_PARAMS:-template}"
```

- Seeds `server.cfg` only when missing (start-script rule: do not overwrite user state).
- The writable game paths are the open question in section 9: the engine must be pointed at `/config`, or the data directories must be symlinked, before this start script can be final.
- `exec` keeps the binary as PID 1 for signal handling. The upstream `term_handler` that sends `quit` to a `screen` session is not used: there is no `screen` in this image, and the engine stops on SIGTERM (UNVERIFIED for the Xonotic dedicated binary).
- `GAME_PARAMS` is passed as the single argument, as upstream does (`${GAME_PARAMS}` appended to the binary).
- Bind: the dedicated server listens on UDP port from `server.cfg` (`port` line UNVERIFIED); the start script does not change the bind address.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
- /app/xonotic/xonotic-linux64-dedicated
- /app/xonotic/data
- /defaults/server.cfg
- /usr/share/licenses/xonotic/COPYING
```

- Coverage minimum: settings port `26000/udp` must have a probe. `container-test.yaml` `tcp` cannot check UDP. The plan uses `filePaths` and the process check instead, and this is a gap: say so in the PR. Check whether forgetool's schema supports a `udp` probe; if it does, add `udp: - port: '26000'`. Do not claim a UDP probe that the schema does not accept.
- `timeoutSeconds: 180`: the first start copies data and starts the engine; compare with a sibling game server if one exists (none found in this run).
- The license path in `filePaths` must match the file copied in section 4.
- The test runs with no env vars, so `GAME_PARAMS` falls back to `template`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` (server files and `data/`) | Game files are in `/app/xonotic` (read-only at runtime). Writable server state must go to `/config`. Remap choices (pick one at implementation, after reading the engine's user-dir option): (a) symlink `/app/xonotic/data -> /config/data` at build time (dangling until `start.sh` creates it; the same pattern as the fenrus reference plan), or (b) pass the engine's user-dir option (`-userdir /config/...`, UNVERIFIED that Xonotic supports it). |
| `/serverdata` ownership, `chown ${UID}:${GID}` | Not needed: no root remap. Owned by `apps` in the image. |
| Runtime download of the zip (`start-server.sh`) | Not used. The zip is fetched at build time and verified. This removes the runtime network dependency and the "sleep infinity" failure path. |
| `UMASK=000`, `DATA_PERM=770` | Not reproduced. Files in `/config` are created with the default umask under `apps`. |
| Temporary and cache writes | `TMPDIR=/tmp`, `HOME=/config` (sibling convention). |

Draft expectations reconciled:
- Chart runs as UID 0 (`runAsUser: 0`) and `readOnlyRootFilesystem: false`. This plan runs as `apps` and must work with `--read-only --tmpfs /tmp`.
- Not privileged. No hostNetwork in chart values (draft). The UDP port is published by the host, not by hostNetwork.
- The chart's extra persistence is the server data (`serverfiles`), which maps to `/config` here.

## 10. Risks, caveats and open questions

- **Writable data (open, blocks section 9):** the engine's writes under the game directory are UNVERIFIED. Confirm with a `--read-only` run, then choose the symlink or user-dir remap.
- **arm64 (open):** the source zip is confirmed, but the arm64 build steps (`make` options, SDL2 and curl needs, build time) were not read. Treat arm64 as not yet validated. If the compile cannot be made to work, ship amd64 only and say so in the PR (the bake's `image-all` must not claim arm64 then).
- **Large download:** the zip is about 1182 MiB. The image layer is large, and the first build is slow (draft caveat, confirmed by size). Alternative considered and rejected for this plan: runtime download into `/config` (the upstream approach). It conflicts with the rule that runtime writes go to `/config` only for state, not for game data, and it adds a network dependency at start.
- **License (open, blocker for the PR):** `LICENSE` in bake is a placeholder until the license file is read. Xonotic code and data may carry different licenses.
- **UDP probe (open):** `tcp` checks cannot test `26000/udp`. See section 8.
- **Port mapping (open):** how `GAME_PORT` relates to the engine's port setting is UNVERIFIED. The plan lists only the settings-level variables the start script uses.
- **Upstream version drift:** the upstream image is pinned to `GAME_VERSION=0.8.5`. The ContainerForge image ships 0.8.6 only; upgrading the game means a new image tag, not a runtime change.
- **Checksum:** the hash value was not captured. Verification in section 4 must be run against the real file.
- **No blockers known** beyond the open items above: no GPU, no privileged needs, no musl-only build (the upstream image is glibc debian, and the plan uses glibc ubuntu).

## 11. Build and test steps

```sh
cd apps/xonotic
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name xonotic-probe --read-only --tmpfs /tmp \
  -p 26000:26000/udp -v xonotic-probe-config:/config xonotic:0.8.6
docker logs -f xonotic-probe
forgetool containers test --image xonotic:0.8.6 --config ./apps/xonotic/container-test.yaml
docker rm -f xonotic-probe; docker volume rm xonotic-probe-config
```

- Readiness signal: the engine's startup lines (exact wording UNVERIFIED; capture the first 100 log lines on the first run and record the real success line in this plan). The container must stay running after the startup window (protocol criterion 1).
- Confirm `/config/data/server.cfg` is created on an empty volume and not overwritten on a second start with the same volume.
- A real UDP check from outside the container (for example a Xonotic server query, or `nc -u -z` as a basic reachability check) is needed to prove the port works. A TCP probe proves nothing for this app.
- arm64: only after amd64 is green, and only if the arm64 compile is validated (section 10).

## 12. PR checklist

- Branch `feat/add-xonotic`, commit and PR title `feat(xonotic): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Say what was not tested: the arm64 compile and run, the UDP port from outside the container (no `tcp` probe covers it), the writable-data remap, and the first-run log wording unless the run was done.
- `docker buildx bake --print` passes; `LICENSE` is no longer the placeholder; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
