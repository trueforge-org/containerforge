# neverwinternights-ee — implementation plan
> Source: ./draft.md · Target: apps/neverwinternights-ee/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream release of the server is published as a versioned artifact. The community image uses `NWNEE_V="latest"` (`https://raw.githubusercontent.com/ich777/docker-nwnee/master/Dockerfile`). Version to pin: UNVERIFIED, no release or tag source has been identified. |
| Draft container | `ghcr.io/ich777/nwnee-server:latest`. Chart TrueCharts (not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-nwnee/master/Dockerfile. `FROM ich777/debian-baseimage:bullseye_amd64` (Debian bullseye, amd64 only). Installs gcc-10, g++-10, default-libmysqlclient-dev, libpq-dev, libseccomp-dev, ruby-dev, ant, libluajit-5.1-2, curl, unzip, mariadb-server, screen, redis-server, jq, libbsd0. Downloads `libsndio6.1_1.1.0-3_amd64.deb` from a Debian mirror and `dpkg -i` it. Creates user `nwnee` (home `/nwnee`). No USER instruction (runs as root). No EXPOSE, no VOLUME. |
| Entrypoint | `/opt/scripts/start.sh`, reviewed at https://raw.githubusercontent.com/ich777/docker-nwnee/master/scripts/start.sh. It sets UID/GID/UMASK to the `USER` values, runs optional `/opt/custom/user.sh` or `/opt/scripts/user.sh`, chowns `/opt/scripts`, `/var/lib/mysql`, `/var/run/mysqld`, `/var/lib/redis`, and redis binaries. |
| Server download | Not in the Dockerfile. Not found in the start script by grep. UNVERIFIED how and from where the NWN:EE server files are fetched (Beamdog vendor download, not confirmed). |
| Env vars (real, Dockerfile) | `SERVER_DIR=/nwnee`, `NWNEE_V=latest`, `USER=nwnee`, `UID=99`, `GID=100`, `UMASK=000`, `DATA_PERM=770`, `MOD_NAME`, `MAX_CLIENTS=4`, `MINLEVEL=1`, `MAXLEVEL=40`, `PAUSEAPLAY=0`, `PVP=0`, `SERVERVAULT=0`, `ELC=0`, `ILR=0`, `ONEPARTY=0`, `DIFF=1`, `RLD_W_E=1`, `GAME_PARAMS`, `SRV_NAME`, `PUBLIC_SRV=0`, `GAME_PORT=5121`, `LOG_LVL=6`, `AUTO_SAV_I=5`, `PPW=Docker`, `APWD=adminDocker`. |
| Ports | `GAME_PORT=5121` (Dockerfile env). Protocol UDP per the draft is UNVERIFIED on the fetched page. |
| Source licence | None declared: `https://api.github.com/repos/ich777/docker-nwnee` returns `license: null`, last push 2024-01-02. The game itself is closed source (Beamdog). |
| Vendor store | https://store.steampowered.com/app/704450/ (not fetched; licence and EULA UNVERIFIED). |
| arm64 | Base is `bullseye_amd64` and the apt `.deb` is amd64. arm64 unsupported is the draft's claim: consistent with the base, vendor binary arch UNVERIFIED. |

Draft's claim of `libc6:i386` multiarch: NOT confirmed. The Dockerfile has no i386 step.

## 2. Target layout

If the blockers in section 10 are resolved, the layout would be:

- `apps/neverwinternights-ee/Dockerfile`
- `apps/neverwinternights-ee/docker-bake.hcl`
- `apps/neverwinternights-ee/settings.yaml`
- `apps/neverwinternights-ee/container-test.yaml`
- `apps/neverwinternights-ee/start.sh`
- `apps/neverwinternights-ee/defaults/` only if a seeded server config is needed (reason: `/config` must seed a default `nwn.ini`-style config; UNVERIFIED).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). No `etc/` unless a config file has to be shipped.

## 3. Base image

Proposed: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Reason: the draft says ubuntu fits and the upstream Debian bullseye base is amd64-only and old. Closest sibling: a closed-source native server on ubuntu, to be picked from `apps/` (not yet chosen; this is an open decision). The needed 32-bit libraries are not confirmed: the upstream Dockerfile has no i386 step, so do not add multiarch unless the server binary's `ldd` output needs it (check in round 1).

## 4. Dockerfile

