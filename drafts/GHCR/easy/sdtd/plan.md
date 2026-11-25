# sdtd — implementation plan
> Source: ./draft.md · Target: apps/sdtd/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable / Steam app id | UNVERIFIED: draft uses app id 294420; Steam appdetails returned `"success":false` | https://store.steampowered.com/api/appdetails?appids=294420 |
| Renovate | UNVERIFIED: no versioned upstream artifact (SteamCMD pulls the server at runtime) | facts/065.md |
| License | UNVERIFIED: proprietary game server; SteamCMD is AGPL-3.0 per apps/steamcmd | apps/steamcmd/docker-bake.hcl |
| Upstream wrapper Dockerfile | `FROM ich777/debian-baseimage:bullseye_amd64`, installs lib32gcc-s1, lib32stdc++6, lib32z1, no USER, ENTRYPOINT `/opt/scripts/start.sh` | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Env vars (wrapper) | DATA_DIR=/serverdata, STEAMCMD_DIR=/serverdata/steamcmd, SERVER_DIR=/serverdata/serverfiles, GAME_ID, GAME_PARAMS, GAME_PORT=27015, VALIDATE, UMASK, USERNAME, PASSWRD | same |
| Game selection | GAME_ID env var (7DTD value UNVERIFIED) | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md |
| Ports | UNVERIFIED: 26900/udp game, 26901/udp query, 8081/tcp telnet, 8080/http panel (draft inferences) | draft.md |
| arm64 | no: SteamCMD is x86 only (UNVERIFIED on the Valve page, which returned 403) | draft.md |
| Upstream Dockerfile reviewed | yes (wrapper, no 7DTD-specific branch) | see above |

Blocker: the Steam app id must be confirmed before a build. Do not start the build until it is.

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `defaults/`: not needed. `root/`: never used. `DOWNSTREAM_CHANGES.md`: not needed.

## 3. Base image

- `FROM ghcr.io/trueforge-org/steamcmd:<steamcmd VERSION>@sha256:<digest, to be pinned at build time>`
- Fits: apps/steamcmd provides SteamCMD and the lib32 libs; the server is pulled at start.
- Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

1. `ARG VERSION` matching the steamcmd base tag.
2. No apt install. No `USER root` needed.
3. `COPY --chmod=0755 start.sh /start.sh` and `COPY --chmod=0755 . /`.
4. `ENV STEAM_APP_IDS=294420` (UNVERIFIED), `STEAM_INSTALL_DIR=/config/steamapps`.
5. `VOLUME /config`, then `USER apps`.

## 5. docker-bake.hcl

- `APP = "sdtd"`, `VERSION` set to the steamcmd base tag with its renovate annotation.
- `LICENSE` UNVERIFIED for the server; `SOURCE = "https://store.steampowered.com/app/294420/"`.
- Four standard targets and `group "default"`. `image-all` lists `linux/amd64` only.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url` = SOURCE.
- `ports`: 26900/udp (required), 26901/udp (UNVERIFIED), 8081/tcp (telnet, UNVERIFIED), 8080/tcp (web panel, UNVERIFIED).
- `env`: `TZ`, `STEAM_APP_IDS` (default 294420, UNVERIFIED), `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_USERNAME` (default `anonymous`).
- `volumes`: `/config` (required). `dependencies`: none.

## 7. start.sh

- Reuse the sibling steamcmd logic to install app 294420 into `/config/steamapps` when missing, then `exec` the server.
- Idempotent: skip the download when files exist.
- Temp and caches in `/tmp`; server binds `0.0.0.0`.
- Telnet and web admin passwords are set in the server config, which must be written only when missing.

## 8. container-test.yaml

- Schema header as for siblings.
- `filePaths`: `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`.
- `tcp` probe on the game port, with `timeoutSeconds` from a sibling.
- The full first-start download cannot run in CI, so the test covers the file paths and the start-script path up to the download step. Narrowing is noted in the file.

## 9. Rootless and read-only-rootfs adaptations

- Chart runs as root and `readOnlyRootFilesystem: false`. Not copied. Target: `apps` user, read-only rootfs.
- Chart PVCs `/serverdata/serverfiles` and `/serverdata/steamcmd` map to `/config/serverfiles` and `/config/steamcmd`.

## 10. Risks, caveats and open questions

- Steam app id 294420 unconfirmed (appdetails success false).
- Ports are inferred, not confirmed.
- Large first-start download; needs internet.
- No arm64.
- Blocker: no confirmed app id, so the build cannot be validated yet.

## 11. Build and test steps

```sh
cd apps/sdtd
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name sdtd-probe --read-only --tmpfs /tmp \
  -v sdtd-probe-config:/config sdtd:<version>
docker logs -f sdtd-probe
forgetool containers test --image sdtd:<version> --config ./apps/sdtd/container-test.yaml
docker rm -f sdtd-probe; docker volume rm sdtd-probe-config
```

Expected readiness signal: SteamCMD logs a successful app update (exact text to confirm from a run). A full server start is not expected in CI.

## 12. PR checklist

- Branch `feat/add-sdtd`, commit `feat(sdtd): add new container`.
- Notes section includes `🤖 This PR is AI generated.`
- Fill in the PR template; check only the boxes that apply.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 (not supported), the Steam app id (UNVERIFIED), and the full server start.
