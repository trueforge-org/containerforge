# longvinter — implementation plan
> Source: ./draft.md · Target: apps/longvinter/ · Difficulty: easy · Role: main · Verified on 2026-11-25

Status: BLOCKED on the dedicated-server Steam app ID (section 10). Do not write the bake or settings until it is confirmed.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No upstream release. The TrueCharts image is `ghcr.io/ich777/steamcmd:longvinter`, a rolling branch tag (https://github.com/ich777/docker-steamcmd-server/tree/longvinter). |
| Renovate | UNVERIFIED: no upstream version to track. |
| License | UNVERIFIED: no LICENSE retrieved for ich777/docker-steamcmd-server (raw LICENSE returned 404; repo page names none). Game is Steam-distributed (proprietary). |
| Steam app IDs | Store app 1635450 (https://store.steampowered.com/app/1635450/Longvinter/, "Dedicated Server tools" listed). The dedicated-server app ID is UNVERIFIED: SteamDB returned 403 and the README does not show `GAME_ID`. |
| Game name and params | UNVERIFIED: branch README shows GAME_PARAMS empty and does not show GAME_ID or GAME_NAME (https://github.com/ich777/docker-steamcmd-server/tree/longvinter). |
| Ports | 27016/udp (README run example, https://github.com/ich777/docker-steamcmd-server/tree/longvinter). Draft's 7777/udp and 27015/udp are UNVERIFIED and dropped. |
| Env vars (README table) | STEAMCMD_DIR=/serverdata/steamcmd, SERVER_DIR=/serverdata/serverfiles, GAME_PORT=27016, UID=99, GID=100. The README table heading still reads "Example Env params for CS:Source" (copy-paste in upstream). |
| First-run content | README gives an initial server name "Longvinter Docker" and password "Docker". These are upstream example values. Do not adopt them as defaults without a decision. |
| Upstream Dockerfile | Same as left4dead: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (FROM `ich777/debian-baseimage:bullseye_amd64`, 32-bit libs, ENTRYPOINT /opt/scripts/start.sh, runs as root and remaps UID/GID). |
| Checksum source | None. SteamCMD `validate` is the only integrity check. |
| arm64 | No (SteamCMD is x86 only; the draft marks arm64 `no`). |

## 2. Target layout

- `apps/longvinter/Dockerfile`
- `apps/longvinter/docker-bake.hcl`
- `apps/longvinter/settings.yaml`
- `apps/longvinter/container-test.yaml`
- `apps/longvinter/start.sh`

No `defaults/` or `etc/` unless a server config template is needed (see section 7). Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` (UNVERIFIED tag and digest; resolve with `docker buildx imagetools inspect` before writing). Same reasoning as left4dead: the steamcmd image already provides SteamCMD (i386) and `USER apps`.

Closest sibling: `apps/left4dead` (once written), which shares the steamcmd pattern. No existing app uses steamcmd as a FROM base.

## 4. Dockerfile

Same shape as the left4dead plan (sections 4 of `drafts/GHCR/easy/left4dead/plan.md`):
1. Single stage on the steamcmd base, `USER apps` in the final layer, `ENV HOME=/config`.
2. No apt.
3. `COPY --chmod=0755 . /` is required. Important: it copies this app's `start.sh` to `/start.sh`, which overwrites the base's SteamCMD helper. So the app's start.sh must be self-contained (seed and run SteamCMD itself), not call `/start.sh`.
4. `EXPOSE 27016/udp`, `VOLUME /config`.
5. License file: UNVERIFIED (section 1); copy only when confirmed.

## 5. docker-bake.hcl

- `APP = "longvinter"`.
- `VERSION`: no upstream version. Open question (section 10).
- `LICENSE`: UNVERIFIED. Do not set until confirmed.
- `SOURCE = "https://store.steampowered.com/app/1635450/Longvinter/"`.
- Targets as in the sibling pattern: `docker-metadata-action`, `image`, `image-local`, `image-all` (linux/amd64 only), `group "default"`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/1635450/Longvinter/"
ports:
  - port: 27016
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: STEAM_APP_IDS
    default: ""          # UNVERIFIED: dedicated-server app ID must be confirmed here
    required: true
volumes:
  - path: /config
    required: true
```
Rules: no env names beyond what the start script reads. `STEAM_APP_IDS` default stays empty until the app ID is confirmed. Server name and password defaults are not listed unless the start script writes them (decision needed).

## 7. start.sh

1. Self-contained, as in the left4dead plan (section 7): seed `/config/Steam/steamcmd` when missing, install with `+force_install_dir /config/serverfiles +login anonymous +app_update <ID> [validate] +quit`, idempotent on restart.
2. First start with an empty `/config`: the server's config file is created or edited under `/config` by hand (upstream says so). Decide whether to seed a minimal server config from a `defaults/` template, which needs the server's config keys (UNVERIFIED) and must not overwrite an existing config.
3. Exec the server binary with `exec` so signals propagate. Launch path and flags: UNVERIFIED until the dedicated-server install tree is inspected. Bind to all interfaces if the server supports a bind flag (UNVERIFIED).
4. No writes to `/app`. Caches and temp under `/tmp`.

## 8. container-test.yaml

- Header: the forgetool `$schema` line from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh` (this app's script).
- Ports: UDP 27016 has no reliable probe in the test schema (UNVERIFIED whether forgetool supports UDP). Use a process check and the file check, with a comment.
- The test runs with no env. Install needs Steam network access, so the test should cover only `filePaths`. A full install run is a manual step (section 11).
- `timeoutSeconds`: copy from the nearest game sibling (UNVERIFIED value).

## 9. Rootless and read-only-rootfs adaptations

- Upstream remaps UID/GID as root. Drop that; the container runs as `apps`.
- Data: `/config/Steam` (SteamCMD) and `/config/serverfiles` (game). Temp and caches in `/tmp`.
- Draft security expectations (medium confidence): non-root possible, read-only rootfs possible (writes only under /config and /tmp), privileged no, no extra persistence beyond /config.

## 10. Risks, caveats and open questions

- BLOCKER: the dedicated-server Steam app ID is not confirmed. The store app ID 1635450 is the client page. Confirm the dedicated-server ID (SteamDB or the ich777 branch `GAME_ID`) before anything else.
- VERSION and LICENSE unverified (section 1).
- Launch command and config format unverified.
- Upstream README example names ("Longvinter Docker", "Docker") are example values; decide whether the app ships any default password (recommend none).
- First start downloads the full server; a ready signal may be slow.
- arm64 not supported.

## 11. Build and test steps

Blocked until section 10 is resolved. Then, from `apps/longvinter`:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run: `docker run --rm -d --name longvinter-probe --read-only --tmpfs /tmp -v longvinter-probe-config:/config longvinter:<version>`, then `docker logs -f longvinter-probe`. Expected readiness: SteamCMD reports the install succeeded, then the server launch line (UNVERIFIED wording).
4. `docker rm -f longvinter-probe; docker volume rm longvinter-probe-config`.
5. `forgetool containers test --image longvinter:<version> --config ./apps/longvinter/container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-longvinter`, commit `feat(longvinter): add new container`, PR title the same.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, tick only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: no build, run or forgetool test was executed for this plan, and the dedicated-server app ID is unconfirmed.
