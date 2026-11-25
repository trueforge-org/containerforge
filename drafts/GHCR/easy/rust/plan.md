# rust — implementation plan
> Source: ./draft.md · Target: apps/rust/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable / Steam app id | UNVERIFIED: app id 258550 from draft; Steam appdetails returned `"success":false` | https://store.steampowered.com/api/appdetails?appids=258550 |
| Renovate | UNVERIFIED: no versioned upstream artifact (SteamCMD pulls the server at runtime) | facts/065.md |
| License | UNVERIFIED: proprietary game server; SteamCMD is AGPL-3.0 per apps/steamcmd | apps/steamcmd/docker-bake.hcl |
| Upstream wrapper Dockerfile | `FROM ich777/debian-baseimage:bullseye_amd64`, installs lib32gcc-s1, lib32stdc++6, lib32z1, no USER, ENTRYPOINT `/opt/scripts/start.sh` | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Env vars (wrapper) | DATA_DIR=/serverdata, STEAMCMD_DIR=/serverdata/steamcmd, SERVER_DIR=/serverdata/serverfiles, GAME_ID, GAME_PARAMS, GAME_PORT=27015, VALIDATE, UMASK, USERNAME, PASSWRD | same |
| Game selection | GAME_ID env var (Rust app id value UNVERIFIED) | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md |
| Ports | UNVERIFIED: 28015/udp game, 28016/tcp rcon, 28082/tcp companion (draft inferences) | draft.md |
| arm64 | no: SteamCMD is x86 only (UNVERIFIED on the Valve page, which returned 403) | draft.md |
| Upstream Dockerfile reviewed | yes (wrapper, not Rust-specific) | see above |

Blocker: the Steam app id must be confirmed before a build. Do not start the build until it is.

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `defaults/`: not needed.
- `root/`: never used. `DOWNSTREAM_CHANGES.md`: not needed.

## 3. Base image

- `FROM ghcr.io/trueforge-org/steamcmd:<steamcmd VERSION>@sha256:<digest, to be pinned at build time>`
- Fits: apps/steamcmd provides SteamCMD (x86 32-bit bootstrap) and lib32 libs, so the game server is pulled at start, not built. The steamcmd digest is UNVERIFIED here; copy it from the registry when building.
- Closest sibling: `apps/steamcmd` (the base), plus any sibling steamcmd game server if one exists.

## 4. Dockerfile

1. `ARG VERSION` matching the steamcmd base tag.
2. No apt install (the base has the libs). No `USER root` needed.
3. `COPY --chmod=0755 start.sh /start.sh` and `COPY --chmod=0755 . /`.
4. `ENV` for the game defaults: `STEAM_APP_IDS=258550` (UNVERIFIED), `STEAM_INSTALL_DIR=/config/steamapps`.
5. `VOLUME /config`, then `USER apps`.

## 5. docker-bake.hcl

- `APP = "rust"`, `VERSION` set to the steamcmd base tag, with a renovate annotation for that tag's datasource (copy from apps/steamcmd).
- `LICENSE` and `SOURCE`: SOURCE is `https://rust.facepunch.com/`; LICENSE is UNVERIFIED for the server (use the steamcmd base license only if documented).
- Four standard targets and `group "default"`. `image-all` lists `linux/amd64` only (arm64 not supported).
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://rust.facepunch.com/"`.
- `ports`: 28015/udp (required), 28016/tcp (rcon, UNVERIFIED), 28082/tcp (companion, UNVERIFIED).
- `env`: `TZ`, `STEAM_APP_IDS` (default 258550, UNVERIFIED), `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_USERNAME` (default `anonymous`).
- `volumes`: `/config` (required).
- `dependencies`: none.

## 7. start.sh

- Reuse the sibling steamcmd logic: `exec` a steamcmd run that installs app 258550 into `/config/steamapps` when missing, then starts the server with `exec`.
- Idempotent: skip the download when the server files exist.
- Caches and temp in `/tmp` (SteamCMD `HOME=/config`, its tmp under `/config/steamcmd/tmp` as the base does; move to `/tmp` where possible).
- Server binds `0.0.0.0`; config (server.cfg, rcon password) is set by hand after first start, per the draft.

## 8. container-test.yaml

- Schema header as for siblings.
- `filePaths`: `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`.
- `tcp` probes on 28016 and 28082 (the game port 28015 is UDP and forgetool `tcp` cannot probe it; state that reason in the file, UNVERIFIED whether the schema has a UDP probe). The server only listens after the SteamCMD download, so these probes may not pass in CI without game content (UNVERIFIED); do not weaken them, resolve in the run step. `timeoutSeconds` from a sibling.
- A full first-start download cannot run in CI, so the test checks the file paths and the start-script path up to the download step. Narrowing is noted in the file.

## 9. Rootless and read-only-rootfs adaptations

- Chart runs as root (`runAsUser 0`) and `readOnlyRootFilesystem: false`. Not copied. Target: `apps` user, read-only rootfs.
- Chart PVCs `/serverdata/serverfiles` and `/serverdata/steamcmd` map to `/config/steamapps` (server files, `STEAM_INSTALL_DIR`) and `/config/steamcmd` (SteamCMD state, as in `apps/steamcmd`).

## 10. Risks, caveats and open questions

- Steam app id 258550 unconfirmed (appdetails success false).
- Ports are inferred, not confirmed.
- Large first-start download; needs internet.
- No arm64: amd64 only.
- Blocker: no confirmed app id, so the build cannot be validated yet.

## 11. Build and test steps

```sh
cd apps/rust
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name rust-probe --read-only --tmpfs /tmp \
  -v rust-probe-config:/config rust:<version>
docker logs -f rust-probe
forgetool containers test --image rust:<version> --config ./apps/rust/container-test.yaml
docker rm -f rust-probe; docker volume rm rust-probe-config
```

Expected readiness signal: SteamCMD logs a successful app update (exact text to confirm from a run). A full server start is not expected in CI.

## 12. PR checklist

- Branch `feat/add-rust`, commit `feat(rust): add new container`.
- Notes section includes `🤖 This PR is AI generated.`
- Fill in the PR template; check only the boxes that apply.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 (not supported), the Steam app id (UNVERIFIED), and the full server start.
