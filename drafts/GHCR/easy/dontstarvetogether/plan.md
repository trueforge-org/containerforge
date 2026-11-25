# dontstarvetogether — implementation plan
> Source: ./draft.md · Target: apps/dontstarvetogether/ · Difficulty: easy · Role: main · Verified on 2026-11-25
> Status: BLOCKED on two unverified facts (dedicated server Steam app ID, game ports). See sections 1 and 10.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Game | Don't Starve Together (Steam store app 322330, client). Source: https://store.steampowered.com/app/322330/ |
| Dedicated server Steam app ID | UNVERIFIED: the draft's 343050 returned `success: false` from https://store.steampowered.com/api/appdetails?appids=343050, and the store page for 322330 lists no dedicated server app. The ID must be confirmed (for example from a SteamDB or Klei page) before the install step can be written. |
| Version to build | UNVERIFIED: no versioned upstream artifact. The server is pulled from Steam at start, so there is no pinned version to renovate. |
| Renovate | UNVERIFIED: no datasource fits. Pin the base image only (see section 3). |
| License | UNVERIFIED: the game is closed source under the Klei EULA. Use the container's own license (see section 5). |
| Source URL | https://www.klei.com/games/dont-starve-together (draft) |
| Download | amd64 only: SteamCMD downloads the server into `/config` at start. No direct URL. |
| Checksum source | SteamCMD `validate` only (no published checksum). |
| Upstream container | ich777 wrapper, https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, user `steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no VOLUME, no EXPOSE, no USER. Runs as root. |
| Upstream env (wrapper) | `DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME`, `PASSWRD`, `USER=steam`, `DATA_PERM=770`. Source: the same Dockerfile and https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md. These are the wrapper's variables, not DST's. |
| Ports | UNVERIFIED: 10999/udp, 10998/udp, 27016/udp from the draft are not confirmed by any fetched page. The wrapper's 27015 is an example only. |
| Data paths | Server files and SteamCMD state live under `/config` in our layout (see section 2). Klei cluster save path (`~/.klei/DoNotStarveTogether`) is UNVERIFIED for the Linux server. |
| arm64 | No. SteamCMD's 32-bit x86 bootstrap does not run on arm64. |

## 2. Target layout

apps/dontstarvetogether/
- Dockerfile (FROM steamcmd base, `USER apps`, `COPY --chmod=0755 . /`)
- docker-bake.hcl
- settings.yaml
- start.sh
- container-test.yaml

No `defaults/`, `etc/` or `health/`: nothing needs seeding beyond what start.sh creates. No `root/`. No DOWNSTREAM_CHANGES.md (not used as a FROM base).

## 3. Base image

- FROM `ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`. Digest: UNVERIFIED. The steamcmd image is built by CI and no `apps/*/Dockerfile` in this repo consumes it yet, so take the digest from the published manifest at build time, not from memory.
- Foundation is `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (through steamcmd).
- Closest sibling: `apps/steamcmd` (the steamcmd base; its start.sh already seeds `/config/Steam/steamcmd` and installs app IDs from `STEAM_APP_IDS`). No other game server in `apps/` uses it yet.
- Rationale: steamcmd provides the 32-bit runtime and the seeded SteamCMD, so this image needs only a start script.

## 4. Dockerfile

1. `FROM` steamcmd base as above. `ARG VERSION`, `ARG VENDOR` only if the base expects them (check `apps/steamcmd/Dockerfile`).
2. No install step is expected. The DST server is downloaded at start. If an install is needed, `USER root` only for apt, then `USER apps`.
3. Do not install `lib32*` packages again: the base already provides the 32-bit stack (check the base before adding anything).
4. `ENV HOME=/config XDG_DATA_HOME=/config`. Caches to `/tmp` (`TMPDIR=/tmp`).
5. `COPY --chmod=0755 start.sh /start.sh` is covered by `COPY --chmod=0755 . /` (allow-list in include/.dockerignore includes start.sh).
6. `VOLUME /config` in the Dockerfile (required by the repo rules; settings.yaml lists it too). `EXPOSE` only for ports confirmed in section 1.
7. Final: `USER apps`, then `COPY --chmod=0755 . /` (this app's `start.sh` replaces the base `/start.sh`; the base `/usr/local/bin/steamcmd` wrapper execs `/start.sh`, so it no longer works as the base intended. Section 7 calls `steamcmd.sh` directly, so this is acceptable).

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "dontstarvetogether" }`
- `variable "VERSION"`: the steamcmd base tag. Use `// renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd` only if the base is versioned by tag; otherwise use the base tag pinned in the Dockerfile and align it here. UNVERIFIED: the steamcmd base tag scheme.
- `variable "LICENSE"`: the container's license, `AGPL-3.0-or-later` to match the sibling steamcmd and nginx apps. The game itself is not open source; say so in the PR.
- `variable "SOURCE" { default = "https://www.klei.com/games/dont-starve-together" }`
- `group "default" { targets = ["image-local"] }`, plus `image`, `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` (`linux/amd64` only, since arm64 is unsupported).
- Validate: `cd apps/dontstarvetogether && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://www.klei.com/games/dont-starve-together"`.
- `ports`: UNVERIFIED. Add only ports confirmed in section 1. Until then, leave `ports: []`, which is what steamcmd uses, and note the gap in section 10.
- `env` (only what start.sh reads):
  - `TZ` (default `Etc/UTC`, required false)
  - `DST_CLUSTER_TOKEN`: required for listing. Name UNVERIFIED; take it from the DST server docs before adding.
  - `STEAM_APP_IDS` only if the base's mechanism is used. Recommended: do not use it, since the base start.sh ends with `exec steamcmd` (see section 7).
- `volumes`: `- path: /config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `export HOME=/config`, `XDG_DATA_HOME=/config`.
- Install or update the server into `/config/serverfiles` (or a dedicated path under `/config`) with the SteamCMD binary at `/config/Steam/steamcmd/steamcmd.sh`, seeded on first run from `/usr/local/share/steamcmd` (same pattern as the steamcmd base). Do not reuse the base's `exec` at the end: it launches an interactive SteamCMD. Call SteamCMD directly with `+force_install_dir /config/serverfiles +login anonymous +app_update <APPID> validate +quit`.
- Seed nothing else. Write only under `/config` and `/tmp`. Never write to `/app`.
- Idempotent: rerun `app_update` on every start (it is an update); the first run downloads the server.
- Bind to all interfaces: the DST server binds per its `dontstarve_dedicated_server_nullrenderer` config. Confirm the bind address and port from the server config (UNVERIFIED).
- Final step: `exec /config/serverfiles/bin64/dontstarve_dedicated_server_nullrenderer_x64 -cluster ... -shard ...`. Binary path and flags UNVERIFIED.

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/share/steamcmd/steamcmd.sh` (the steamcmd base files).
- `timeoutSeconds`: the first run downloads the server, so use a large value (for example 600). Check sibling steamcmd-style timeouts before fixing the number.
- `tcp`/`udp` probes: only for ports confirmed in section 1. UNVERIFIED for DST.
- Test runs with no env vars, so the no-token path (listing requires a cluster token) is not tested; cover it with `filePaths` if a file is needed.
- No weakened assertions. If the server cannot be exercised without Steam access, narrow the test only per the DB exception rules (not applicable here: no DB dependency). Document any narrowing in the file.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (`runAsUser 0` in the TrueCharts chart). Our image runs as `apps`. The chart values must change in a separate chart PR, not here.
- `readOnlyRootFilesystem`: the chart sets false. Our image needs `/config` and `/tmp` only, so it can run read-only. Verify with `--read-only --tmpfs /tmp`.
- Upstream extra persistence (`/serverdata/serverfiles`, `/serverdata/steamcmd`, `/serverdata/.klei/DoNotStarveTogether`) becomes `/config` subpaths. Remap every write in start.sh. The `.klei` path must be remapped through `HOME=/config`.
- UID: `apps` (container default), not `99`/`100` from the wrapper. Do not set `UID`/`GID`.
- `privileged`: no. Chart default is false.

## 10. Risks, caveats and open questions

- BLOCKER: dedicated server Steam app ID unverified (draft's 343050 not confirmed).
- BLOCKER: game ports unverified (10999/udp, 10998/udp, 27016/udp are draft inferences).
- BLOCKER: Klei cluster token needed for the shard to list (draft inference, UNVERIFIED upstream). Decide whether to require it or only warn.
- arm64 unsupported: `image-all` is amd64 only.
- First start is slow (Steam download); test timeout must allow for it.
- Upstream image is a root-run wrapper; the rootless rewrite of start.sh is new work, not a port of the upstream script.
- Steam anonymous login is used; dedicated server downloads need no account, but the cluster token is still needed.
- Steam app ID and version are not renovated: updates happen at container start via `app_update`, so the image does not pin the game version.

## 11. Build and test steps

From `apps/dontstarvetogether/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run: `docker run --rm -d --name dontstarvetogether-probe --read-only --tmpfs /tmp -v dontstarvetogether-probe-config:/config dontstarvetogether:<VERSION>`, then `docker logs -f dontstarvetogether-probe`.
   - Expected readiness: UNVERIFIED (the DST server's "Sim paused" or "Serving" line must be confirmed from a real run).
   - Pass criteria per protocol: container stays up, readiness line appears, no fatal error.
4. Cleanup: `docker rm -f dontstarvetogether-probe; docker volume rm dontstarvetogether-probe-config`.
5. Tests: `forgetool containers test --image dontstarvetogether:<VERSION> --config ./container-test.yaml`.
6. Not run in this plan. Steps 2 to 5 need network access to Steam and are long (first run downloads the server).

## 12. PR checklist

- Branch: `feat/add-dontstarvetogether`
- Commit and PR title: `feat(dontstarvetogether): add new container`
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only what applies.
- Not tested: state clearly that the server was not run unless step 3 passed.
- Do not check "Built container locally" unless step 2 passed.
- Include the open blockers from section 10 in the PR description.
