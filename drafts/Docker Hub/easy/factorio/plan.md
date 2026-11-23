# factorio — implementation plan
> Source: ./draft.md · Target: apps/factorio/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.1.25` stable headless (https://factorio.com/api/latest-releases returned `{"stable":{"headless":"2.1.25"}}`). The draft only says `stable`. |
| Renovate | No GitHub release for the game itself. UNVERIFIED best option: `datasource=github-tags depName=factoriotools/factorio-docker` (that repo tags image versions; tag format not checked) or a `custom.factorio` datasource reading `https://factorio.com/api/latest-releases` (`$.stable.headless`) which would need a new custom manager in the repo's renovate config (existing precedent: `custom.plex`, `custom.qbittorrent`). Ask maintainers; do not guess. |
| License | Proprietary (Wube). Not an SPDX id. Factorio ToS says it is "not a free software, copy-left or public domain software". Use `LicenseRef-Proprietary` in `LICENSE` (UNVERIFIED that the repo accepts it). See section 10 for redistribution. |
| Source URL | https://factorio.com/ (draft). Packaging reference: https://github.com/factoriotools/factorio-docker (MIT). |
| Download amd64 | `https://factorio.com/get-download/2.1.25/headless/linux64` (302 to `dl.factorio.com/releases/.../factorio-headless_linux_2.1.25.tar.xz`, 200, 61 MB) |
| Download arm64 | `https://factorio.com/get-download/2.1.25/headless/linux-arm64` (302, 200, 56 MB). The draft says arm64 is not available; that is outdated for 2.1+, upstream factoriotools Dockerfile also notes a "native linux-arm64 archive (2.1+)". |
| Checksum source | `https://factorio.com/download/sha256sums/` (plain text `<sha256>  <file>`). 2.1.25: x64 `78da2f5aa99e9e0af7586d6bf82c04aae91165d53036720dabb26e855688f3ae  factorio-headless_linux_2.1.25.tar.xz`; arm64 `c10ab4008043713b6e37097850c69ff675acac7ab965e87d768ce46d0c1753fd  factorio-headless_linux-arm64_2.1.25.tar.xz`. |
| Archive layout | Extracts to `factorio/` (upstream extracts to `/opt` and runs `/opt/factorio/bin/x64/factorio`; arm64 archive has `bin/arm64`). |
| Upstream Dockerfile reviewed | `factoriotools/factorio-docker/docker/Dockerfile`: debian stable-slim, `ENV PORT=34197 RCON_PORT=27015 SAVES=/factorio/saves CONFIG=/factorio/config MODS=/factorio/mods SCENARIOS=... SCRIPTOUTPUT=... PUID/PGID=845 DLC_SPACE_AGE=true`, `VOLUME /factorio`, `EXPOSE 34197/udp 27015/tcp`. Also `docker-entrypoint.sh`, `server-config.sh`, `config.ini` reviewed. |
| Env vars (upstream image, not the game) | `PORT`, `RCON_PORT`, `SAVE_NAME`, `LOAD_LATEST_SAVE` (default true), `GENERATE_NEW_SAVE` (default false), `PRESET`, `BIND`, `CONSOLE_LOG_LOCATION`, `UPDATE_MODS_ON_START`, `DLC_SPACE_AGE`, `SERVER_SETTINGS_FILE` and friends. These are conventions of the factoriotools image; the game itself only takes CLI flags. |
| CLI flags (wiki) | `--start-server-load-latest`, `--start-server <save>`, `--create <file>`, `--server-settings`, `--map-gen-settings`, `--map-settings`, `--port`, `--bind`, `--rcon-port`, `--rcon-bind`, `--rcon-password`, `--mod-directory`, `--config <file>`, `--server-adminlist`, `--server-banlist`, `--server-id`, `--console-log`, `--use-server-whitelist`. |
| Ports | 34197/udp (game), 27015/tcp (RCON, only open when `--rcon-port` is passed). Default game port confirmed by the wiki ("UDP only"). |
| Server settings | Example files under `data/` in the archive: `server-settings.example.json`, `map-gen-settings.example.json`, `map-settings.example.json` (used by the upstream entrypoint; presence in the archive not independently listed, UNVERIFIED). Public listing needs Factorio username plus token/password in `server-settings.json`. |

## 2. Target layout

