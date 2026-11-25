# stationeers — implementation plan
> Source: ./draft.md · Target: apps/stationeers/ · Difficulty: easy (see section 10: the difficulty depends on the start-up wrapper) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Not a versioned release. The server is downloaded from Steam by SteamCMD at start, app ID `600760` (from the ich777 stationeers README). The draft's chart image `ghcr.io/ich777/steamcmd:stationeers` is a Steam wrapper, not a release. |
| Renovate | UNVERIFIED: no release feed for the Steam app. Use `apps/steamcmd`'s own VERSION (`datasource=deb`) for the base; the Stationeers app ID has no datasource. Open question (section 10). |
| License | Stationeers is closed-source Steam software. The ich777 repo has no SPDX license (`null`). Upstream licence: UNVERIFIED. Use `LICENSE` value `NONE`/proprietary only after checking the Steam EULA (open question). |
| Source URL | https://stationeers.net/ (the draft's "source") is a website, not a source repo. |
| Download | SteamCMD `app_update 600760` into `STEAM_INSTALL_DIR`. No direct release asset. |
| Checksum source | None published. SteamCMD verifies Steam content (`validate` flag). |
| Upstream Dockerfile reviewed | ich777 `stationeers` branch `Dockerfile`: `FROM ich777/debian-baseimage`, apt `lib32gcc-s1 screen`, `ENV DATA_DIR=/serverdata`, `GAME_ID=template`, `GAME_PARAMS=-difficulty easy -loadlatest Mars Mars`, `GAME_PORT=27015`, `UID=99`, `GID=100`, `USER=steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. Master `Dockerfile` (steamcmd base): `FROM ich777/debian-baseimage:bullseye_amd64`. `scripts/start.sh` runs as root (`usermod`, `groupmod`, `chown`), then `su ${USER} -c start-server.sh`. |
| Ports | `27015/udp` and `27500/udp` (ich777 README run example). The draft's `27016/udp` is not confirmed. Valve wiki returned 403. UNVERIFIED for the game port. |
| Env vars (real, ich777 README) | `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `USERNAME`, `PASSWRD`, `UID`, `GID`. Stationeers default `GAME_PARAMS`: `-difficulty easy -loadlatest Mars Mars`. |
| Config path | `settings.xml` in the server's main directory (ich777 README). Stop the server before editing. |
| Data/config write paths | Server files and SteamCMD cache under the data dir. |
| Dependencies | None beyond SteamCMD (`apps/steamcmd` exists). |
| arm64 | No. SteamCMD bootstrap is i386/lib32 (per ich777 Dockerfile). Valve wiki (not fetched) would confirm. Treat as UNVERIFIED-no. |
| UNVERIFIED | Stationeers game port (27015 vs 27016); Steam app ID confirmation on Valve's site; the Linux server binary name and its launch flags (`scripts/start-server.sh` on the stationeers branch was not fetched); whether the server reads `settings.xml` from its working directory. |

## 2. Target layout

- `apps/stationeers/Dockerfile`
- `apps/stationeers/docker-bake.hcl`
- `apps/stationeers/settings.yaml`
- `apps/stationeers/container-test.yaml`
- `apps/stationeers/start.sh` (or `scripts/stationeers-start.sh`, see section 4: a top-level `start.sh` would replace the base's `/start.sh`)

No `defaults/` yet: the default `settings.xml` content is UNVERIFIED, so it is not seeded (section 10). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Runtime base: `FROM ghcr.io/trueforge-org/steamcmd:<tag>` (the ContainerForge `apps/steamcmd` image, which already has SteamCMD, `lib32` libraries and `USER apps`). Foundation is `ghcr.io/trueforge-org/ubuntu` through steamcmd. Do not use the ich777 image: it runs as root and rewrites UID/GID, which conflicts with `USER apps`. Closest sibling for SteamCMD-driven servers: `apps/steamcmd` itself (see section 4 for how the app triggers the Steam download).

## 4. Dockerfile

1. Header: `ARG VERSION` (the steamcmd package version used by the base, or the Stationeers branch name), `USER root` only if a package install is needed. None is needed (steamcmd base has `lib32`).
2. No `apt-get` (base provides everything).
3. `ENV HOME=/config` (inherits from steamcmd), `ENV STEAM_APP_IDS=600760`, `ENV STEAM_INSTALL_DIR=/config/stationeers`. `apps/steamcmd/start.sh` reads these, but this app's own `start.sh` is copied to `/start.sh` by `COPY . /` and replaces the base's script (which `/usr/local/bin/steamcmd` execs). To keep the base script, ship this app's launcher as `scripts/stationeers-start.sh` (the `.dockerignore` allow-list includes `scripts/`) instead of `start.sh`, and have it run `/start.sh +quit` first: the base only installs when its first argument starts with `+` (a non-`+` argument is exec'd immediately). Decide before implementing.
4. `COPY --chmod=0755 . /`, `USER apps`.
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp
EXPOSE 27500/udp
VOLUME /config
```

The `EXPOSE` for the game port must match the final port decision (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "stationeers"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "NONE"
}

variable "SOURCE" {
  default = "https://stationeers.net/"
}
```