1. Build stage not needed: no compiling is required. A single ubuntu stage.
2. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Fail the build on `TARGETARCH != amd64` (the server is amd64 only).
3. Install the runtime libs needed by the server, only if `ldd` shows them missing. Upstream installs MariaDB, Redis and Screen, which are not required by the game server itself. Do not include them unless the server proves it needs them.
4. Download the vendor server files only if a legal, stable URL is found. UNVERIFIED: no URL is confirmed. Do not add a download from an unconfirmed URL.
5. Ship the Beamdog EULA or licence text with the image to `/usr/share/licenses/neverwinternights-ee/` once it is located.
6. `ENV HOME=/config SERVER_DIR=/config/nwnee`. Caches to `/tmp`.
7. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5121` (UDP), `VOLUME /config`.

## 5. docker-bake.hcl

Use the four standard targets and default group from `apps/adguardhome-sync`. Values:

- `APP` = `neverwinternights-ee`
- `VERSION` = UNVERIFIED pin. The renovate datasource is not known: no tag or release source identified. Do not guess one.
- `LICENSE` = proprietary: the image has no open-source licence. Use the value the maintainers settle on (UNVERIFIED).
- `SOURCE` = https://store.steampowered.com/app/704450/ (vendor page, no source repo).

Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/704450/"
ports:
  - port: 5121
    protocol: udp
    required: true
env:
  - name: SRV_NAME
    default: "Docker NWN:EE"
    required: false
  - name: GAME_PORT
    default: "5121"
    required: false
  - name: MAX_CLIENTS
    default: "4"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Add only the variables `start.sh` actually reads. Upstream's `PPW` and `APWD` default to fixed passwords: do not carry those defaults over. Require them from the environment or generate them on first start (see section 7). Dependencies: none declared. If MariaDB is kept, it is bundled, not a separate app.

## 7. start.sh

Plan, to be confirmed in round 1:
- Create `/config/nwnee` on first start only. Do not overwrite existing saves or config.
- Apply `SRV_NAME`, `GAME_PORT`, `MAX_CLIENTS` and the other game options into the server config on every start.
- Passwords: `PPW` and `APWD` from the environment. If unset, generate on first start and store in `/config`, not in the process list.
- Server binds `0.0.0.0` on the UDP game port (check the server's own bind option: UNVERIFIED).
- `exec` the server binary in the foreground for PID 1 signal handling.
- No writes to `/app`. Scratch goes to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
```

Add a UDP check on 5121 only if forgetool supports UDP. Otherwise, a `file` or `process` check on the server binary. Timeouts: large first-start download, so `timeoutSeconds` must be high or the test cannot pass without the download. If the server is not downloaded in the image, the test is at most a smoke test: state the narrowing in a comment. The DB exception does not apply (MariaDB is bundled, not a dependency).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with a `nwnee` user and `UID`/`GID` env. ContainerForge runs `USER apps`, so the start script must not call `usermod`, `groupmod`, `chown` on `/var/lib/mysql` or run `su`.
- Writes: `/nwnee` (serverfiles, draft persistence) becomes `/config/nwnee`. MariaDB and Redis data (`/var/lib/mysql`, `/var/lib/redis`) would need `/config` too, if kept, which is a reason to drop them.
- `--read-only --tmpfs /tmp` is possible once all writes go to `/config` or `/tmp`.
- The server is x86 only, so arm64 is out of scope.

## 10. Risks, caveats and open questions

- BLOCKER: no confirmed, legal source for the server files. The draft admits this. Do not port until a stable download is confirmed.
- BLOCKER: no versioned pin. `latest` is not reproducible and renovate cannot track it.
- BLOCKER: no licence. The upstream repo declares none, and the game is closed source. The maintainers need to decide whether the image can be published.
- Upstream bundles MariaDB and Redis, which contradicts the single-process model and the database exception. Remove them unless proven needed.
- The draft's i386 claim is not confirmed (section 1).
- The upstream Dockerfile is from a Debian bullseye base, not a current image.
- A first start downloads a large set of files: measure before setting `timeoutSeconds`.
- UDP 5121 must be reachable from players: needs host or port forwarding.

## 11. Build and test steps

Only after the section 10 blockers are resolved. From `apps/neverwinternights-ee/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name nwnee-probe --read-only --tmpfs /tmp -v nwnee-probe-config:/config ghcr.io/trueforge-org/neverwinternights-ee:<version>` then `docker logs -f nwnee-probe`. Expected readiness line: UNVERIFIED until the server runs.
4. `forgetool containers test --image <image>:<version> --config ./apps/neverwinternights-ee/container-test.yaml`.
5. Clean up: `docker rm -f nwnee-probe; docker volume rm nwnee-probe-config`.

## 12. PR checklist

- Branch `feat/add-neverwinternights-ee`, commit `feat(neverwinternights-ee): add new container`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: the server download (not confirmed), arm64 (unsupported), and gameplay. Do not tick "Built container locally" unless the build ran.
- Do not open this PR until the section 10 blockers are settled. Recommendation: keep this app as a draft.
