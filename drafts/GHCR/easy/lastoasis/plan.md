# lastoasis — implementation plan
> Source: ./draft.md · Target: apps/lastoasis/ · Difficulty: easy (as drafted; blocked, see section 10) · Role: main · Verified on 2026-11-25

**Status: blocked.** The Steam store lists the Last Oasis dedicated server as Windows-only. Do not create `apps/lastoasis/` until a Linux depot is confirmed or the decision in section 10 is made.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Not a versioned release. The game is delivered by SteamCMD at start. Steam app IDs: client `903950` (store page, "Last Oasis"), dedicated server `920720` ("Last Oasis - Dedicated Server"). Sources: https://store.steampowered.com/api/appdetails?appids=903950 and https://store.steampowered.com/api/appdetails?appids=920720 |
| Platforms (Steam store) | Dedicated server 920720: `windows: true`, `mac: false`, `linux: false`. Client 903950: same. A Linux depot is **UNVERIFIED** (depot list is not on the store API). |
| Renovate | Not applicable: no versioned upstream artifact. Steam build IDs are not in a public release feed. |
| License | Not applicable as an open-source licence; the game is proprietary (Steam EULA). UNVERIFIED: EULA text not fetched. |
| Source URL | https://store.steampowered.com/app/903950/Last_Oasis/ (the draft's "source" is a store page, not a repository) |
| Download | SteamCMD `app_update 920720` at start (not a direct URL). |
| Checksum source | None; SteamCMD `validate` only. |
| Upstream image | `ghcr.io/ich777/steamcmd:lastoasis`, built from the `lastoasis` branch of https://github.com/ich777/docker-steamcmd-server. Dockerfile: `FROM ich777/debian-baseimage` (Debian, glibc); apt `lib32gcc-s1 lib32stdc++6`; `ENV GAME_ID`, `IDENTIFIER`, `CUSTOMER_KEY`, `PROVIDER_KEY`, `BACKENDAPIURLOVERRIDE=backend.last-oasis.com`, `SLOTS=20`, `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME`, `PASSWRD`, `USER=steam`, `DATA_PERM=770`; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no `USER` instruction (runs as root). Source: `gh api repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=lastoasis`. |
| Upstream README (lastoasis branch) | `GAME_ID` 920720 for the dedicated server; GAME_PARAMS example `-port=5555 -QueryPort=27015 -NoLiveServer -EnableCheats`; run example maps `5555/udp` and `27015/udp`; keys come from https://myrealm.lastoasis.gg. Source: https://github.com/ich777/docker-steamcmd-server/blob/lastoasis/README.md |
| Real env vars (upstream) | `GAME_ID`, `IDENTIFIER`, `SRV_PASSWORD`, `SLOTS`, `CUSTOMER_KEY`, `PROVIDER_KEY`, `GAME_PARAMS`, `BACKENDAPIURLOVERRIDE`, `VALIDATE`, `UMASK`, `UID`, `GID`, `USERNAME`, `PASSWRD`, `DATA_DIR`, `STEAMCMD_DIR`, `SERVER_DIR`. |
| Ports | `5555/udp` (game, from GAME_PARAMS `-port=5555`), `27015/udp` (query, from `-QueryPort=27015`). Both from the upstream README. |
| Write paths (upstream) | `/serverdata/steamcmd` (SteamCMD), `/serverdata/serverfiles` (game). ContainerForge remap: `/config`. |
| copy-from | Not applicable. The upstream image is glibc Debian, so the blocker is the Windows-only platform, not musl. Per the draft, `ghcr.io/ich777/steamcmd:lastoasis` is the only source. |
| arm64 | **no**. x86 SteamCMD bootstrap with lib32 libraries. |
| Dependencies | None inside ContainerForge. External: Last Oasis backend (`backend.last-oasis.com`) and vendor keys (`CUSTOMER_KEY`, `PROVIDER_KEY`). |

## 2. Target layout

If it is built later, `apps/lastoasis/` would hold `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, and `include/.dockerignore` would allow `start.sh`. No `root/`, no `DOWNSTREAM_CHANGES.md`. Use `apps/steamcmd` for the SteamCMD flow instead of copying ich777's scripts.

## 3. Base image

- `FROM ghcr.io/trueforge-org/steamcmd:<version>@<digest>` (the ContainerForge sibling, from `apps/steamcmd`). Its digest is not in the brief; copy the FROM line from `apps/steamcmd/Dockerfile` at build time. Note: that Dockerfile uses `ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb...` as its own base.
- Why: `apps/steamcmd` already installs SteamCMD as `apps` user with `/config` writes. The draft's reuse is correct.
- Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

If built: no build stage; the image is the steamcmd sibling plus `start.sh`. The `ARG VERSION` must match the steamcmd bake `VERSION` (`20180105-5build1`), per `apps/steamcmd`. Otherwise the steps are:

1. `FROM` the steamcmd sibling.
2. `COPY --chmod=0755 start.sh /start.sh` (ContainerForge-owned script, not ich777's).
3. `USER apps` and `COPY --chmod=0755 . /`.

Do not copy ich777's `/opt/scripts`; they run as root and assume the Debian base.

## 5. docker-bake.hcl

If built: `APP = "lastoasis"`, `VERSION` taken from the steamcmd sibling, `LICENSE` = proprietary (not an SPDX identifier; use a `LicenseRef-Steam-EULA` string after the licence owner confirms the field format), `SOURCE` = `https://store.steampowered.com/app/903950/Last_Oasis/`. Standard four targets and `group "default"`. Validate with `docker buildx bake --print`. Renovate: none (no versioned upstream).