`VERSION` follows the `apps/steamcmd` pattern (the base's package version), so it stays aligned with the base. `LICENSE` must be the licence of the software in the image: the Stationeers server is proprietary, so `LICENSE` is a placeholder until verified (section 10). Standard targets then follow, with `image-all` for amd64 only (see section 9 for why arm64 is out).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://stationeers.net/"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27500
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "600760"
    required: true
  - name: STEAM_INSTALL_DIR
    default: "/config/stationeers"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: GAME_PARAMS
    default: "-difficulty easy -loadlatest Mars Mars"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`STEAM_APP_IDS` is the name `apps/steamcmd` reads. `GAME_PARAMS` is our env name (not an upstream name). Ports: 27015/udp and 27500/udp are the ich777 example values; the game port is UNVERIFIED (section 10).

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Do not use the ich777 `start.sh` (it needs root). Run the Stationeers server as `apps` with `cd "${STEAM_INSTALL_DIR}"`.
- Download step: the launcher must not overwrite the base `/start.sh` (see section 4). Run `/start.sh +quit` to trigger the `STEAM_APP_IDS` install, then exec the server. If the server binary is still missing afterwards, exit with a clear message.
- `mkdir -p "${STEAM_INSTALL_DIR}"`, and `export HOME=/config` and `XDG_DATA_HOME=/config` so Steam state stays in `/config` (matches `apps/steamcmd`).
- Launch: `exec "${STEAM_INSTALL_DIR}/<server binary>" ${GAME_PARAMS}` (the binary name and whether it lives in `rocketstation_DedicatedServer` or similar is UNVERIFIED; take it from the ich777 `start-server.sh` before implementing).
- Do not write to the install dir except via SteamCMD. Caches to `/tmp`.
- Do not echo `PASSWRD` or `USERNAME`; this image has no password env var yet.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

Reason for the file-only check: the test runs with no internet download, and the game port is UDP, so `tcp` probes cannot check it (the coverage rule asks for a probe per port; a UDP-capable probe is not available in the schema, UNVERIFIED). This is a gap to record, not a weakened test. The sibling `apps/steamcmd` uses the same file-only check. If forgetool supports a UDP probe, add one for 27015. Timeout: a long `timeoutSeconds` is needed only once a probe exists (first-start Steam download is large).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`. The draft's chart expectation (runAsUser 0, readOnlyRootFilesystem false) is not carried over: the image runs as `apps` and writes only to `/config` and `/tmp`.
- Read-only rootfs: SteamCMD writes under `/config`, which is a volume, so `--read-only --tmpfs /tmp` works. Confirm the SteamCMD cache paths during step 3 of section 11.
- arm64 is not supported: SteamCMD is i386 (lib32). So `image-all` lists only `linux/amd64`, and `arm64` is marked unsupported in the PR.
- Ports are UDP and above 1024: no privileged port.
- Extra persistence: the chart's `/serverdata/serverfiles` and `/serverdata/steamcmd` PVCs map to `/config/stationeers` and `/config` (SteamCMD state) in this image.

## 10. Risks, caveats and open questions

- Difficulty: `easy` in the draft assumed a simple start script. The ich777 wrapper runs as root, so this image takes the `apps/steamcmd` route instead, which makes the image closer to `medium`. The PR must state this.
- Game port: the draft says 27016; the ich777 README says 27015/udp and 27500/udp. Confirm the real game port on the Valve/Stationeers page before writing `EXPOSE` and `settings.yaml`.
- Server binary name and launch flags: UNVERIFIED. The ich777 `start-server.sh` on the stationeers branch was not fetched. Fetch it (read-only) before implementing `start.sh`.
- `settings.xml`: the file is in the server's main directory (ich777 README). Whether the server reads it from the working directory is UNVERIFIED. Do not seed a default `settings.xml` until confirmed.
- Licence: closed-source Steam software; `LICENSE` value is a placeholder until confirmed against the Steam EULA.
- arm64: no (x86/lib32 SteamCMD). Confirm on the Valve wiki (403 during fetch).
- First start downloads the server via Steam: large, needs internet. This blocks a CI test that expects readiness in seconds.
- Blockers: the wrapper's root requirement is avoided by using `apps/steamcmd`. Not a hard blocker, but the launch binary and port must be confirmed before a build.

## 11. Build and test steps

1. `cd apps/stationeers && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with internet and a fresh volume: `docker run --rm -d --name stationeers-probe --read-only --tmpfs /tmp -v stationeers-probe-config:/config stationeers:<version>`. Readiness signal: the SteamCMD success line for app 600760 (`Success! App '600760' fully installed`, exact text UNVERIFIED), then the server's own "ready" line (UNVERIFIED). Check the container stays up.
4. Clean up: `docker rm -f stationeers-probe; docker volume rm stationeers-probe-config`.
5. `forgetool containers test --image stationeers:<version> --config ./apps/stationeers/container-test.yaml` (file-only checks; no network needed).
6. Repeat step 3 with an existing `/config/stationeers` to confirm the second start skips re-download (SteamCMD up-to-date).

## 12. PR checklist

- Branch `feat/add-stationeers`, commit `feat(stationeers): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: the full Steam download and server start, arm64 (unsupported), UDP port probe (not in schema), and the game port (UNVERIFIED).
