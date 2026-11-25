# v-rising — implementation plan
> Source: ./draft.md · Target: apps/v-rising/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: Steam branch `default` has no version string in the sources fetched. Pin the Steam build id at build time and record it in the PR. Do not invent a version. |
| Renovate | UNVERIFIED: no versioned release to track. Use the sibling `apps/steamcmd` pattern (`datasource=deb` for the package) and pin the app by Steam app id; no renovate annotation can be confirmed for the server build. |
| License | UNVERIFIED: proprietary Steam/Stunlock EULA. Not an open-source license; set `LICENSE` only after review. |
| Source URL | https://playvrising.com/ (vendor site); instructions https://github.com/StunlockStudios/vrising-dedicated-server-instructions |
| Steam app id | 1829350 (dedicated server), branch `default` (https://raw.githubusercontent.com/StunlockStudios/vrising-dedicated-server-instructions/master/1.1.x-pc/INSTRUCTIONS.md). |
| Download | SteamCMD install of app 1829350 (`+app_update 1829350`). Exact SteamCMD command line: UNVERIFIED (the instructions point to `examples/download-default.bat`, not fetched). |
| Executable | `VRisingServer.exe` (Windows). Vendor states: "At the moment there is only a Windows version of the server available" (same source). |
| arm64 | No (Windows-only server). |
| Checksum source | UNVERIFIED: Steam manifests provide depot checksums; not fetched. Record the Steam build id instead. |
| Ports | UDP. Game `-gamePort` (example 27015) and query `-queryPort` (example 27016), labelled as examples in the vendor instructions. Draft's 9876/9877 are NOT confirmed by any fetched page: UNVERIFIED. |
| Config | `ServerHostSettings.json`, `ServerGameSettings.json`. Defaults in `VRisingServer_Data/StreamingAssets/Settings/` (read-only defaults, do not edit). Overrides under the `-persistentDataPath` folder `Settings/`. |
| Data path | `-persistentDataPath <path>` (recommended), saves under `Saves/`, `-saveName <name>`. |
| Upstream packager | https://github.com/ich777/docker-steamcmd-server (Dockerfile: base `ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, no Wine, no Xvfb, `USER steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`). The `vrising` tag's Wine/Xvfb setup is UNVERIFIED: no `vrising` branch was found in the branch list read. |
| Steam store | https://store.steampowered.com/app/1829350/ (draft link). |
| apt on Ubuntu 26.04 | Not required for the server; Wine packages (`wine64`, `xvfb`) availability on resolute is UNVERIFIED. |
| Dependencies | None at runtime. `apps/steamcmd` is the build/runtime base (see section 3), not a service dependency. |

## 2. Target layout

- `apps/v-rising/Dockerfile`
- `apps/v-rising/docker-bake.hcl`
- `apps/v-rising/settings.yaml`
- `apps/v-rising/container-test.yaml`
- `apps/v-rising/start.sh` (SteamCMD download to `/config`, then launch the server)

No `defaults/` unless default settings files are seeded. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`, using the FROM line from `apps/steamcmd/Dockerfile` family (its VERSION in `apps/steamcmd/docker-bake.hcl` is `20180105-5build1`; the published tag and digest are UNVERIFIED and must be read from the built `steamcmd` image). Alternative: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` and install steamcmd in-app. Closest sibling for SteamCMD games: `apps/steamcmd` (steamcmd runtime) and `apps/xvfb` (Xvfb runtime, for Wine).

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest> AS base` (confirm the tag by building `apps/steamcmd` first).
2. `USER root`, then install Wine and Xvfb only if the Wine path is confirmed (UNVERIFIED: `wine64`, `xvfb`, `lib32gcc-s1` on resolute). Pin versions if from apt and check against `VERSION`. Do not install if the server can run without Wine (it cannot: the server is Windows-only).
3. `ARG VERSION` (Steam build id or `default`), matched to `docker-bake.hcl`.
4. Set `ENV WINEPREFIX=/tmp/wine WINEDEBUG=-all` (prefix in `/tmp`, never `/config` unless persistence is explicitly needed; the wine prefix is recreated each start).
5. `COPY --chmod=0755 . /` then `USER apps`.
6. `EXPOSE 27015/udp 27016/udp` (vendor example ports, see section 10) and `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "v-rising"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "UNVERIFIED-STEAM-BUILD"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://playvrising.com/"
}

