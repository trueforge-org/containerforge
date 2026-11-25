# necesse — implementation plan
> Source: ./draft.md · Target: apps/necesse/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no Necesse release or build number confirmed. The game updates through SteamCMD, so the image has no pinned game version. Pin the SteamCMD base (`apps/steamcmd` VERSION `20180105-5build1`) and record the Steam build at first install. |
| Renovate | UNVERIFIED for the game: no version source confirmed. The base image version follows `apps/steamcmd/docker-bake.hcl` (`datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`). |
| License | UNVERIFIED for Necesse (proprietary game; the server is distributed through Steam, not as an open-source package). The wrapper license is not confirmed. Use the license of the ContainerForge wrapper, `AGPL-3.0-or-later` as in `apps/steamcmd`, and say so in the PR. |
| Source URL | https://necessegame.com (website, from the draft). Not a source repository. |
| Documentation | https://necessewiki.com (from the draft, not fetched). |
| Game binary | Steam dedicated server, installed by SteamCMD at start. Draft cites Steam app 1169370. UNVERIFIED: the Steam store fetch returned the Steam home page, not the game page, so the app id and the dedicated-server app id are not confirmed. |
| Per-arch download | amd64: via SteamCMD (anonymous login). arm64: not available (see below). |
| Checksum source | None from upstream. SteamCMD validates with `validate` (`STEAM_APP_VALIDATE=true` in `apps/steamcmd/start.sh`). |
| Upstream wrapper Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, installs `lib32gcc-s1 lib32stdc++6 lib32z1`, creates `steam`, no `USER` (runs as root), ENV `DATA_DIR=/serverdata`, `GAME_PORT=27015`, `UID=99`, `GID=100`, `UMASK=000`. No EXPOSE, no VOLUME. `ENTRYPOINT ["/opt/scripts/start.sh"]`. start.sh NOT fetched: UNVERIFIED. |
| Necesse GAME_ID | UNVERIFIED: the ich777 README shows no Necesse entry. |
| Ports | UNVERIFIED: `14159/udp` is from the draft (inferred). No fetched page confirms it. |
| Data paths | Draft: game server in `/config`, caches in `/tmp`. UNVERIFIED for Necesse's own save and config paths. |
| arm64 | No. `apps/steamcmd` installs `steamcmd:i386` from Ubuntu multiverse, an x86 bootstrap. The draft's `copy-from arm64: no` matches this. |

Draft corrections: the draft's `arm64: yes` in the "Application binary" field conflicts with the `copy-from arm64: no` and with SteamCMD being x86 only. Treat arm64 as not supported.

## 2. Target layout

Files in `apps/necesse/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: installs or updates the Necesse server through SteamCMD into `/config`, then `exec`s the server)
- `defaults/` — not needed unless a default `Server.cfg` needs seeding (decide once the server layout is confirmed)
- `DOWNSTREAM_CHANGES.md` — not needed (not a `FROM` base)

## 3. Base image

- Runtime base: `ghcr.io/trueforge-org/steamcmd` (`apps/steamcmd`). The draft's choice is confirmed: that image provides `steamcmd` and `start.sh` that installs apps from `STEAM_APP_IDS`.
- Its own base: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Pin the steamcmd image by the digest in `apps/steamcmd/docker-bake.hcl`/Dockerfile (copy the FROM line from `apps/steamcmd/Dockerfile`).
- Closest sibling: `apps/steamcmd` itself. No other game-server sibling confirmed.

## 4. Dockerfile

Minimal, because `apps/steamcmd` already provides SteamCMD and `start.sh`:

1. `ARG VERSION`, `ARG TARGETARCH`.
2. `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:…` (digest copied from the steamcmd build output, or the image built from `apps/steamcmd`).
3. `USER root` only if apt is needed. Expect none.
4. `COPY --chmod=0755 start.sh /start.sh` (game-specific install and run logic) and `USER apps`.
5. `ENV` only defaults the game needs. Use `GAME_PORT`/`PORT` only if confirmed.
6. `EXPOSE 14159/udp` only once confirmed.
7. `VOLUME /config` (the steamcmd base already writes `/config`).
8. `COPY --chmod=0755 . /`.

Key rule: a container built on `steamcmd` must start with an empty `/config`, so `start.sh` must create dirs and let SteamCMD install on first run.

## 5. docker-bake.hcl

- `APP = "necesse"`
- `VERSION` pinned to the steamcmd image tag (the wrapper version), with `// renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd` style annotation. UNVERIFIED for the exact datasource string; copy the pattern used by a sibling built on a ContainerForge base (`apps/valkey`, `apps/budge`).
- `LICENSE = "AGPL-3.0-or-later"` (see section 1 caveat).
- `SOURCE = "https://necessegame.com"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (linux/amd64 only, matching the steamcmd base), `group "default"`.
- Validate with `docker buildx bake --print` from `apps/necesse/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://necessegame.com"
ports:
  - port: 14159
    protocol: udp
    required: true
