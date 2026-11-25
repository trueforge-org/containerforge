# pixark — implementation plan
> Source: ./draft.md · Target: apps/pixark/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/ich777/steamcmd:pixark` (pinned in TrueCharts `charts/stable/pixark/values.yaml`, digest `sha256:311562a48c9fabc1991b8807c166490ac59f3c1033623f8d87b6df1b1a694af1`) |
| Steam app ID | `824360` (`GAME_ID` in the chart values) |
| Version / tag | UNVERIFIED: no pixark server release or version pin was found on a fetched page. The chart pins only an image digest. |
| Renovate | UNVERIFIED: no reliable datasource. The Steam app build is not a GitHub release. Options are `datasource=deb` only if a Linux package exists (not confirmed). |
| License | Pixark server is closed source (Snail Games). UNVERIFIED license for the server files. ContainerForge's `LICENSE` must match the image's software, so set `LICENSE` to the license of the packaged software once confirmed; until then, block. |
| Source URL | Draft link `https://store.steampowered.com/app/` is a placeholder. Use `https://store.steampowered.com/app/824360` (Steam app ID from the chart) as `SOURCE`, UNVERIFIED that this page loads for the Windows dedicated server. |
| Per-arch download | amd64: the server is fetched by SteamCMD (`app_update 824360`), not a single URL. arm64: no evidence. |
| Checksum source | None: SteamCMD validates files with `validate`. |
| Upstream Dockerfile reviewed | `ich777/docker-steamcmd-server` master `Dockerfile` (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile): `FROM ich777/debian-baseimage:bullseye_amd64`; apt installs only `lib32gcc-s1 lib32stdc++6 lib32z1`; no Wine, no Xvfb; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no `USER` (runs as root); `ENV DATA_DIR=/serverdata`, `GAME_PORT=27015`, `UMASK=000`, `UID=99`, `GID=100`, `USER=steam`, `DATA_PERM=770`. The Pixark-specific install and Wine logic lives in the image's scripts, which were not fetched. |
| Ports (chart, UDP) | `27015` (main), `27016` (query), `27018` (cube). Source: TrueCharts `values.yaml`. The draft's `7777` and `27020` are not in the chart and are dropped. |
| Env (chart, real names) | `GAME_ID`, `GAME_PARAMS`, `GAME_PARAMS_EXTRA` (`-QueryPort=27016 -Port=27015 -CubePort=27018 -NoBattlEye -nosteamclient -game -server -log`), `MAP` (`CubeWorld_Light`), `SERVER_NAME`, `SRV_ADMIN_PWD`, `SRV_PWD`, `PASSWRD`, `USERNAME`, `VALIDATE`. Source: chart values. |
| arm64 | No: the server is a Windows build run under Wine (draft; UNVERIFIED on a fetched page). |
| Dependencies | None (draft: none). |

## 2. Target layout

- `apps/pixark/Dockerfile`
- `apps/pixark/docker-bake.hcl`
- `apps/pixark/settings.yaml`
- `apps/pixark/container-test.yaml`
- `apps/pixark/start.sh`
- `apps/pixark/defaults/` only if a server config template is needed (reason: UNVERIFIED, no config fetched).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Why: the upstream steamcmd image is Debian-based, but ContainerForge's rule is the ubuntu base. The closest sibling is `apps/steamcmd`, which installs `steamcmd` from apt on the same ubuntu base. Do not use `ghcr.io/trueforge-org/steamcmd` as `FROM`: `apps/steamcmd/Dockerfile` has no published digest to pin and its `/start.sh` and `/usr/local/bin/steamcmd` wrapper would be overwritten by this app's `start.sh`. Repeat the install instead. Wine and Xvfb are added on top (see section 4).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install SteamCMD as `apps/steamcmd/Dockerfile` does: `dpkg --add-architecture i386`, `add-apt-repository -y multiverse`, debconf `I AGREE`, `apt-get install -y --no-install-recommends steamcmd:i386=0~${VERSION}` with the package version `0~20180105-5build1` from `apps/steamcmd/docker-bake.hcl` (`VERSION` default `20180105-5build1`). Do not reuse `ARG VERSION` for this: the pixark bake `VERSION` is still UNVERIFIED (section 5) and must not be the steamcmd package version, so use a separate `ARG STEAMCMD_VERSION` with its own bake variable and renovate comment (`datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`, as in `apps/steamcmd`).
3. Install Wine and Xvfb: `apt-get install -y --no-install-recommends wine64 xvfb` (package names UNVERIFIED for ubuntu 26.04; check `apt-cache policy` in the build). Pin to versions that exist in the base release.
4. `mkdir -p /config`, `chown -R apps:apps /config`, `rm -rf /var/lib/apt/lists/*`.
5. `COPY --chmod=0755 start.sh /start.sh`, `USER apps`, `COPY --chmod=0755 . /`.
6. `ENV HOME=/config WINEPREFIX=/tmp/wine WINEDEBUG=-all XDG_RUNTIME_DIR=/tmp` (keep Wine state out of `/config` only if it does not need to persist; decide in section 9).
7. `EXPOSE 27015/udp 27016/udp 27018/udp`, `VOLUME /config`.

