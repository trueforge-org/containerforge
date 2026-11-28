# cstrike1-6 — implementation plan
> Source: ./draft.md · Target: apps/cstrike1-6/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Chart | cstrike1-6, Steam app 90 (HLDS), `GAME_NAME=cstrike`, `GAME_PORT=27015`, `GAME_PARAMS=+maxplayers 32 +map de_dust` | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrike1-6/values.yaml |
| Chart image today | `ghcr.io/ich777/steamcmd:cstrike1.6@sha256:6f5d33c4719b6a82798c08abb2a714cfc7f8b4bbf8d540ee2c75d981b43a39fc` | same values.yaml, line 5 |
| Upstream wrapper | ich777/docker-steamcmd-server, master, last push 2026-07-18, no SPDX license declared (GitHub API `license: null`) | `gh api repos/ich777/docker-steamcmd-server` |
| Upstream Dockerfile | `FROM ich777/debian-baseimage:bullseye_amd64`, installs `lib32gcc-s1 lib32stdc++6 lib32z1`, ENTRYPOINT `/opt/scripts/start.sh`, runs as root wrapper | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Upstream start | Remaps UID/GID, chowns `/serverdata`, runs `start-server.sh` as user `steam` | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh |
| SteamCMD download | `http://media.steampowered.com/client/steamcmd_linux.tar.gz` (plain HTTP, no checksum in the wrapper) | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh |
| Game install | `steamcmd +login anonymous +force_install_dir <SERVER_DIR> +app_update 90 [validate] +quit`, then `hlds_run -game cstrike <GAME_PARAMS> -console +port <GAME_PORT>` (the `cstrike1.6` branch of start-server.sh uses `hlds_run`; verified) | same start-server.sh |
| License | Steam EULA for the game server (not checked on a fetched page: `UNVERIFIED: Steam EULA text not fetched`). Wrapper: none declared | GitHub API |
| Renovate | `UNVERIFIED: no versioned upstream artifact; the image tag is a variant tag. Plan uses the apt steamcmd package (see section 3), which the sibling apps/steamcmd already pins with datasource=deb` | apps/steamcmd/docker-bake.hcl (local) |
| Ports | 27015/tcp (rcon) and 27015/udp (game and query) | chart values.yaml lines 21-31 |
| Upstream write paths | `/serverdata/serverfiles`, `/serverdata/steamcmd`, `/serverdata/.steam/sdk32` | Dockerfile ENV and start-server.sh |
| arm64 | No. SteamCMD bootstrap is 32-bit x86 (lib32 libs). apps/steamcmd is amd64 only (local: apps/steamcmd/docker-bake.hcl `image-all` uses `linux/amd64`) | local sibling |
| Dependencies | None (no DB) | chart Chart.yaml (draft) |

Upstream Dockerfile and wrapper were reviewed; the chart's values were reviewed. The Dockerfile in the draft is the upstream wrapper.

## 2. Target layout

Files in `apps/cstrike1-6/`:

- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, it performs the SteamCMD install and launches hlds_run. Copied via the allow-list in `include/.dockerignore` (`start.sh` is allowed).
- `defaults/`, `etc/`, `scripts/`, `health/`: not needed. The Dockerfile uses `COPY --chmod=0755 start.sh /start.sh` plus `COPY --chmod=0755 . /`, as apps/steamcmd does.
- `root/`: never used.
- `DOWNSTREAM_CHANGES.md`: not needed, this app is not a `FROM` base.

## 3. Base image