```
apps/factorio/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.ini       # read-data = installed data dir, write-data = /config
```
`defaults/` is on the `include/.dockerignore` allow-list. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: vendor tarball (glibc) on Ubuntu. `xz-utils`, `curl`, `jq`, `uuid-runtime`, `tar` are already in the base, so no apt step. Closest sibling: `apps/steamcmd` (game-server shape), plus `apps/adguardhome-sync` for tarball into `/app`.

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) platform="linux64"; file="factorio-headless_linux_${VERSION}.tar.xz" ;; \
      arm64) platform="linux-arm64"; file="factorio-headless_linux-arm64_${VERSION}.tar.xz" ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL --retry 8 -o "/tmp/${file}" "https://factorio.com/get-download/${VERSION}/headless/${platform}"; \
    curl -fsSL -o /tmp/sha256sums.txt "https://factorio.com/download/sha256sums/"; \
    (cd /tmp && grep " ${file}\$" sha256sums.txt | sha256sum -c -); \
    tar -xJf "/tmp/${file}" -C /app --strip-components=1; \
    if [ -d /app/bin/arm64 ] && [ ! -e /app/bin/x64 ]; then ln -s arm64 /app/bin/x64; fi; \
    mkdir -p /usr/share/licenses/factorio; \
    ls /app; \
    chown -R apps:apps /app; chmod -R 755 /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 34197/udp 27015/tcp
VOLUME /config
```
Notes:
- Checksums come from the vendor's own published list, as the upstream image also requires one. Fetching the list from the same origin only protects against corruption; pin ARGs only if maintainers want stronger guarantees.
- License notices: the archive's licence/readme files were not listed, so no `/usr/share/licenses/factorio/` copy can be specified. UNVERIFIED: inspect `tar -tJf` on first build and copy any `*license*`/`*readme*` files; remove the empty `mkdir` if none exist.
- No apt packages; `file`, `procps`, `pwgen` used by the upstream image are not needed (see start.sh).
- The `bin/x64` symlink keeps the same start path on both arches (borrowed from the upstream image).
- Final `USER apps`; `COPY --chmod=0755 . /` kept.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "factorio"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=factoriotools/factorio-docker versioning=loose
  default = "2.1.25"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://factorio.com/"
}
```
The renovate line is a placeholder pending the datasource decision in section 1. Standard `group "default"`, `image`, `image-local` (`factorio:${VERSION}`), `image-all` (amd64 and arm64) as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://factorio.com/"
ports:
  - port: 34197
    protocol: udp
    required: true
  - port: 27015
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "34197"
    required: false
  - name: RCON_PORT
    default: "27015"
    required: false
  - name: SAVE_NAME
    default: "_autosave1"
    required: false
  - name: LOAD_LATEST_SAVE
    default: "true"
    required: false
  - name: GENERATE_NEW_SAVE
    default: "false"
    required: false
  - name: PRESET
    default: ""
    required: false
  - name: BIND
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
These env names are defined by `start.sh` (mirroring the factoriotools image so chart values carry over), not by the game. Defaults must equal those in `start.sh`. Omit `PUID`/`PGID`, `UPDATE_MODS_ON_START`, `DLC_SPACE_AGE` unless implemented. `dependencies:` none. Single `/config` volume replaces the chart's `/factorio`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-34197}"
RCON_PORT="${RCON_PORT:-27015}"
SAVE_NAME="${SAVE_NAME:-_autosave1}"
LOAD_LATEST_SAVE="${LOAD_LATEST_SAVE:-true}"
GENERATE_NEW_SAVE="${GENERATE_NEW_SAVE:-false}"
PRESET="${PRESET:-}"
BIND="${BIND:-}"

CONFIG=/config/config SAVES=/config/saves MODS=/config/mods
mkdir -p "$CONFIG" "$SAVES" "$MODS" /config/scenarios /config/script-output

[ -f /config/config.ini ] || cp /defaults/config.ini /config/config.ini

# RCON password generated once, kept 0600 in /config
if [ ! -f "$CONFIG/rconpw" ]; then
  umask 077; uuidgen | tr -d '-' > "$CONFIG/rconpw"
fi
for f in server-settings:server-settings.example map-gen-settings:map-gen-settings.example map-settings:map-settings.example; do
  dst="$CONFIG/${f%%:*}.json"; src="/app/data/${f##*:}.json"
  [ -f "$dst" ] || cp "$src" "$dst"
