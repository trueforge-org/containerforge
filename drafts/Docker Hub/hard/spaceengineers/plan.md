# spaceengineers — implementation plan
> Source: ./draft.md · Target: apps/spaceengineers/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | The game server has no semver release: it is the Steam app 298740 (Space Engineers Dedicated Server), pulled by SteamCMD at runtime. Draft tag `latest`. The upstream image pins Wine 9.0 (`WINEVERSION=9.0.0.0~bookworm-1`, `latest`) or Wine 9.9 (`winestaging`) on `debian:bookworm-20241016-slim`. Image `VERSION` here tracks the Wine apt package (see section 5); resolve the exact Ubuntu 26.04 version with `apt-cache policy wine` (UNVERIFIED) |
| Renovate | `datasource=deb depName=wine registryUrl=https://archive.ubuntu.com/ubuntu` (same pattern as `apps/steamcmd`); UNVERIFIED that the Ubuntu 26.04 archive carries `wine` under that name |
| License | The image contains Wine (LGPL-2.1-or-later) and SteamCMD (Steam license). The game server itself is Keen Software House proprietary, free to download with anonymous login, not redistributed in the image. Use `LGPL-2.1-or-later` |
| Source | https://www.spaceengineersgame.com/ (draft) ; packaging reference https://github.com/Devidian/docker-spaceengineers |
| Download | SteamCMD: `+@sSteamCmdForcePlatformType windows +force_install_dir <dir> +login anonymous +app_update 298740 validate +quit` (app id confirmed by search results and Valve's dedicated server list). amd64 only (Windows build under Wine) |
| Checksum | Steam verifies content itself (`validate`); no separate checksum |
| Upstream Dockerfile | `Devidian/docker-spaceengineers` at 26569e3: `debian:bookworm-20241016-slim`, i386 arch, WineHQ repo, `libfaudio0`, `winehq-stable`, `steamcmd`, `xvfb`, `cabextract`, winetricks, `WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server`, `ENTRYPOINT /root/entrypoint.sh`, healthcheck `/root/healthcheck.sh` (start period 600s). The entrypoint and winetricks scripts could not be read (404): UNVERIFIED what winetricks components are installed |
| Ports | 27016/udp (README, host mode). 27015/udp and 8766/udp in the draft are inferred and not listed upstream: UNVERIFIED |
| Env (README) | `WINEDEBUG=-all`, `INSTANCE_NAME` (world instance name), `PUBLIC_IP` (needed for the upstream healthcheck) |
| Paths | `/appdata/space-engineers/plugins`, `.../instances`, `.../SpaceEngineersDedicated`, `/root/.steam` |
| Dependencies | none |

## 2. Target layout

```
apps/spaceengineers/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
`root/` is not used. No DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (the draft's alternative). The draft prefers `ghcr.io/trueforge-org/steamcmd`, but that image owns `/start.sh` and `/usr/local/bin/steamcmd` and `COPY . /` would overwrite them; no app in this repo uses it as a `FROM`, and it has no `DOWNSTREAM_CHANGES.md`. So install the same steamcmd package as `apps/steamcmd` (multiverse, i386) on plain ubuntu. Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; amd64 only.
2. `USER root`; `dpkg --add-architecture i386`; `apt-get update`; `add-apt-repository -y multiverse`; `echo steamcmd steam/question select "I AGREE" | debconf-set-selections` and the `steam/license note ''` line, exactly as in `apps/steamcmd/Dockerfile`.
3. `apt-get install -y --no-install-recommends steamcmd:i386 wine=${VERSION}* wine64=${VERSION}* xvfb winbind cabextract winetricks` (package names and pinning UNVERIFIED on 26.04; pin `wine` and check against `VERSION`, as `apps/valkey` does with a `test` guard). Do not reinstall curl, wget, ca-certificates (in base).
4. `ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd`.
5. License files: copy `/usr/share/doc/wine*/copyright` to `/usr/share/licenses/spaceengineers/wine-copyright`.
6. `ENV HOME=/config WINEPREFIX=/config/wineprefix WINEARCH=win64 WINEDEBUG=-all XDG_DATA_HOME=/config XDG_CACHE_HOME=/tmp/.cache`.
7. `mkdir -p /config && chown apps:apps /config`, `rm -rf /var/lib/apt/lists/*`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 27016/udp`, `VOLUME /config`, `WORKDIR /config`, final `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "spaceengineers" }
variable "VERSION" {
  // renovate: datasource=deb depName=wine registryUrl=https://archive.ubuntu.com/ubuntu
  default = "<wine version from apt-cache policy wine>"
}
variable "LICENSE" { default = "LGPL-2.1-or-later" }
variable "SOURCE" { default = "https://www.spaceengineersgame.com/" }
```
Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` with `platforms = ["linux/amd64"]` only (Wine on arm64 not supported, as `apps/steamcmd`), `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://www.spaceengineersgame.com/"`.
- ports: `27016` udp, required true.
- env: `TZ` (`Etc/UTC`, false), `INSTANCE_NAME` (default `SpaceEngineers`, false; start.sh uses the same default), `PUBLIC_IP` (default "", false), `WINEDEBUG` (default `-all`, false).
- volumes: `/config` required true (game files, Wine prefix, steam data, worlds, plugins).
- dependencies: none (steamcmd functionality is built in; `steamcmd` is not a runtime dependency container).

## 7. start.sh

1. `set -euo pipefail`; `: "${INSTANCE_NAME:=SpaceEngineers}"`; `mkdir -p /config/{SpaceEngineersDedicated,instances,plugins,wineprefix}`.
2. Update game only when needed and always idempotently: `steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir /config/SpaceEngineersDedicated +login anonymous +app_update 298740 validate +quit` (several GB on first start, needs internet); steam data goes to `/config/.steam` via `HOME=/config`.
3. Initialise the Wine prefix once, guarded by `/config/wineprefix/.initialised`: `wineboot --init`, then winetricks components the server needs (UNVERIFIED which; upstream Dockerfile runs a `winetricks.sh`, content unseen). Use `xvfb-run` only if the server needs a display (UNVERIFIED).
4. Seed `/config/instances/${INSTANCE_NAME}` only when missing (user uploads worlds there). Copy plugins from `/config/plugins` into the game dir on each start (upstream entrypoint adds/removes them).
5. Final command: `exec wine /config/SpaceEngineersDedicated/DedicatedServer64/SpaceEngineersDedicated.exe -noconsole -ignorelastsession -path "Z:\\config\\instances\\${INSTANCE_NAME}"`. Flags `-noconsole -ignorelastsession -path` come from a hosting knowledge base and the exe location from common guides: UNVERIFIED, check against the upstream entrypoint. The server binds all interfaces by default (UDP game port from the instance config, `ServerPort` 27016: UNVERIFIED).
6. The draft's postStart `sed` on the config is replaced by setting `PublicIP`/port values in the instance config only when the file is first created.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
healthCommands:
- command: bash -c 'ss -lun | grep -q ":27016 "'
runners:
- entrypoint: wine --version
- entrypoint: test -x /usr/local/bin/steamcmd
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```
UNVERIFIED: that `ss` (iproute2) exists in the ubuntu base; if not, install `iproute2` in the Dockerfile or read `/proc/net/udp` instead. The schema has no `udp` probe, so the UDP port 27016 is checked with a `healthCommands` `ss -lun` assertion. Risk: it only passes if the first-run SteamCMD download (several GB, internet) and Wine setup finish within the timeout; `timeoutSeconds: 600` copies the longest sibling value. If CI has no internet this assertion cannot pass: maintainers must decide between a longer timeout or narrowing the test, and it must not be turned into a no-op (see section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream path | Remap |
|---|---|
| `/root/.steam` (steam cache) | `/config/.steam` via `HOME=/config` |
| `/root/server` (Wine prefix) | `/config/wineprefix` |
| `/appdata/space-engineers/SpaceEngineersDedicated` | `/config/SpaceEngineersDedicated` |
| `/appdata/space-engineers/instances` | `/config/instances` |
| `/appdata/space-engineers/plugins` | `/config/plugins` |
| Wine/X temp, `/tmp/.X11-unix` | `/tmp` (tmpfs) |

Draft: root UID 0, writable rootfs. Image runs UID 568 with read-only rootfs; Wine only writes under `WINEPREFIX` and `/tmp`. The four persistence paths collapse into one `/config` volume (game files are large; size it for 10+ GB).

## 10. Risks, caveats and open questions

- The dedicated server runs under Wine: heavy RAM/CPU, slow first start, large download; amd64 only (arm64 blocker).
- The image `VERSION` is the Wine package version, not the game: the game version is whatever Steam serves at start. Maintainers may prefer a different versioning scheme.
- UNVERIFIED: Wine package name/version on Ubuntu 26.04, winetricks components, exe path and CLI flags (upstream entrypoint unreadable), additional UDP ports (27015, 8766).
- UDP port cannot be probed with the schema's tcp/http primitives (see section 8).
- Game download needs internet at first start; Steam anonymous login must stay available.
- Draft says the chart's probes are disabled; do not copy that, keep a startup window instead.

## 11. Build and test steps

```sh
cd apps/spaceengineers
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name spaceengineers-probe --read-only --tmpfs /tmp -v spaceengineers-probe-config:/config spaceengineers:<VERSION>
docker logs -f spaceengineers-probe
forgetool containers test --image spaceengineers:<VERSION> --config ./apps/spaceengineers/container-test.yaml
docker rm -f spaceengineers-probe; docker volume rm spaceengineers-probe-config
```
Readiness: SteamCMD logs `Success! App '298740' fully installed`, then the server log shows it started and `docker exec spaceengineers-probe ss -lun` lists 27016. Allow 10 minutes on first start.

## 12. PR checklist

- Branch `feat/add-spaceengineers`, commit `feat(spaceengineers): add new container`, target `main`.
- Use the PR template; only tick what applies.
- Notes: `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge ; only the user can sign it.
- Untested: everything runtime (Wine prefix creation, game download, UDP reachability from another host, plugins); say so if the image was not built or run.
- Pre-completion: `bake --print`, version alignment, final `USER apps`, empty `/config` start.