env:
  - name: STEAM_APP_IDS
    default: "1169370"   # UNVERIFIED app id
    required: true
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `STEAM_APP_IDS` and `STEAM_USERNAME` are read by `apps/steamcmd/start.sh`; the names match.
- Do not list the game's own env vars until they are confirmed.
- Ports: `14159/udp` is UNVERIFIED. The protocol says UDP ports need a probe too, but `tcp`/`http` probes do not cover UDP (see section 8).

## 7. start.sh

- `set -euo pipefail`.
- Export `HOME=/config` and `XDG_DATA_HOME=/config`, and use `/tmp` for caches (SteamCMD scratch via the base's `STEAMCMD_TMP_DIR`, which is `/config/steamcmd/tmp` in the base: decide whether to override it to `/tmp` and record the decision).
- Install or update the server: `STEAM_APP_IDS` is passed to the base `start.sh`, which runs `app_update <id>` into `STEAM_INSTALL_DIR` (default `/config/steamapps`). Set `STEAM_INSTALL_DIR=/config/necesse`. Do not write under `/app`.
- After install, run the Necesse server binary from the install dir with `exec`. The binary path and arguments are UNVERIFIED (not confirmed from the ich777 start.sh or the game docs).
- Idempotent: SteamCMD re-runs with `validate` only when `STEAM_APP_VALIDATE=true`.
- Do not expose the Steam password in `ps` (use `STEAM_PASSWORD`, not args).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- Probes: no `tcp` probe for `14159/udp` (forgetool's `tcp` is TCP). Use a `filePaths` check instead, and say so in the PR. Add a UDP check only if forgetool supports one.
- The test runs with no env vars, so the steamcmd base's first install (which needs network and Steam) will not run in CI. Narrow the test with the protocol's DB-style exception only if all three criteria apply. They do not (no DB dependency), so state the gap in the PR instead of narrowing silently.

## 9. Rootless and read-only-rootfs adaptations

- Draft security expectations are partly wrong: the wrapper runs as root with `runAsUser 0` in the chart. The ContainerForge base runs `start.sh` as `apps` and writes to `/config`, so non-root is achievable.
- Read-only rootfs: SteamCMD writes its own files under `HOME=/config` and caches in `/tmp`. Must confirm that SteamCMD does not write into `/usr/local/share/steamcmd` at runtime.
- Privileged: no. Extra persistence: none beyond `/config`.
- The chart's `/serverdata/serverfiles` and `/serverdata/steamcmd` mounts map to `/config/necesse` and `/config/steamcmd` in this layout.

## 10. Risks, caveats and open questions

- **arm64 not supported.** The steamcmd base is an x86 bootstrap. Keep `image-all` amd64-only, and say so in the PR.
- **Steam app id UNVERIFIED.** Confirm via SteamDB or the Steam store (the fetched store page was the home page). The app id `1169370` is only a draft value.
- **Server binary path and launch args UNVERIFIED.** The ich777 wrapper `start.sh` was not fetched. Read it (or the Necesse wiki) before writing the final `exec`.
- **Game version not pinned.** Steam updates the game on its own schedule. Decide whether to pin a build (via `validate` on a known build) or accept latest and document it.
- **Large first download.** The first start downloads the server, which may take minutes. The protocol's "still running" window must allow for this, or the probe will fail on an empty `/config`.
- **UDP port 14159.** Players must reach it, so UDP forwarding is required. The test cannot prove reachability.
- **Licence.** Necesse is proprietary. The wrapper licence is the only one this repo can state.
- Blockers: arm64 unsupported (accepted limit); SteamCMD needs a Steam network connection at build or first run.

## 11. Build and test steps

From `apps/necesse/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty `/config` volume and a long startup window (first install is slow):
   ```sh
   docker run --rm -d --name necesse-probe --read-only --tmpfs /tmp \
     -e STEAM_APP_IDS=<confirmed id> -v necesse-probe-config:/config necesse:<VERSION>
   docker logs -f necesse-probe
   docker rm -f necesse-probe; docker volume rm necesse-probe-config
   ```
   Expected readiness signal: UNVERIFIED until the server's log line is seen on a real install.
4. `forgetool containers test --image necesse:<VERSION> --config ./apps/necesse/container-test.yaml`
5. Clean up scratch containers and volumes.

## 12. PR checklist

- Branch `feat/add-necesse`, commit `feat(necesse): add new container`, PR title the same.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, all sections and checkboxes kept; only tick boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested: the Steam app id, server launch args, arm64 (not supported), UDP reachability, and the first-run download.
