# fsm — implementation plan
> Source: ./draft.md · Target: apps/fsm/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 0.10.1 (GitHub "Latest", published 09 Mar, commit 2d007c8; same as draft). Notes: dynamic link fix for glibc 2.32, Docker base moved from Alpine to Ubuntu. |
| Renovate | `datasource=github-releases depName=OpenFactorioServerManager/factorio-server-manager versioning=semver` |
| License | MIT (README) -> `MIT` |
| Source URL | https://github.com/OpenFactorioServerManager/factorio-server-manager |
| Download | amd64: `https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/${VERSION}/factorio-server-manager-linux-${VERSION}.zip` (from upstream Dockerfile and draft). The release has 4 assets whose names did not load (UNVERIFIED which exist). arm64: no asset known, therefore amd64 only. |
| Checksum | UNVERIFIED: none seen. Record a sha256 ARG at implementation time. |
| Upstream Dockerfile reviewed | `docker/Dockerfile`: `ubuntu` (glibc needed for Factorio); `ENV FACTORIO_VERSION=stable MANAGER_VERSION=0.10.1 RCON_PASS=`; ports `80/tcp`, `34197/udp`; volumes `/opt/fsm-data /opt/factorio/saves /opt/factorio/mods /opt/factorio/config`; apt `curl tar xz unzip jq`; unzips to `/opt/fsm`; entrypoint `/opt/entrypoint.sh`; runs as root |
| Upstream entrypoint (`docker/entrypoint.sh`) | If `/opt/fsm-data/conf.json` is missing, `jq` copies `/opt/fsm/conf.json` and sets `rcon_pass` (from `RCON_PASS`), `sqlite_database_file=/opt/fsm-data/sqlite.db`, `log_file=/opt/fsm-data/factorio-server-manager.log`; **always** downloads the headless server from `https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64` with plain `curl` (no account or token) and extracts it to `/opt/factorio`; then `cd /opt/fsm && ./factorio-server-manager --conf /opt/fsm-data/conf.json --dir /opt/factorio --port 80`. Flags verified: `--conf`, `--dir`, `--port`. |
| Ports | web UI: `--port` (draft 80, container will use 8080); Factorio game `34197/udp` (verified in Dockerfile); RCON `27015/tcp` (draft inference, UNVERIFIED; check `conf.json.example` `rcon_port`) |
| Bind address | UNVERIFIED: the entrypoint passes only `--port`. Check `conf.json.example` for an `address` key and the flags in `./factorio-server-manager --help`. |

Corrections to the draft: the base is not `python-node` (FSM is a Go binary with a bundled UI, no Node runtime); the headless server download needs **no** Factorio account, contradicting the draft caveat, so the "cannot start without a token" claim is only true for online multiplayer matchmaking (`factorio.com` credentials in server settings), not for the download.

## 2. Target layout

