# valheim — implementation plan
> Source: ./draft.md · Target: apps/valheim/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream image tool `v1.4.1` (latest release, published 2026-10-19). Chart image `ghcr.io/lloesche/valheim-server:latest` is rolling; the game server itself is downloaded from Steam at start, so there is no fixed game version in the image. Source: https://api.github.com/repos/lloesche/valheim-server-docker/releases/latest |
| Repo | Upstream is now at `community-valheim-tools/valheim-server-docker` (draft links this); not archived, pushed 2026-10-20. License Apache-2.0. Source: https://api.github.com/repos/community-valheim-tools/valheim-server-docker |
| Renovate | For the tool: `datasource=github-releases depName=community-valheim-tools/valheim-server-docker versioning=semver`. The game build itself is not pinned by ContainerForge; it comes from Steam via SteamCMD at runtime. |
| License | Apache-2.0 for the wrapper tooling. The Valheim server is closed-source Steam software and is not redistributed; license file shipped is the wrapper's. |
| Source URL | https://www.valheimgame.com/ (vendor); tooling https://github.com/community-valheim-tools/valheim-server-docker |
| Per-arch download | amd64: Steam app 896660 via SteamCMD (`https://store.steampowered.com/app/896660/`). arm64: **no vendor build**; not possible. |
| Checksum source | Steam manifests and depot cache (SteamCMD validates); no sha256 published for the server files. |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/community-valheim-tools/valheim-server-docker/main/Dockerfile`. Stages: `debian:trixie-slim` build (Go 1.24.1, busybox 1.36.1 with sha256, supervisor 4.3.0, python-a2s 1.4.1, env2cfg), `debian:buster-slim` i386 libs (linux/386), final `debian:trixie-slim` with SteamCMD. `EXPOSE 2456-2458/udp`, `9001/tcp`, `80/tcp`. `CMD ["/usr/local/sbin/bootstrap"]`. No USER, no VOLUME. `PUID`/`PGID` default 0. |
| Ports | Game: `SERVER_PORT` default 2456 UDP (2456-2457 per README mapping; 2458 Steam query per Dockerfile EXPOSE). Supervisor `SUPERVISOR_HTTP_PORT` 9001. Status `STATUS_HTTP_PORT` 80. Source: README at https://api.github.com/repos/community-valheim-tools/valheim-server-docker/contents/README.md |
| Env (README) | `SERVER_PORT` (2456), `SERVER_PASS_FILE`, `ADMINLIST_IDS`, `BANNEDLIST_IDS`, `PERMITTEDLIST_IDS`, `CROSSPLAY` (false), `BACKUPS` (true), `BACKUPS_CRON` (`5 * * * *`), `BACKUPS_DIRECTORY` (`/config/backups`), `BACKUPS_MAX_AGE` (3), `BACKUPS_MAX_COUNT` (0), `BACKUPS_IF_IDLE` (true), `BACKUPS_IDLE_GRACE_PERIOD` (3600), `BACKUPS_ZIP` (true), `PERMISSIONS_UMASK` (022), `STEAMCMD_ARGS` (validate), `PUBLIC_TEST` (false), `VALHEIM_PLUS` (false), `BEPINEX` (false), `SUPERVISOR_HTTP_PORT` (9001), `SUPERVISOR_HTTP_PASS_FILE`, `STATUS_HTTP_PORT` (80), `STATUS_HTTP_CONF` (`/config/httpd.conf`), `STATUS_HTTP_HTDOCS` (`/opt/valheim/htdocs`), `SYSLOG_REMOTE_PORT` (514). Server name, world and password variable names: UNVERIFIED (not in the fetched excerpt). |
| Data paths | `/config` (config, worlds_local, backups). `/opt/valheim` (downloaded server and `dl/depotcache`). |
| Dependencies | `apps/steamcmd` exists in this repo and is the intended runtime base. No database. |
| copy-from | `ghcr.io/lloesche/valheim-server:latest` is glibc Debian but the server is downloaded at runtime, so `COPY --from` gives nothing useful. Answer: `no`. |

## 2. Target layout

- `apps/valheim/Dockerfile`
- `apps/valheim/docker-bake.hcl`
- `apps/valheim/settings.yaml`
- `apps/valheim/container-test.yaml`
- `apps/valheim/start.sh` (replaces upstream `bootstrap` and supervisor; see section 7)

No `defaults/` unless a config seed is needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a base image). Closest sibling: `apps/steamcmd` (the base) and its `start.sh`/`container-test.yaml`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`. No sibling Dockerfile in this repo uses the steamcmd image as a `FROM` yet, so the exact tag and digest must be taken from the `apps/steamcmd` build output after it is published; UNVERIFIED here. Fits because the base already provides SteamCMD and the `apps` user. Do not reinstall SteamCMD. Ubuntu is the underlying base of steamcmd, so no direct ubuntu FROM is needed.

