# memories-of-mars — implementation plan
> Source: ./draft.md · Target: apps/memories-of-mars/ · Difficulty: easy · Role: main · Verified on 2026-11-25

Status: BLOCKED on the Steam app ID and the game's launch command (section 10). The plan below is ready once those two facts are confirmed.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no game-server version or tag was found. The draft's chart pins the image tag `ghcr.io/ich777/steamcmd:memoriesofmars`, which is a wrapper tag, not a game version. The game is downloaded by SteamCMD at start, so there is no release asset to pin. |
| Steam app ID | UNVERIFIED: not found on any fetched page. The draft cites only the store search page https://store.steampowered.com/search/?term=memories+of+mars, which is not an app page. |
| Renovate | UNVERIFIED: no pinned upstream version exists. For the base image, use the `steamcmd` app's own renovate annotation (`apps/steamcmd/docker-bake.hcl`). |
| License | UNVERIFIED for the game (proprietary Steam content). The wrapper `ich777/docker-steamcmd-server` README states no license (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md). ContainerForge `steamcmd` app is AGPL-3.0-or-later (its bake). Set `LICENSE` to the license of the software in the image; confirm before build. |
| Source URL | https://store.steampowered.com/search/?term=memories+of+mars (draft; not an app page, UNVERIFIED as the source) |
| Website | https://memoriesofmars.com (draft; not fetched) |
| Download | Not a release asset. SteamCMD installs the dedicated server from Steam into `STEAM_INSTALL_DIR` at start. |
| Checksum source | None (Steam manages content integrity). |
| Upstream wrapper reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: base `ich777/debian-baseimage:bullseye_amd64`; installs `lib32gcc-s1`, `lib32stdc++6`, `lib32z1`; user `steam` (UID 99, GID 100); ENTRYPOINT `/opt/scripts/start.sh`; no USER, EXPOSE, VOLUME or CMD. |
| Upstream wrapper start | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: runs as root, applies UID/GID/UMASK, chowns `DATA_DIR`, runs `start-server.sh` as `${USER}` via `su`. The SteamCMD install command lives in `start-server.sh`, which was not fetched (UNVERIFIED). |
| Ports | UNVERIFIED: game port not confirmed. Draft infers 7777/udp (game) and 27015/udp (query). The wrapper's `GAME_PORT` example (27015) is from a CS:Source example, not this game. |
| Data paths | `/serverdata/steamcmd` (`STEAMCMD_DIR`) and `/serverdata/serverfiles` (`SERVER_DIR`) in the wrapper README. |
| Dependencies | None. |
| arm64 | No (draft). Not checked: SteamCMD's 32-bit bootstrap is x86 only. |

## 2. Target layout

- `apps/memories-of-mars/Dockerfile`
- `apps/memories-of-mars/docker-bake.hcl`
- `apps/memories-of-mars/settings.yaml`
- `apps/memories-of-mars/container-test.yaml`
- `apps/memories-of-mars/start.sh`

No `defaults/` or `etc/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`, taken from `apps/steamcmd` (its build produces `ghcr.io/trueforge-org/steamcmd`; the digest is UNVERIFIED and must be read from the published image at build time, not invented). Reasons:

- It already provides SteamCMD (`/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`), runs as `apps`, and creates `/config`.
- Its `start.sh` supports `STEAM_APP_IDS` (numeric, comma-separated), `STEAM_INSTALL_DIR`, `STEAM_APP_VALIDATE`, and `STEAM_USERNAME`/`STEAM_PASSWORD` for login. This app's own `start.sh` replaces it at `/start.sh` (see section 7), so the install logic must be carried into the new script; the env names stay the same.

