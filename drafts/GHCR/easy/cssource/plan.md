# cssource — implementation plan
> Source: ./draft.md · Target: apps/cssource/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release version: Steam app id 232330 (Counter-Strike: Source dedicated server) installed by SteamCMD at first start. Chart pins `ghcr.io/ich777/steamcmd:latest@sha256:5763fe62a7f9a5f81a46729aa1182f8a18e97877ac962772abbf4c49cfc18ec8` (`charts/stable/cssource/values.yaml`). Draft's `latest` is rolling. |
| Renovate | Base: `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). Game build not pinned. |
| License | Wrapper license UNVERIFIED (not fetched). Game is proprietary Valve software. |
| Source URL | https://store.steampowered.com/app/232330 |
| Download | SteamCMD at first start into `/config/serverfiles`. No prebuilt binary fetched at build time. |
| Checksum source | None on the fetched path. SteamCMD `validate` checks depots. UNVERIFIED for the bootstrap download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`; 32-bit libs `lib32gcc-s1 lib32stdc++6 lib32z1`; `ENV USER=steam UID=99 GID=100 DATA_DIR=/serverdata GAME_PORT=27015 VALIDATE="" UMASK=000 USERNAME="" PASSWRD="" DATA_PERM=770`; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no VOLUME, EXPOSE or CMD. |
| Upstream start scripts reviewed | Same ich777 flow as cs2 (`usermod`, `su ${USER}`, SteamCMD `+login`, `+force_install_dir`, `+app_update ${GAME_ID} [validate]`). The Source server launch binary for app 232330 is UNVERIFIED: the fetched `start-server.sh` was the cs2 branch and hard-codes `game/bin/linuxsteamrt64/cs2`. The cssource branch's binary (`srcds_run` or `srcds_linux`) was not fetched. |
| Port | `main` 27015/udp (game and query), `tcprcon` 27015/tcp (rcon), per chart `charts/stable/cssource/values.yaml`. Matches draft. |
| Env vars (real) | Chart: `GAME_ID=232330`, `GAME_NAME=cstrike`, `GAME_PARAMS=-secure +maxplayers 32 +map de_dust2`, `GAME_PORT=27015`, `PASSWRD` (secret), `USERNAME=""`, `VALIDATE="false"`. Upstream env set as in cs2. |
| Data path | Upstream `/serverdata`; ours `/config/serverfiles` and `/config/steamcmd`. Chart persists `/serverdata/serverfiles` and `/serverdata/steamcmd`. |
| arm64 | No (32-bit x86 bootstrap; `bullseye_amd64` base). |
| Dependency | None. |

## 2. Target layout

- `apps/cssource/Dockerfile`
- `apps/cssource/docker-bake.hcl`
- `apps/cssource/settings.yaml`
- `apps/cssource/container-test.yaml`
- `apps/cssource/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:UNVERIFIED`. Steamcmd base provides SteamCMD, i386 arch and `/config`. Closest siblings: `apps/steamcmd` (base) and the cs2 and csgo plans in this folder.

## 4. Dockerfile

1. `FROM` steamcmd base, `ARG VERSION`, `ARG VENDOR`.
2. `USER root`; install only the libraries `ldd` shows missing for the server binary (candidates `lib32gcc-s1 lib32stdc++6 lib32z1`). Clean apt lists.
3. `mkdir -p /config/serverfiles /config/steamcmd`; `chown -R apps:apps /config`.
4. `ENV HOME=/config XDG_DATA_HOME=/config GAME_PORT=27015 GAME_ID=232330 GAME_PARAMS="" VALIDATE="false" STEAMCMD_DIR=/config/steamcmd SERVER_DIR=/config/serverfiles UMASK=002`.
5. `USER apps`, `COPY --chmod=0755 . /`.
6. `EXPOSE 27015/udp 27015/tcp`.
7. `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` = `cssource`.
- `VERSION` with the deb renovate annotation, default `20180105-5build1` (matches FROM).
- `LICENSE`: UNVERIFIED (see section 1).
- `SOURCE` = `https://store.steampowered.com/app/232330`.
- Standard 4 targets plus default group `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Source_Dedicated_Server"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27015
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`upstream_env_url` is a Valve wiki URL NOT fetched in this batch (UNVERIFIED): confirm before use. Confirm the schema shape with forgetool first.

## 7. start.sh

1. `set -euo pipefail`; `export HOME=/config`; create `/config/serverfiles`, `/config/steamcmd`.
2. SteamCMD via `/usr/local/share/steamcmd/steamcmd.sh`: `+force_install_dir /config/serverfiles +login anonymous +app_update 232330 [validate] +quit`. Support `STEAM_USERNAME`/`STEAM_PASSWORD` as `apps/steamcmd` does. Read the rest of `apps/steamcmd/start.sh` first (UNVERIFIED past line 80).
3. Copy the Steam sdk64 client library into `/config/.steam/sdk64/`.
4. `export LD_LIBRARY_PATH=/config/serverfiles/bin:${LD_LIBRARY_PATH:-}` (exact dir UNVERIFIED for cssource).
5. Final: `exec` the srcds launcher from `/config/serverfiles` with `-port ${GAME_PORT}` and `${GAME_PARAMS}` (exact binary UNVERIFIED).
6. No writes to `/app`. Idempotent. Bind 0.0.0.0.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
```

Probes: tcp on 27015 only if the server listens in the test window (UNVERIFIED; first start downloads the server, so not reliable in CI). Test runs without env vars.

## 9. Rootless and read-only-rootfs adaptations

- Drop upstream `usermod`, `su`, `chown ${UID}:${GID}`: runs as `apps`.
- Writes move to `/config`; `HOME`/`XDG_DATA_HOME` to `/config`. Test with `--read-only --tmpfs /tmp`.
- Chart securityContext (runAsUser 0, readOnlyRootFilesystem false) is not carried over.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: arm64 not supported; rolling `latest` tag (chart pins digest); game and rcon both on 27015 (udp game, tcp rcon per chart).
- Launch binary for app 232330 is UNVERIFIED: blocker until the cssource branch's start script is read.
- Chart `GAME_PARAMS` (`-secure +maxplayers 32 +map de_dust2`) validity on the current build is UNVERIFIED.
- Chart persistence mapped to `/config`; no migration.
- Blockers: launch binary UNVERIFIED; base digest UNVERIFIED.

## 11. Build and test steps

From `apps/cssource/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create cssource-probe-config`; `docker run --rm -d --name cssource-probe --read-only --tmpfs /tmp -v cssource-probe-config:/config <image>:<VERSION>`
4. Readiness signal: SteamCMD success line for app 232330, then the srcds startup line (UNVERIFIED wording). Long timeout for first download.
5. Run the forgetool container test with `container-test.yaml`.
6. Cleanup: `docker rm -f cssource-probe; docker volume rm cssource-probe-config`.

## 12. PR checklist

- Branch `feat/add-cssource`; commit `feat(cssource): add new container`.
- PR template; `🤖 This PR is AI generated.` in Notes.
- CLA: user signs at https://cla-assistant.io/trueforge-org/containerforge (user only).
- Not tested: full server run and first download unless completed; state it honestly. Do not tick "Built container locally" unless built.