## 4. Dockerfile

1. Single final stage (no build stage needed: the game server is downloaded at runtime, and the tooling is shell).
2. `ARG VERSION` (tool version `1.4.1`, matching `docker-bake.hcl`). `USER root` only for `apt-get install -y --no-install-recommends` of the runtime libs the server needs: `libsdl2-2.0-0` (inferred from draft) and any 32-bit libs SteamCMD requires if needed (UNVERIFIED; upstream installs `libsdl2`, 32-bit libc, libstdc++, SDL2, libcurl from buster for i386). Confirm by running the server once.
3. Create the data layout owned by `apps`: `install -d -o apps -g apps /config /tmp/valheim-cache` (no `/opt/valheim` writes at runtime, see section 9).
4. Copy the start script and license: `COPY --chmod=0755 start.sh /start.sh`, license of the wrapper to `/usr/share/licenses/valheim/LICENSE` from the tooling repo.
5. Environment: `ENV HOME=/config XDG_CACHE_HOME=/tmp/cache STEAMCMD_ARGS=validate`. Note the `STEAMCMD_ARGS` default must match the README.
6. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
EXPOSE 2456-2458/udp
EXPOSE 80/tcp
VOLUME /config
```

Do not expose supervisor 9001 unless the chosen start script uses it.

## 5. docker-bake.hcl

Same 4 standard targets and default group as the other plans in this repo. Values:

- `APP` = `valheim`
- `VERSION` = `1.4.1` with `// renovate: datasource=github-releases depName=community-valheim-tools/valheim-server-docker versioning=semver`
- `LICENSE` = `Apache-2.0`
- `SOURCE` = `https://github.com/community-valheim-tools/valheim-server-docker`
- `image-all` platforms = `linux/amd64` only.

Run `docker buildx bake --print` from `apps/valheim/`. Dockerfile `ARG VERSION` must be `1.4.1`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.valheimgame.com/"
ports:
  - port: 2456
    protocol: udp
    required: true
  - port: 2457
    protocol: udp
    required: true
  - port: 80
    protocol: http
    required: false
env:
  - name: SERVER_PORT
    default: "2456"
    required: false
  - name: BACKUPS
    default: "true"
    required: false
  - name: BACKUPS_CRON
    default: "5 * * * *"
    required: false
  - name: BACKUPS_DIRECTORY
    default: "/config/backups"
    required: false
  - name: CROSSPLAY
    default: "false"
    required: false
  - name: STEAMCMD_ARGS
    default: "validate"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 2458/udp (Steam query) is listed by upstream EXPOSE; add it only if the server actually binds it (UNVERIFIED). Server name, world and password variables are UNVERIFIED and must be read from the README table before writing `env:`. `SERVER_PASS_FILE` is a secret path, not a default. Do not invent env vars.

## 7. start.sh

- Idempotent: `install -d -m 0755 /config /config/worlds_local /config/backups /tmp/steam`. Never write to `/opt`, `/app` or `/usr`.
- Install the server into `/config/valheim` (persistent, avoids a ~1 GB redownload per start) with `steamcmd +force_install_dir /config/valheim +login anonymous +app_update 896660 ${STEAMCMD_ARGS} +quit`. Run with `HOME=/tmp` so SteamCMD writes its state to `/tmp`. Use the `/tmp/steam` cache for the depot cache; document that a fresh `/config` redownloads.
- Read `SERVER_PORT` (default 2456), `CROSSPLAY`, `BACKUPS*` from the environment; write `/config/valheim` launch arguments; do not put the server password on the command line (use `SERVER_PASS_FILE` or the upstream env name, UNVERIFIED).
- Launch `./valheim_server.x86_64 -name ... -port "${SERVER_PORT}" -world ... -savedir /config` with `exec` as the final command. Bind `0.0.0.0` (Valheim default).
- Empty `/config` must work: first start downloads the server and creates `/config/worlds_local`.