Fallback if the steamcmd image cannot be used: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` plus the apt setup from `apps/steamcmd/Dockerfile` (multiverse, `steamcmd:i386`). That duplicates the base, so prefer the steamcmd base.

Closest sibling: `apps/steamcmd` (base) and, for a game-server layout, any sibling that uses `start.sh` with `exec`.

## 4. Dockerfile

Thin layer on the steamcmd base; no compile step.

1. `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` (section 3).
2. `ARG VERSION`, `USER root` only if a package is needed. Current plan needs none.
3. `ENV HOME=/config STEAM_INSTALL_DIR=/config/memories-of-mars`. Install directory under `/config` so the server files persist (draft: /config).
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `VOLUME /config`. Do not add `EXPOSE` until ports are confirmed.

The `docker-bake.hcl` `VERSION` must still align with the Dockerfile (section 5). Use the app's own version label, since there is no upstream game version: UNVERIFIED which value to pin (open question in section 10).

## 5. docker-bake.hcl

- `APP` = `memories-of-mars`
- `VERSION`: UNVERIFIED. No upstream game version. Option: use the wrapper image tag `memoriesofmars` with a renovate comment for the steamcmd base, or a date-based pin agreed with the maintainers. Do not invent a version.
- `LICENSE`: UNVERIFIED (section 1).
- `SOURCE` = `https://store.steampowered.com/search/?term=memories+of+mars` is not an app page, so confirm the upstream project URL before setting `SOURCE` (it must match `upstream_env_url` in settings.yaml).
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` with `linux/amd64` only (arm64 not supported), `group "default"` (image-local). Copy the layout from `apps/steamcmd/docker-bake.hcl`.

Validate with `docker buildx bake --print` from `apps/memories-of-mars`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "<upstream project URL: confirm, see section 5>"
ports:
  []
env:
  - name: STEAM_APP_IDS
    default: ""
    required: true
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `ports: []` until the game ports are verified. Do not list 7777 or 27015 from the draft's inference.
- `STEAM_APP_IDS` is the Steam app ID of the dedicated server. It is UNVERIFIED and must not be guessed. `required: true` with an empty default means first start needs the ID. Check the `start.sh` rule: `required: true` env vars need a default or start.sh handling. Decide with the maintainers: keep required and make `start.sh` fail with a clear message when empty, or make it optional.
- The steamcmd base reads these names directly, so names match the base's `start.sh`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/memories-of-mars}"
export STEAM_APP_IDS="${STEAM_APP_IDS:-}"

if [ -z "${STEAM_APP_IDS}" ]; then
    echo "Error: STEAM_APP_IDS is required (Steam app ID for the Memories of Mars server)." >&2
    exit 1
fi

# Install or update the dedicated server, then launch it.
# TODO: self-contained SteamCMD install (see below), then the server launch.
# UNVERIFIED: exact launch command for the server binary, see section 10
```