Not used: no `ENTRYPOINT` in the Dockerfile; `start.sh` is the entry.

## 5. docker-bake.hcl

Copy `apps/steamcmd/docker-bake.hcl` shape:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pixark"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/824360"
}
```

`VERSION` cannot be set until a pinnable Pixark version or build ID source is found. Keep the four standard targets and the default group as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/824360"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27016
    protocol: udp
    required: false
  - port: 27018
    protocol: udp
    required: false
env:
  - name: GAME_PARAMS
    default: "?MaxPlayers=10"  # UNVERIFIED: not found in chart values, confirm
    required: false
  - name: SERVER_NAME
    default: "PIXARKDocker"  # UNVERIFIED: chart default not read
    required: false
  - name: MAP
    default: "CubeWorld_Light"
    required: false
  - name: SRV_PWD
    default: ""
    required: false
  - name: SRV_ADMIN_PWD
    default: ""
    required: false
  - name: VALIDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. Only list env vars the start script reads (verify each name against the server launch; `GAME_PARAMS_EXTRA` is included only if `start.sh` passes it). Keep `required: false` because the server starts with defaults.

## 7. start.sh

- Idempotent. Create `/config/steamcmd` and `/config/serverfiles` only when missing (seeding only when empty; no overwrite of user state).
- Run SteamCMD `app_update 824360` (with `validate` only when `VALIDATE=true`) into `/config/serverfiles`. Use the `apps/steamcmd/start.sh` pattern for login and runscript.
- Start the server under Wine with `Xvfb :99 -screen 0 1024x768x16 &` and `exec wine ... PixarkServer.exe ${GAME_PARAMS_EXTRA}` (exact binary path UNVERIFIED).
- Bind to `0.0.0.0` (the Steam server flags above do not expose a bind address; check the server's config after first start).
- Caches and Wine prefix in `/tmp` or `/config`, per section 9.
- Never write to `/app`.
- End with `exec` of the server process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

`/usr/local/bin/steamcmd` exists only if the Dockerfile recreates the wrapper that `apps/steamcmd/Dockerfile` writes; otherwise drop it (or use `/usr/games/steamcmd`, installed by the apt package).

UDP ports are not covered by the schema's `tcp` probe. Add a `tcp` probe only if the server also opens TCP (UNVERIFIED). Note in the file that this is narrowed: the server needs a full SteamCMD download, so the test covers the startup path, not gameplay. `timeoutSeconds` is a large value because the first start downloads the server files.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` (chart PVC) | `/config/serverfiles` |
| `/serverdata/steamcmd` (chart PVC) | `/config/steamcmd` |
| Wine prefix (UNVERIFIED location) | `/tmp/wine` (ephemeral) or `/config/wine` if save data needs it |
| Xvfb socket and locks | `/tmp/.X11-unix` (must be writable on `--tmpfs /tmp`) |

Chart runs as UID 0 (`runAsUser: 0`) with `readOnlyRootFilesystem: false`. The ContainerForge image runs as `apps` and must work with `--read-only --tmpfs /tmp`, so the chart's root setting does not carry over. The chart's PVC paths move under `/config`, so existing data needs a one-time copy from `/serverdata` to `/config` (document in the PR).

## 10. Risks, caveats and open questions

- Blocker (until verified): a Windows-only server under Wine. Wine and Xvfb installs are not in the upstream steamcmd Dockerfile fetched, so the Pixark-specific image is UNVERIFIED for those steps.
- Blocker: no pinned version or renovate source. `VERSION` cannot be set honestly until a source is found.
- Blocker: license of the server files is UNVERIFIED; the bake `LICENSE` must be correct.
- arm64: not supported (Windows build under Wine). Build `image-local` on amd64 only; `image-all` should list `linux/amd64` only, as `apps/steamcmd` does.
- Large first-start download and Wine startup (inferred): set a long `timeoutSeconds`.
- Ports 27015, 27016 and 27018 UDP must be published for players and admins (chart). The draft's 7777 and 27020 are removed.
- The `-NoBattlEye` and `-nosteamclient` flags come from the chart and are not confirmed as required in this image.
- Security: chart runs as root and not read-only; this image must not. Any step that needs root (apt) stays in the build stage.

## 11. Build and test steps

```sh
cd apps/pixark
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pixark-probe --read-only --tmpfs /tmp \
  -v pixark-probe-config:/config pixark:<version>
docker logs -f pixark-probe
forgetool containers test --image pixark:<version> --config ./apps/pixark/container-test.yaml
docker rm -f pixark-probe; docker volume rm pixark-probe-config
```

Readiness signal: the server process stays up after SteamCMD finishes, and the UDP port 27015 is open (`ss -lun`). Readiness log line is UNVERIFIED until a real server run.

## 12. PR checklist

- Branch `feat/add-pixark`, commit and PR title `feat(pixark): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the image build (none yet), Wine startup, the server start on `--read-only`, UDP reachability, the version pin and renovate source, and the license.
- Do not check "Built container locally" unless a build ran.