group "default" {
  targets = ["image-local"]
}
```

The `VERSION` default must be a real pinned value before commit (see section 10). Then the four standard targets from `apps/adguardhome-sync`. `image-all` platforms: `linux/amd64` only. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://playvrising.com/"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27016
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port numbers are the vendor's example values (`-gamePort`, `-queryPort`), not confirmed defaults. Match the chart's ports (UNVERIFIED) before finalizing. Do not list env vars the server does not read; the server takes its settings from JSON files and flags.

## 7. start.sh

- `set -euo pipefail`; `DATA=/config/vrising`; `mkdir -p "$DATA/Settings" "$DATA/Saves"`.
- Seed `ServerHostSettings.json` and `ServerGameSettings.json` into `$DATA/Settings` only when missing (never overwrite user edits).
- Install/update: run SteamCMD for app 1829350 into `$DATA/server` (`+app_update 1829350 validate`). Use `/tmp` for SteamCMD caches. Idempotent: skip if already installed at the pinned build.
- Launch: `exec wine64 "$DATA/server/VRisingServer.exe" -persistentDataPath "$DATA" -saveName "${SAVE_NAME:-world1}" -gamePort "${GAME_PORT:-27015}" -queryPort "${QUERY_PORT:-27016}"` inside `xvfb-run` if Xvfb is confirmed required (UNVERIFIED). Use `WINEPREFIX=/tmp/wine`.
- Bind: game and query listen on all interfaces by default (UNVERIFIED; confirm in a real run).

## 8. container-test.yaml

Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json`

- `udp` probes for 27015 and 27016 (if forgetool supports `udp`; otherwise `tcp` probes are NOT valid for these ports and the gap must be stated).
- `filePaths`: `/start.sh`.
- `timeoutSeconds`: large (SteamCMD downloads several GB on first start). Set from the sibling family (UNVERIFIED value).
- The test runs with no env vars and no network guarantee, so the first start cannot finish in CI. State this in the PR; do not weaken or fake the assertions. The DB-dependency narrowing exception does NOT apply (no database).

## 9. Rootless and read-only-rootfs adaptations

- Upstream chart: `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem: false`, privileged unset (false), extra persistence `/serverdata/serverfiles` and `/serverdata/steamcmd` (chart paths). Expectations to verify.
- Adaptation: `USER apps`; server and SteamCMD data in `/config` (`/config/vrising/server`, `/config/steamcmd`); Wine prefix and caches in `/tmp`. Chart `/serverdata/serverfiles` maps to `/config/vrising/server`; `/serverdata/steamcmd` maps to `/config/steamcmd` (or `/tmp` if caches only).
- Wine under read-only rootfs: `WINEPREFIX` must be on `/tmp` or `/config` (writable). Confirm during the run.

## 10. Risks, caveats and open questions

- Windows-only server: the Wine path is required, and the Wine/Xvfb setup for `ich777/steamcmd:vrising` is unverified (no Wine in the fetched steamcmd Dockerfile). Blocker until a real run shows it works.
- Ports: game and query UDP, example values only. Draft's 9876/9877 unconfirmed; players need NAT/forwarding.
- Steam build version pin is unverified: `VERSION` in bake cannot be a real value until SteamCMD is run and the build id is read.
- Several GB SteamCMD download on first start; needs internet.
- arm64 impossible.
- `privileged` is not needed, but Wine/Xvfb may need extra capabilities (UNVERIFIED).
- Blockers: Wine unverified, version pin unverified, no arm64.

## 11. Build and test steps

```sh
cd apps/v-rising
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name v-rising-probe --read-only --tmpfs /tmp \
  -v v-rising-probe-config:/config v-rising:<version>
docker logs -f v-rising-probe
docker rm -f v-rising-probe; docker volume rm v-rising-probe-config
forgetool containers test --image v-rising:<version> --config ./apps/v-rising/container-test.yaml
```

Expected readiness signal: the server logs a ready/listening line (wording UNVERIFIED until a real run). Empty `/config` must be tested each round.

## 12. PR checklist

- Branch `feat/add-v-rising`; commit `feat(v-rising): add new container`; target `main`.
- PR title matches the commit; use the PR template and keep its sections and checkboxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what is untested: the Wine path, the Steam build pin, the UDP ports, arm64 (not possible), and the first-start download.