done
rm -f "$SAVES"/*.tmp.zip
```
then build `FLAGS` as the upstream entrypoint does (verified logic): `--config /config/config.ini --server-settings "$CONFIG/server-settings.json" --server-banlist ... --server-whitelist ... --server-adminlist ... --server-id ... --rcon-port "$RCON_PORT" --rcon-password "$(cat "$CONFIG/rconpw")" --mod-directory "$MODS"`, add `--port "$PORT"` (and `--bind "$BIND"` when set), generate a first save with `--create "$SAVES/${SAVE_NAME}.zip" --map-gen-settings ... --map-settings ...` (plus `--preset` when set) when no `*.zip` exists or `GENERATE_NEW_SAVE=true`, then use `--start-server-load-latest` when `LOAD_LATEST_SAVE=true`, else `--start-server "$SAVES/${SAVE_NAME}.zip"`. Final line:
```bash
exec /app/bin/x64/factorio "${FLAGS[@]}" "$@"
```
Rules satisfied: runs with empty `/config`, seeds only when missing, nothing under `/app`, no `setpriv`/`usermod` (already non-root), `exec`. Open point: `--rcon-password` appears in the process list (inside the container's own PID namespace); factorio offers no password-file flag in what was read. `defaults/config.ini` content:
```
[path]
read-data=__PATH__executable__/../../data
write-data=/config
```
Keep the upstream relative `read-data` so it resolves to `/app/data` (verify on first run, UNVERIFIED), and `[other]` sections as defaults. The upstream entrypoint rewrites `write-data` with `sed -i`; here the seed already has the right value, so no in-place edits are needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '27015'
filePaths:
- /start.sh
- /app/bin/x64/factorio
- /defaults/config.ini
```
- The tcp probe covers the RCON port, which is always enabled by `start.sh` (generated password).
- The game port 34197 is UDP-only and the schema's `tcp`/`http` checks cannot probe UDP (same limitation noted in `apps/luanti/container-test.yaml`). It is covered indirectly by the binary and the log line `Hosting game at IP ADDR:...` UNVERIFIED wording. Mention this gap in the PR.
- First start generates a map; allow time (`timeoutSeconds: 300`; sibling heavy apps use 120-240, schema minimum is 180).
- No DB dependency, no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/factorio` volume (saves, config, mods, scenarios, script-output) | `/config/{saves,config,mods,scenarios,script-output}` |
| `/opt/factorio/config/config.ini` (edited with sed) | seeded `/config/config.ini`, passed with `--config` |
| `/opt/factorio/saves`, `/opt/factorio/scenarios` symlinks | not needed (flags and write-data point at `/config`) |
| `write-data` default `__PATH__executable__/../..` (the install dir) | `/config` |
| lock file, `factorio-current.log`, `.lock` | under write-data, thus `/config`. UNVERIFIED: any write to `/tmp` or HOME outside it. |
| `PUID/PGID`, `usermod`, `chown -R` as root | removed; image runs as `apps` (568) |

Draft expectations: chart runs UID 0 with writable root. This port is non-root (568), `readOnlyRootFilesystem: true`, not privileged, one persistence volume `/config` instead of `/factorio`. The chart must change mount path and port to match.

## 10. Risks, caveats and open questions

- **Redistribution licence:** Factorio's ToS prohibits distributing the game or parts of it and says binaries are Wube property; it allows operating the headless server, including commercially. Publishing an image that bundles the server is not explicitly granted. The upstream factoriotools project also publishes images, but maintainers must decide (or ask factorio@factorio.com). A safer variant is downloading the archive into `/config` at first start instead of in the build; that breaks the "version baked into image" rule and needs network at runtime. Resolve before the PR.
- Draft says amd64 only; the 2.1.25 arm64 archive exists and checksums are published. Test arm64 natively; the old box64 workaround is unnecessary.
- Draft caveat: multiplayer needs licensed clients; public listing needs a Factorio account or token in `server-settings.json`.
- Draft caveat: RAM and disk for saves; first-start map generation is CPU heavy.
- Draft says "first start downloads the tarball": this plan downloads at build time instead.
- UDP port cannot be probed by forgetool; only the RCON tcp port is tested.
- Renovate datasource still to be decided (section 1).
- Space Age DLC handling (`DLC_SPACE_AGE`, `docker-dlc.sh`) is not read and is out of scope; do not add unverified env vars.

## 11. Build and test steps

```sh
cd apps/factorio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create factorio-probe-config
docker run --rm -d --name factorio-probe --read-only --tmpfs /tmp \
  -v factorio-probe-config:/config factorio:2.1.25
docker logs -f factorio-probe   # expect map creation, then "Hosting game" / server started, no repeated errors
# confirm RCON from another container (tcp 27015), and a UDP 34197 listener via `ss -lun` in the container
docker rm -f factorio-probe; docker volume rm factorio-probe-config
forgetool containers test --image factorio:2.1.25 --config ./apps/factorio/container-test.yaml
```
Also: restart on the same volume and verify the latest save is loaded and the RCON password is unchanged; repeat once with `--platform linux/arm64` if hardware allows. Max 10 rounds.

## 12. PR checklist

- [ ] Branch `feat/add-factorio`; commit and PR title `feat(factorio): add new container`; target `main`.
- [ ] PR template filled; only applicable boxes ticked.
- [ ] Notes: `🤖 This PR is AI generated.` plus the redistribution-licence question.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- [ ] `docker buildx bake --print` passed; `ARG VERSION` equals bake `VERSION`.
- [ ] Untested until run: both arch builds, checksum step, empty-`/config` first map creation under `--read-only`, UDP reachability, RCON, forgetool. Do not tick "Built container locally" unless done.
- [ ] Renovate datasource confirmed with maintainers; `LICENSE` value agreed.