- FROM: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (the repo ubuntu base, same digest as `apps/steamcmd`).
- Why: the upstream wrapper runs on Debian with the ich777 base, which is not a ContainerForge base. ContainerForge already packages SteamCMD in `apps/steamcmd`, so this app follows the same install path.
- Why not `ghcr.io/trueforge-org/steamcmd` as FROM: no sibling uses it as FROM (grep of `apps/*/Dockerfile` finds no `FROM ghcr.io/trueforge-org/steamcmd`), and its published tag is `UNVERIFIED`. The plan copies the install steps from `apps/steamcmd/Dockerfile` instead.
- Closest sibling: `apps/steamcmd` (same steamcmd install, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

Steps:

1. `ARG VERSION` and `ARG VENDOR`. `VERSION` matches the bake default (see section 5). `VERSION` is the apt steamcmd package version `0~<version>`, the same as apps/steamcmd (`steamcmd:i386=0~${VERSION}`). Keep the bake default identical to apps/steamcmd's pinned version unless a renewed package is needed; check the value against `apt-cache policy steamcmd` on the base at build time.
2. `USER root`.
3. `dpkg --add-architecture i386`, `add-apt-repository -y multiverse`, debconf accept for the Steam license, `apt-get install -y --no-install-recommends steamcmd:i386=0~${VERSION} lib32gcc-s1 lib32stdc++6 lib32z1`, then `rm -rf /var/lib/apt/lists/*`. The lib32 packages are listed by the upstream Dockerfile; check if they are already pulled by `steamcmd:i386` and drop them if so.
4. Create `/usr/local/share/steamcmd` and a symlink to `/usr/games/steamcmd` (same as apps/steamcmd). Do not write to `/app` at runtime.
5. `mkdir -p /config`, `chown -R apps:apps /config`.
6. `ENV` (build-time only defaults that do not write to /config): `GAME_ID=90`, `GAME_NAME=cstrike`, `GAME_PORT=27015`, `GAME_PARAMS="+maxplayers 32 +map de_dust"`, `XDG_CACHE_HOME=/tmp`, `HOME=/config`. Put the actual defaults in settings.yaml; keep ENV minimal.
6a. Licensing: copy the steamcmd license text if it ships in the package, to `/usr/share/licenses/cstrike1-6/`. Otherwise `UNVERIFIED: no license file in package`.
7. `COPY --chmod=0755 start.sh /start.sh`.
8. `EXPOSE 27015/tcp 27015/udp`.
9. `VOLUME /config` is optional (settings.yaml declares the volume).
10. `USER apps`, then `COPY --chmod=0755 . /`, `ENTRYPOINT ["/start.sh"]`.

Do not add a `CMD` that would bypass start.sh.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "cstrike1-6"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "UNVERIFIED: Steam EULA; wrapper declares no SPDX"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/90"
}
```

- `VERSION` is the steamcmd apt package, matching the Dockerfile `ARG VERSION`. This is the only versioned artifact; the game files are downloaded at runtime (open question 10.2).
- `LICENSE`: set this to the license of the software in the image. The image ships steamcmd (Valve EULA) and the game is downloaded at runtime, so the value is `UNVERIFIED` until checked. Do not guess an SPDX id. Use `LicenseRef-Steam-EULA` only if the team agrees.
- Targets: `docker-metadata-action`, `image`, `image-local` (`${APP}:${VERSION}`, `output=type=docker`), `image-all` with `platforms = ["linux/amd64"]` (not arm64), and `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/cstrike1-6 && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/90"
ports:
  - port: 27015
    protocol: tcp
    required: true
  - port: 27015
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: STEAM_USERNAME
    default: ""
    required: false
  - name: STEAM_PASSWORD
    default: ""
    required: false
  - name: GAME_PARAMS
    default: "+maxplayers 32 +map de_dust"
    required: false
  - name: GAME_PORT
    default: "27015"
    required: false
  - name: VALIDATE
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
```

- Do not add `GAME_ID` or `GAME_NAME` to env. They are fixed to 90 and cstrike in start.sh; the app does not need a user override (a plan decision). If the team wants them overridable, add them with the same defaults.
- Env names match the upstream wrapper (`USERNAME`/`PASSWRD` upstream). This plan renames them to `STEAM_USERNAME`/`STEAM_PASSWORD`, following apps/steamcmd naming. The rename must be applied in start.sh so the names are the ones the script reads.
- `dependencies:` none. Omit the key (no DB).
- Chart PVCs `/serverdata/serverfiles` and `/serverdata/steamcmd` are remapped (see section 9). They are not volumes in settings.yaml; only `/config`.

## 7. start.sh

Behaviour to implement (bash, `set -euo pipefail`):

1. Set `HOME=/config`, `XDG_CACHE_HOME=/tmp`, `TMPDIR=/tmp`.
2. Create `/config/steamcmd`, `/config/serverfiles`, `/config/.steam/sdk32` only if missing (idempotent, seeds empty `/config`).
3. If `/config/steamcmd/steamcmd.sh` is missing, copy from `/usr/local/share/steamcmd/steamcmd.sh` and `linux32/steamcmd` as apps/steamcmd does. Do not write to `/app`.
4. Run `steamcmd +force_install_dir /config/serverfiles +login <user or anonymous> [pass] +app_update 90 [validate] +quit`. `validate` only when `VALIDATE=true`. Pass the password through a script file in `/tmp` (as apps/steamcmd does with `+runscript`) so it does not appear in the process list.
5. On update failure, exit non-zero with a clear error (matching apps/steamcmd).
6. Copy `linux32/*` into `/config/.steam/sdk32/` when `steamclient.so` is missing (upstream step).
7. Apply `GAME_PARAMS` and `GAME_PORT` from env. Quote arguments with an array, not `eval`.
8. `cd /config/serverfiles` and `exec ./hlds_run -game cstrike ${GAME_PARAMS} -console +port ${GAME_PORT}` (GoldSrc app 90 ships `hlds_run`, as in the upstream `cstrike1.6` branch). The `exec` makes the server PID 1 handoff.
9. Listen on all interfaces. srcds binds to `0.0.0.0` by default; check the first boot log (see section 11).
10. Do not write to `/app`. All state, downloads, and steamcmd caches go to `/config` (the game files, which must persist) or `/tmp` (scratch).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
  - /start.sh
  - /usr/local/share/steamcmd/steamcmd.sh
tcp:
  - port: '27015'
```

- Probe every port in settings.yaml: `tcp` on 27015 (UDP cannot be probed with the schema's tcp/http check, so that is recorded as `UNVERIFIED: forgetool has no udp probe`).
- The test runs with no env vars, so the server path (steam download plus srcds) is not reached in the default test unless it starts. Expect a first start that downloads the game (several GB) from Steam: set `timeoutSeconds` high and check the schema for it. No sibling sets `timeoutSeconds`; the apps/steamcmd test does not set it either. `UNVERIFIED: whether CI has Steam network access and the time budget`.
- Add a `filePaths` entry for any file under `/config` only if the schema allows it.
- No DB, so the DB-dependency narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Target |
| --- | --- |
| Wrapper runs as root, then `usermod` for UID 99 | Runs as `apps` (`USER apps`); no UID remap in start.sh |
| `/serverdata/serverfiles` | `/config/serverfiles` (persistent, the game files) |
| `/serverdata/steamcmd` | `/config/steamcmd` (persistent) |
| `/serverdata/.steam/sdk32` | `/config/.steam/sdk32` (persistent, seeded only when missing) |
| `umask 000`, `chmod -R 770` | Not used; file perms follow `apps` ownership. `UMASK` may be set in start.sh if the team wants it. |
| `ulimit -n 2048` | Not applied in the Dockerfile; check srcds needs at runtime, `UNVERIFIED` |
| `/tmp` writes by steamcmd | Set `TMPDIR=/tmp` and `XDG_CACHE_HOME=/tmp` |

- `privileged`: not required (draft expectation confirmed by chart `privileged` default false).
- `readOnlyRootFilesystem`: the image runs on `--read-only --tmpfs /tmp` with `/config` as a volume. Steam and srcds write only under `/config` and `/tmp`.
- `non-root`: the chart runs as UID 0; the target runs as `apps`, so the chart expectation changes. Verify the game still starts as `apps`.

## 10. Risks, caveats and open questions

10.1 Blockers: no arm64 (SteamCMD 32-bit). Requires Steam network access at first start, the game download is large.

10.2 Renovate: no upstream version exists for the game, so the image version is the steamcmd apt version. The game build itself changes on each update; decide whether to pin the Steam build (manifest) or accept a moving target.

10.3 Steam EULA and `LICENSE` value: not confirmed (`UNVERIFIED`).

10.4 `hlds_run` may need extra 32-bit libs beyond `lib32gcc-s1 lib32stdc++6 lib32z1`. Confirm in the run.

10.5 GSLT: the draft says a Game Server Login Token may be needed for a public listing. Not verified on any fetched page (`UNVERIFIED`). If needed, add `STEAM_GSLT` as an env var, passed as `+sv_setsteamaccount`, and document it.

10.6 Upstream wrapper uses plain HTTP to download steamcmd (`media.steampowered.com`). The apt package is used here instead, so the plain HTTP fetch is not repeated.

10.7 Legacy game: mods and maps are added by hand in `/config/serverfiles/cstrike` (draft caveat, `inferred`).

10.8 Upstream wrapper has an unrelated fix for CSDM (`chmod 550 cssdm.games.txt`). Not ported unless the user runs CSDM.

## 11. Build and test steps

From `apps/cstrike1-6/`, per `build-test-protocol.instructions.md`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty `/config`:
   ```sh
   docker run --rm -d --name cstrike1-6-probe --read-only --tmpfs /tmp \
     -v cstrike1-6-probe-config:/config ${APP}:${VERSION}
   docker logs -f cstrike1-6-probe
   ```
   Pass: process stays up, log shows `Update Server` completing and hlds reporting it is listening on port 27015 (readiness signal to confirm on first run, `UNVERIFIED` exact text), and no fatal error. Cleanup: `docker rm -f cstrike1-6-probe; docker volume rm cstrike1-6-probe-config`.
4. `forgetool containers test --image <image>:<version> --config ./apps/cstrike1-6/container-test.yaml`.
5. Round limit: 10 rounds, then record `unfixable`.

## 12. PR checklist

- Branch: `feat/add-cstrike1-6`.
- Commit: `feat(cstrike1-6): add new container`. Use the `Co-Authored-By` line the environment gives.
- PR title: `feat(cstrike1-6): add new container`. Target `main`.
- PR body: fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Not tested: state clearly in the PR if the image was not built or run (for example, no Steam network access). Do not check "Built container locally" unless it was built.
- Check before PR: bake print passed; image-local built; empty `/config` start on `--read-only --tmpfs /tmp`; `container-test.yaml` assertions run via forgetool; no assertion weakened; scratch containers and volumes removed.