```
apps/fsm/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (conf.json comes from the shipped `/app/fsm/conf.json`). No `root/`. No `DOWNSTREAM_CHANGES.md`. Note `apps/factorioservermanager` may be the sibling twin (draft says same image); check `drafts/Docker Hub/hard/factorioservermanager/plan.md` for consistency.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: glibc binary (upstream moved to Ubuntu for this); no Node or Python needed. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; fail unless amd64: `[ "$TARGETARCH" = amd64 ] || exit 1`.
2. `USER root`; `apt-get install -y --no-install-recommends unzip xz-utils jq` (the upstream "xz" package name is wrong on Ubuntu; `curl` and `tar` are in the base: bazarr uses curl without installing it, unzip is installed by bazarr so not in the base).
3. Download zip, verify sha256, `unzip -q -d /app`, rename the extracted dir to `/app/fsm`, `chmod 755`.
4. Licenses: `/usr/share/licenses/fsm/LICENSE.md` (from the repo tag, since the zip may not contain it).
5. `ENV HOME=/config TMPDIR=/tmp`.
6. Cleanup `/tmp/*`, apt lists.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080 34197/udp`, `VOLUME /config`, `WORKDIR /app/fsm`.

## 5. docker-bake.hcl

- `APP` `fsm`; `VERSION` `0.10.1` with `// renovate: datasource=github-releases depName=OpenFactorioServerManager/factorio-server-manager versioning=semver`; `LICENSE` `MIT`; `SOURCE` `https://github.com/OpenFactorioServerManager/factorio-server-manager`.
- Targets as standard; `image-all` platforms **amd64 only** (no arm64). `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/OpenFactorioServerManager/factorio-server-manager"`.
- ports: `8080/tcp` (web), `34197/udp` (game, required false), `27015/tcp` (RCON, required false; UNVERIFIED).
- env: `TZ` (`Etc/UTC`), `FACTORIO_VERSION` (`stable`), `RCON_PASS` (`""`, start.sh generates one when empty and stores it in `conf.json`), `PORT` (`8080`).
- volumes: `/config` (required true: `fsm-data`, `factorio/saves`, `factorio/mods`, `factorio/config`, the Factorio install).
- dependencies: none.

## 7. start.sh

1. `mkdir -p /config/fsm-data /config/factorio`; Factorio install dir `/config/factorio` (writable and persistent; ~1 GB).
2. If `/config/fsm-data/conf.json` is missing: `jq` from `/app/fsm/conf.json`, set `sqlite_database_file`, `log_file` to `/config/fsm-data/...`; set `rcon_pass` using `jq --arg` (not string interpolation, as upstream does, which breaks on quotes and echoes the secret in logs; do not echo it). Apply `RCON_PASS` on every start via `jq --arg` (idempotent); when it is empty and `conf.json` has no `rcon_pass`, generate one (for example `head -c 18 /dev/urandom | base64`) and store it only in `conf.json`.
3. If `/config/factorio/bin/x64/factorio` is missing: `curl -fL https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64 -o /tmp/factorio.tar.xz`, extract with `--strip-components=1` into `/config/factorio`, delete the tar (upstream re-downloads every start; we only when missing). Download at runtime (not baked): redistribution terms UNVERIFIED.
4. `cd /app/fsm` (UNVERIFIED if FSM needs its cwd to be the tree and writable; if it writes there, copy `/app/fsm` to `/tmp/fsm` first).
5. `exec ./factorio-server-manager --conf /config/fsm-data/conf.json --dir /config/factorio --port "${PORT:-8080}"` plus a bind flag if one exists (must listen on 0.0.0.0).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180   # first start downloads ~100+ MB of Factorio; check the sibling and raise if flaky
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
```
No probe for 34197/udp or 27015: the schema offers tcp/http only (UNVERIFIED); the game server is not started at boot by FSM (the user starts it from the UI), so those ports are not open at idle. Note this in `settings.yaml` (required false) and in section 10. The test needs outbound internet for the Factorio download; if CI is offline, add `filePaths` only for `/app/fsm/factorio-server-manager`.

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs, no persistence. Target: `USER apps`; `/opt/fsm-data`, `/opt/factorio/{saves,mods,config}` and the install tree all moved under `/config` (draft says "saves and mods move to /config").
- Upstream writes: sqlite DB, log file, Factorio saves/mods/config/logs, temp download. All under `/config` or `/tmp`.
- Factorio binary writes `factorio-current.log` into its install dir (under `/config/factorio`, writable).

## 10. Risks, caveats and open questions

- amd64 only (Factorio x86_64).
- Runtime download needs internet at first start; pinned version via `FACTORIO_VERSION` (`stable` moves).
- Factorio multiplayer authentication (username/token for `require_user_verification`) is configured in the server settings by the user, not needed to start.
- Bind address and cwd write behaviour UNVERIFIED.
- Game and RCON ports cannot be tested at idle.
- Duplicate of `factorioservermanager` draft: keep one image and decide which name wins to avoid two builds.

## 11. Build and test steps

```sh
cd apps/fsm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create fsm-probe-config
docker run --rm -d --name fsm-probe --read-only --tmpfs /tmp -v fsm-probe-config:/config fsm:0.10.1
docker logs -f fsm-probe     # expect Factorio download/extract, then the manager listening on :8080
forgetool containers test --image fsm:0.10.1 --config ./apps/fsm/container-test.yaml
docker rm -f fsm-probe; docker volume rm fsm-probe-config
```
Restart the container on the same volume to prove the second start does not re-download.

## 12. PR checklist

- Branch `feat/add-fsm`, commit `feat(fsm): add new container`.
- Template filled, `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, zip asset name and checksum, Factorio download, bind address, RCON port, game port.