- Important: `COPY --chmod=0755 . /` copies this app's `start.sh` to `/start.sh`, OVERWRITING the base's SteamCMD helper, and `/usr/local/bin/steamcmd` in the base is a wrapper that does `exec /start.sh`. Calling `/usr/local/bin/steamcmd` from this script would therefore re-run itself in a loop. The script must be self-contained: seed `/config/Steam/steamcmd` from `/usr/local/share/steamcmd/` when missing and run `/config/Steam/steamcmd/steamcmd.sh +force_install_dir ${STEAM_INSTALL_DIR} +login anonymous +app_update ${STEAM_APP_IDS} +quit` itself (logic adapted from `apps/steamcmd/start.sh`), then launch the server. Replace the placeholder line above accordingly.
- Launch command: UNVERIFIED. The server binary path under `${STEAM_INSTALL_DIR}` and its arguments are not confirmed. Do not guess it. Replace the placeholder above with `exec "${STEAM_INSTALL_DIR}/<server binary>" <args>` once confirmed, and keep `exec` so signals reach PID 1.
- Writes: `/config` only (install dir and HOME). Caches and scratch go to `/tmp` (steamcmd base uses `/config/steamcmd/tmp`; note it in the PR as a deviation to review, since the rule says caches go to `/tmp`).
- Bind: game server bind address: UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- No tcp or http probes: no ports are verified, so there is nothing to probe. Add tcp/udp probes once ports are confirmed (`settings.yaml` rule: every port needs a probe).
- The test runs with no env vars. `STEAM_APP_IDS` is empty, so the start script exits with the message in section 7 by design; that is the required-env code path, so it goes into `filePaths` and is covered by the protocol. The test as written checks file presence only; this is a narrow test that must be called out in the PR (and the readiness check run manually with a real app ID).
- Do not weaken the test to pass. If the forgetool schema requires a readiness probe, add the verified port probe, not a stub.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (SteamCMD) | `/config/steamcmd` (base's own path) |
| `/serverdata/serverfiles` (game files) | `/config/memories-of-mars` via `STEAM_INSTALL_DIR` |
| Wrapper `DATA_DIR`, `UID`/`GID`, `UMASK` | Not used: the steamcmd base runs as `apps` and sets no UID/GID. Drop these. |
| Wrapper entrypoint runs as root | Not applicable: the base already runs `USER apps`. |
| SteamCMD temp files | `/config/steamcmd/tmp` (base). Review against the `/tmp` rule (section 7). |

- Read-only rootfs: works if all writes land in `/config` or `/tmp`. Verify with `--read-only --tmpfs /tmp`.
- Draft expectations: non-root possible (yes, via the base), read-only possible (yes once writes are remapped), privileged no, extra persistence none beyond `/config`. The chart's `/serverdata` mounts become `/config`.

## 10. Risks, caveats and open questions

- BLOCKER: Steam app ID for the Memories of Mars dedicated server. Not on any fetched page. Look it up on a Steam/SteamDB source and confirm it before building. Do not guess.
- BLOCKER: launch command and binary path for the server. Not in the fetched wrapper files.
- UNVERIFIED: game ports. The draft's 7777/udp and 27015/udp are inferred. Do not list them until confirmed.
- UNVERIFIED: version to pin in `docker-bake.hcl` (section 5) and `SOURCE`/`upstream_env_url`.
- UNVERIFIED: license for the game and the image's `LICENSE` label.
- UNVERIFIED: `ghcr.io/trueforge-org/steamcmd` tag and digest; must be read from the published image, not copied from this plan.
- Caveat: the steamcmd base's start.sh writes under `/config/steamcmd/tmp`. The rule says caches go to `/tmp`; review or accept with a note in the PR.
- Caveat: first start downloads the game over Steam, so startup is slow and needs internet access (inferred).
- Caveat: amd64 only (SteamCMD). arm64 not supported.
- Caveat: the Steam store search page cited by the draft is not an app page; treat it as a placeholder until the app ID is confirmed.

## 11. Build and test steps

From `apps/memories-of-mars/` (only after the blockers in section 10 are resolved):

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name memories-of-mars-probe --read-only --tmpfs /tmp \
  -e STEAM_APP_IDS=<confirmed app id> \
  -v memories-of-mars-probe-config:/config memories-of-mars:<version>
docker logs -f memories-of-mars-probe
docker rm -f memories-of-mars-probe; docker volume rm memories-of-mars-probe-config
forgetool containers test --image memories-of-mars:<version> --config ./container-test.yaml
```

- Expected readiness signal: SteamCMD reports the app installed (`Success! App '<id>' fully installed`) and the server process starts and stays up. Exact text to confirm on first run.
- Also run with an empty `STEAM_APP_IDS` to confirm the clear error and non-zero exit.
- Empty `/config` test: use a fresh volume each round (protocol rule).

## 12. PR checklist

- Branch `feat/add-memories-of-mars`, commit `feat(memories-of-mars): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it. The `license/cla` check shows status.
- State what was not tested: the Steam app ID and launch command (if still unresolved), game ports, arm64 (not supported), and the full install (needs a real app ID and internet).
- Do not check "Built container locally" unless the image was built and run.
