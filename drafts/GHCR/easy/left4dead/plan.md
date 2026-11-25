# left4dead — implementation plan
> Source: ./draft.md · Target: apps/left4dead/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No upstream release or version tag. The TrueCharts image is `ghcr.io/ich777/steamcmd:l4d`, a rolling branch tag (https://github.com/ich777/docker-steamcmd-server/tree/l4d). Pin a value for `VERSION` before implementation (see section 10). |
| Renovate | UNVERIFIED: no upstream version to track. Candidate: `datasource=docker depName=ghcr.io/ich777/steamcmd` (not fetched; confirm before use). |
| License | UNVERIFIED: no LICENSE retrieved for ich777/docker-steamcmd-server (raw LICENSE returned 404; repo page names none). Game content is Valve's, under Steam's subscriber agreement; the wrapper license must be confirmed before `LICENSE` is set. |
| Steam app ID | 222840 (`GAME_ID` on branch l4d, https://github.com/ich777/docker-steamcmd-server/tree/l4d). |
| Game name and params | `GAME_NAME=left4dead`, `GAME_PARAMS=+maxplayers 4 +map l4d_farm04_barn` (same page). |
| Source URL | https://store.steampowered.com/app/500/Left_4_Dead/ (draft link; the Valve wiki link in the draft was not retrievable, 403). |
| Download | Not a release asset. SteamCMD downloads app 222840 at start (`app_update 222840`). |
| Checksum source | None. SteamCMD validates the install with `validate` when requested. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: FROM `ich777/debian-baseimage:bullseye_amd64`; apt lib32gcc-s1, lib32stdc++6, lib32z1; ENV DATA_DIR=/serverdata, STEAMCMD_DIR, SERVER_DIR, GAME_PORT=27015, UID=99, GID=100, USER=steam, UMASK=000, VALIDATE, USERNAME, PASSWRD; no EXPOSE, no VOLUME, no USER; ENTRYPOINT /opt/scripts/start.sh. |
| Upstream start.sh reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: remaps user to UID/GID, chowns DATA_DIR, runs `start-server.sh` as the user. The download logic is in `start-server.sh`, which was not retrieved: UNVERIFIED. |
| Ports | 27015/tcp and 27015/udp (README example, branch l4d). The draft's 27005/udp is UNVERIFIED and is dropped. |
| Env vars (real, upstream) | DATA_DIR, STEAMCMD_DIR, SERVER_DIR, GAME_ID, GAME_NAME, GAME_PARAMS, GAME_PORT, VALIDATE, UMASK, UID, GID, USERNAME, PASSWRD, USER, DATA_PERM. The ContainerForge `steamcmd` image reads STEAM_USERNAME, STEAM_USER, STEAM_PASSWORD, STEAMCMD_PRE_UPDATE, STEAMCMD_SKIP_APP_UPDATE, STEAM_APP_IDS, STEAM_APP_VALIDATE, STEAM_INSTALL_DIR (apps/steamcmd/start.sh). |
| Data paths (upstream) | /serverdata/steamcmd and /serverdata/serverfiles (README volume mapping). ContainerForge: /config/steamcmd and /config/serverfiles (see section 9). |
| Base image | `ghcr.io/trueforge-org/steamcmd` (apps/steamcmd): SteamCMD i386 package from multiverse, seeds `/config/Steam/steamcmd`, HOME=/config. |
| arm64 | No. SteamCMD is x86 only; the draft marks arm64 `no`. |

Sources: the URLs above. Anything not listed here is UNVERIFIED.

## 2. Target layout

- `apps/left4dead/Dockerfile`
- `apps/left4dead/docker-bake.hcl`
- `apps/left4dead/settings.yaml`
- `apps/left4dead/container-test.yaml`
- `apps/left4dead/start.sh`

No `defaults/`, `etc/`, or `health/` (not needed; the server writes its own config into /config). Never `root/`. No `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` (UNVERIFIED: the published tag and digest were not checked against the registry; resolve with `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:<tag>` before writing the line). The local build of apps/steamcmd is tagged `steamcmd:20180105-5build1` (its bake VERSION), so the local FROM for a bake-only test can use that tag.

Fit: the steamcmd image already provides the 32-bit SteamCMD and the `USER apps` runtime, so the game app needs no apt installs. The steamcmd image's Dockerfile uses `ubuntu:26.4` while the brief's base uses `26.04`; the digest is the same (see section 10).

Closest siblings: `apps/steamcmd` (the base). No existing app uses steamcmd as a FROM base today (checked with grep over apps/*/Dockerfile).

## 4. Dockerfile

1. Single stage, `FROM` as in section 3, then:
   ```dockerfile
   ARG VERSION
   USER root
   ENV HOME=/config
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 27015/tcp
   EXPOSE 27015/udp
   VOLUME /config
   ```
2. No apt. The 32-bit libraries the upstream Dockerfile installs (lib32gcc-s1, lib32stdc++6, lib32z1) are expected to come from the steamcmd image's i386 install; this is UNVERIFIED and is a build-time check (section 11).
3. Do not write to `/app` at runtime. Important: `COPY --chmod=0755 . /` copies this app's `start.sh` to `/start.sh`, which OVERWRITES the steamcmd base's `/start.sh` (the SteamCMD helper). Therefore the app's start.sh must be self-contained: it seeds and runs SteamCMD itself (logic copied from apps/steamcmd/start.sh, reduced to the anonymous login and the app_update for 222840) instead of calling `/start.sh`. Do not ship a second file under `/start.sh`. The final copy uses `COPY --chmod=0755 . /`, which is required.
4. License file: UNVERIFIED (see section 1). If the wrapper license is confirmed, copy it to `/usr/share/licenses/left4dead/`.
5. Final `USER apps`.

## 5. docker-bake.hcl

- `APP` = `left4dead`.
- `VERSION`: needs a renovate-trackable value. Open question (section 10). Do not invent a version. Use `// renovate: ...` once the datasource is confirmed.
- `LICENSE`: UNVERIFIED (see section 1). Do not set a value until confirmed.
- `SOURCE` = `https://store.steampowered.com/app/500/Left_4_Dead/` (upstream game page; alternatively the ich777 wrapper repo once its license is confirmed).
- Targets: `docker-metadata-action`, `image` (args VERSION, labels source and licenses), `image-local` (output docker, tag `${APP}:${VERSION}`), `image-all` (platforms `linux/amd64` only, because arm64 is no), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print` from `apps/left4dead`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/500/Left_4_Dead/"
ports:
  - port: 27015
    protocol: tcp
    required: false
  - port: 27015
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: STEAM_APP_IDS
    default: "222840"
    required: true
  - name: STEAM_INSTALL_DIR
    default: "/config/serverfiles"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
Rules: only env names the start script reads. `GAME_PORT`, `GAME_PARAMS` and `GAME_NAME` are upstream names; do not list them unless the start script reads them (the plan's start script will read `GAME_PARAMS` for the launch line, so add it with default `+maxplayers 4 +map l4d_farm04_barn`, required false, if adopted). `STEAM_USERNAME` with `anonymous` is the default. Ports: UDP 27015 is the game port; TCP 27015 is listed as the README example only, so keep it `required: false` (UNVERIFIED whether the server listens on TCP).

## 7. start.sh

Design (the file is `start.sh`, copied to the image root `/start.sh` by `COPY . /`, replacing the base's helper; see section 4):

1. `set -euo pipefail`, export `HOME=/config`, `XDG_DATA_HOME=/config`. Caches and SteamCMD temp scripts go to `/tmp` (the base script puts `steamcmd/tmp` under /config; this app must not, per the Dockerfile rules).
2. Seed and install, idempotent and self-contained (see section 4, item 3): seed `/config/Steam/steamcmd` from the image's SteamCMD when missing, then run `steamcmd.sh +force_install_dir /config/serverfiles +login anonymous +app_update 222840 [validate] +quit`. Do not call the base `/start.sh`, because this app's `start.sh` replaces it and `/start.sh` ends with `exec`. Confirm the seed paths in the build.
3. Validate on the first start only, or when `STEAM_APP_VALIDATE=true`.
4. Launch the server with `exec` so signals reach the process: `exec /config/serverfiles/<launch binary> -game left4dead ${GAME_PARAMS}` (UNVERIFIED: the launch binary path and flags; `srcds_run` or `srcds_linux` under `/config/serverfiles` must be confirmed from the installed tree).
5. Never write to `/app`. All game files go to `/config`.
6. Empty `/config` must work: create `/config/serverfiles` on demand only.
7. Bind: Source servers take `-ip 0.0.0.0` (UNVERIFIED flag name; confirm) so the server listens on all interfaces.

## 8. container-test.yaml

- Header: the forgetool `$schema` line used by `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh` (this app's script, which replaces the base one) and the SteamCMD binary path the base image ships (`/usr/local/share/steamcmd/steamcmd.sh`, from apps/steamcmd).
- Probes: the game port is UDP only. The `tcp` probe rules in `container-test.instructions.md` say every port in settings.yaml SHOULD have a probe. For UDP 27015 no reliable probe exists in the test schema (UNVERIFIED whether forgetool supports UDP). Use a process check and the `filePaths` check, and say so in a comment.
- No env vars are set by the test. The install path (`STEAM_APP_IDS`) needs Steam network access, so the test cannot pass without internet. Narrow the test to `filePaths` for the start script and steamcmd helpers. Add the DB-dependency style comment only if a DB applies (it does not).
- `timeoutSeconds`: copy from `apps/steamcmd/container-test.yaml` or the nearest game sibling (UNVERIFIED value; read it at implementation time). A first install takes many minutes, so the run test must not wait for it.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root and remaps UID/GID (`usermod`, `groupmod`, `chown -R ${UID}:${GID} ${DATA_DIR}`). Drop all of that. The container runs as `apps` (`USER apps`), and the steamcmd image already does the install as `apps`.
- Upstream data paths `/serverdata/steamcmd` and `/serverdata/serverfiles` map to `/config/steamcmd` (steamcmd image default, `HOME=/config`) and `/config/serverfiles` (STEAM_INSTALL_DIR).
- Caches (`/tmp`) are read-only-rootfs compatible when the run uses `--read-only --tmpfs /tmp`.
- `privileged`: no. Security expectations from the draft: non-root possible (chart runAsUser 0 in TrueCharts; ContainerForge runs as `apps`), read-only rootfs possible (the install writes only under /config and /tmp).
- `DATA_PERM`, `UMASK`, `USERNAME`, `PASSWRD`: upstream names. Do not list them unless the start script reads them.

## 10. Risks, caveats and open questions

- Blocker-level question: `VERSION` and renovate for a rolling `l4d` branch. The image has no upstream version. Choose one before the bake can be written (proposal: a manually bumped date-based value, with the steamcmd base as the rebuild trigger). Do not guess.
- LICENSE and SPDX for the ich777 wrapper are unverified (raw LICENSE returned 404). Set `LICENSE` only after confirmation.
- The server launch command (binary path, `-game`, `-ip`, `-port`) is UNVERIFIED: the upstream `start-server.sh` was not retrieved.
- The upstream `GAME_PARAMS` default includes a map; a fresh install should start with the map from the draft unless the user overrides it.
- First start downloads roughly the full dedicated server over SteamCMD; the test is unlikely to see a ready signal within a short window.
- The draft's security expectations are medium confidence; `readOnlyRootFilesystem` must be verified by the run step.
- Base-image inconsistency: apps/steamcmd uses `ubuntu:26.4` in its FROM; the brief's base is `26.04`. Same digest, so no change is needed here; note only.
- Dependencies: none. apps/steamcmd is a base, not a dependency.

## 11. Build and test steps

From `apps/left4dead` (after the files exist):
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty config: `docker run --rm -d --name left4dead-probe --read-only --tmpfs /tmp -v left4dead-probe-config:/config left4dead:<version>`, then `docker logs -f left4dead-probe`. Expected readiness signal: SteamCMD reports the app 222840 install or update succeeding, then the server launch line. Failure signals: `Error: Failed to initialize Steam app(s)` from the steamcmd helper, or an exit.
4. `docker rm -f left4dead-probe; docker volume rm left4dead-probe-config`.
5. `forgetool containers test --image left4dead:<version> --config ./apps/left4dead/container-test.yaml` (or the manual checks from the protocol if forgetool is unavailable).
6. Full steps 1 to 4 must be run by a runner with Steam network access. Record the result in the PR; no step has been run for this plan.

## 12. PR checklist

- Branch `feat/add-left4dead`, commit `feat(left4dead): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not tested: no build, no run, no forgetool test was executed for this plan.
- Confirm the UNVERIFIED items (VERSION, LICENSE, launch command, UDP probe support) are resolved before marking any box.