## 8. container-test.yaml

- Schema header from the siblings.
- `filePaths`: `/start.sh`, `/usr/share/licenses/valheim/LICENSE`, and `/usr/local/bin/steamcmd` (inherited from the base; confirm path in `apps/steamcmd` container-test).
- No `tcp` probe for UDP ports: a `tcp` probe does not test UDP. Use a process or log check for the game port if forgetool supports UDP probes (UNVERIFIED); otherwise narrow the test and say so in a comment.
- Startup downloads ~1 GB from Steam, so `timeoutSeconds` must be large. The test runs without network guarantees: if the download fails, the test fails. Add a comment that Steam access is required (narrowed per `build-test-protocol` if the download cannot run in CI).
- Empty-env run: the server path needs `/config` only; the password-required code path goes to `filePaths` and is run manually.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with `PUID`/`PGID` defaulting to 0. ContainerForge runs as `apps`. Drop `PUID`/`PGID`; the image user is fixed.
- Writes: server install under `/config/valheim` (persistent), backups `/config/backups`, SteamCMD state and depot cache `/tmp/steam` (no `/config` cache), status/supervisor files under `/tmp`.
- `/opt/valheim` in upstream is a data path; ContainerForge uses `/config/valheim`. Chart mount for `/opt/valheim` moves to `/config` (note for the chart repo).
- `STATUS_HTTP_CONF` default `/config/httpd.conf` must be relocated if it is written at runtime.
- Chart `runAsUser 0`, `readOnlyRootFilesystem false` are expected to change: run with `--read-only --tmpfs /tmp`, verify the install and launch work.
- Not privileged. `CAP_SYS_NICE` is optional upstream (for Steam CPU scheduling); do not grant it by default.

## 10. Risks, caveats and open questions

- **arm64 blocker.** The vendor ships no arm64 server; not possible.
- **Closed-source download.** The server is fetched from Steam at runtime (~1 GB, needs Steam access). First start is slow and network-dependent.
- **Multi-process upstream.** Upstream uses supervisor, bootstrap and busybox httpd. This plan replaces them with one `start.sh`. Confirm the server has no hard dependency on the supervisor status file.
- **BepInEx and ValheimPlus** are downloaded at runtime and break after game updates. Out of scope for the first PR; disable (`BEPINEX=false`, `VALHEIM_PLUS=false`) unless the user asks.
- **UNVERIFIED env names** for server name, world and password. Confirm from the README table before writing `settings.yaml`.
- **UNVERIFIED UDP probe support** in forgetool.
- **Chart rolling tag.** Chart uses `:latest`; this plan pins tool `1.4.1` only.
- **Dockerfile link.** Draft points at the old org path for the source; the community-valheim-tools repo is current and the lloesche image is what the chart pulls.

## 11. Build and test steps

From `apps/valheim/`, in order (`.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name valheim-probe --read-only --tmpfs /tmp -v valheim-probe-config:/config valheim:1.4.1`, then `docker logs -f valheim-probe`. Readiness: the server launch line or "Game server connected" equivalent, confirmed on a live run. The first start downloads from Steam; allow several minutes. Container must stay up.
4. `forgetool containers test --image valheim:1.4.1 --config ./container-test.yaml`
5. Cleanup: `docker rm -f valheim-probe; docker volume rm valheim-probe-config`.

No build or docker run was done for this plan.

## 12. PR checklist

- Branch `feat/add-valheim`; commit and title `feat(valheim): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what was run.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Say what was not tested: the Steam download path, the UDP game port, arm64 (not possible), and env names not confirmed live.
- Downstream: none (not a base image).