## 6. settings.yaml

If built:

- Schema header, `schema_version: 1`, `upstream_env_url` = `https://store.steampowered.com/app/903950/Last_Oasis/`.
- `ports`: `5555/udp` required, `27015/udp` required.
- `env`: `GAME_ID` default `"920720"`, `IDENTIFIER`, `SRV_PASSWORD` (empty default), `SLOTS` default `"20"`, `CUSTOMER_KEY` and `PROVIDER_KEY` `required: true` (no default; vendor secrets), `GAME_PARAMS` default `"-port=5555 -QueryPort=27015 -NoLiveServer -EnableCheats"`, `STEAM_APP_IDS` mapping per `apps/steamcmd`, `TZ`.
- `volumes`: `/config`, required.
- `dependencies`: none.

## 7. start.sh

If built, the rules apply: idempotent, `/config` only, no writes to `/app`, caches in `/tmp`, `exec` the server, read keys from the environment and never write them to disk, and do not print them.

Constraints the script must meet:

- `CUSTOMER_KEY` and `PROVIDER_KEY` are secrets: keep them out of files and the process list (pass them via env to the server only if the server reads env; otherwise write a config file in `/tmp`, not `/config`).
- Call SteamCMD through `apps/steamcmd`'s `start.sh` for the install step rather than duplicating it.
- Windows platform handling (section 10) must be decided first.

## 8. container-test.yaml

If built: schema header from `apps/steamcmd`; `filePaths` for `/start.sh`; UDP probes on `5555` and `27015` (not tcp: Steam query is UDP). A full functional test is not possible without the game download and vendor keys, so the narrowed approach from the build-test protocol applies only if the database criteria hold; they do not (no database dependency), so this app needs real probes or should not be built.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | ContainerForge |
| --- | --- |
| Runs as root (no USER) | `USER apps` |
| `/serverdata/steamcmd`, `/serverdata/serverfiles` | `/config/steamcmd`, `/config/serverfiles` (or `STEAM_INSTALL_DIR`) |
| `UID=99 GID=100` | the `apps` user from the base |
| `ulimit -n 2048` | not settable from the image; check the runtime |
| SteamCMD cache | `/tmp` (per the Dockerfile rule), HOME is `/config` in `apps/steamcmd` |

- `readOnlyRootFilesystem`: the chart sets false; with `/config` and `/tmp` writable it can be true, but the download needs `/config` persistence.
- `privileged`: no.

## 10. Risks, caveats and open questions

- **Blocker 1 (platform):** Steam lists the dedicated server (920720) and client (903950) as Windows-only. A Windows binary does not run on glibc Ubuntu without Wine or Proton. The ich777 Linux container downloads through SteamCMD, but it is not confirmed that a Linux depot exists. Confirm with a SteamCMD `app_info_print 920720` run (depot list) before any build. If no Linux depot exists, this app is not feasible as an easy container.
- **Blocker 2 (secrets):** the game requires `CUSTOMER_KEY` and `PROVIDER_KEY` from a vendor account. The image cannot ship them; the user must supply them. The container's readiness cannot be tested in CI without them.
- **Blocker 3 (upstream root):** the ich777 image runs as root; the ContainerForge plan requires `USER apps`, so the scripts must be ours.
- **Caveat:** first start downloads the server via SteamCMD into `/config`: large and slow.
- **Caveat:** UDP ports `5555` and `27015` must be forwarded to be reachable.
- **arm64:** not supported (x86 SteamCMD).
- **Decision needed:** (a) confirm a Linux depot and keep the plan; (b) drop the app from the easy queue; (c) move it to a Wine/Proton-based plan (not easy, not in scope here).
- **Draft mismatch:** the draft says "Dedicated server pulled from Steam", but the store data says Windows-only. Treat the draft's amd64 `yes` as UNVERIFIED.

## 11. Build and test steps

Not applicable until blockers 1 and 2 are resolved. When unblocked, follow `.github/instructions/build-test-protocol.instructions.md` from `apps/lastoasis/`: `docker buildx bake --print`, `image-local` build (amd64), a run with `--read-only --tmpfs /tmp` and a fresh `/config` volume (expect SteamCMD progress lines, then a server readiness line, exact text UNVERIFIED), then `forgetool containers test`. Real-run validation needs the vendor keys, which the user must supply.

## 12. PR checklist

- Not applicable now: no PR until the decision in section 10. If a PR is later opened: branch `feat/add-lastoasis`, commit and title `feat(lastoasis): add new container`.
- `🤖 This PR is AI generated.` in the Notes section, and the PR template.
- Tell the user about the CLA at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign it.
- State in the PR that the game was not run and that the keys were not tested.
