# avorion — implementation plan
> Source: ./draft.md · Target: apps/avorion/ · Difficulty: easy · Role: main · Verified on 2026-11-25 · Status: blocked on unverified server facts (see section 10)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: the Avorion dedicated server build number and Steam app id were not fetched. The Valve wiki (https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide) and the Steam store page were not read in this run. The server is installed at first start from Steam, so there is no release tag to pin. |
| Draft container | `ghcr.io/ich777/steamcmd:avorion` (third-party ich777 image, not a ContainerForge source). Upstream Dockerfile reviewed: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (FROM `ich777/debian-baseimage:bullseye_amd64`, `ENV GAME_ID`/`GAME_PARAMS`/`GAME_PORT=27015`/`DATA_DIR=/serverdata`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no USER, no EXPOSE, no VOLUME). The ich777 image is not the source of truth for us: we reuse the ContainerForge steamcmd base instead. |
| ContainerForge steamcmd base | `apps/steamcmd/` (Dockerfile FROM `ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`; installs `steamcmd:i386`; `/usr/local/bin/steamcmd` wrapper; `/usr/local/share/steamcmd/steamcmd.sh`; `USER apps`; `COPY --chmod=0755 . /`). Its start.sh: when the first arg starts with `+` it builds a SteamCMD script with `STEAM_USERNAME`/`STEAM_PASSWORD` (default anonymous); otherwise it `exec`s the args. Source: /workspaces/containers/apps/steamcmd/Dockerfile and start.sh. |
| Renovate | UNVERIFIED for the avorion image. The steamcmd base uses `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (apps/steamcmd/docker-bake.hcl), and the avorion `VERSION` will be the steamcmd base tag or the Avorion build id, to be decided in section 10. |
| License | Avorion server: UNVERIFIED (not read). Our `LICENSE` must be the license of the software in the image. Set to the Valve/Avorion EULA once read; until then the bake file must not claim an open license. |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (draft's website link). No upstream source repository. |
| Download | SteamCMD: `https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz` (draft link, not fetched). The base already installs SteamCMD from apt, so no separate download is needed. Avorion itself: pulled by SteamCMD at first start, UNVERIFIED app id. |
| Checksum source | Not applicable for the game server (installed by SteamCMD). Base SteamCMD comes from apt, with the package version pinned in `apps/steamcmd`. |
| Arch | amd64 only (SteamCMD is x86; draft says arm64 no; consistent with the steamcmd base). |
| Ports | UNVERIFIED: draft lists 27000/udp, 27000/tcp, 27020/udp (inferred from chart). Chart also mentions 27003 and 27021. Not confirmed from a fetched page. |
| Env vars | UNVERIFIED for avorion. The ich777 wrapper's env (`GAME_ID`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `USERNAME`, `PASSWRD`, `UMASK`, `UID`, `GID`) is not used: our start.sh uses the steamcmd base's `STEAM_USERNAME`/`STEAM_PASSWORD` only. |

## 2. Target layout

- `apps/avorion/Dockerfile`
- `apps/avorion/docker-bake.hcl`
- `apps/avorion/settings.yaml`
- `apps/avorion/container-test.yaml`
- `apps/avorion/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The draft's "work is a USER apps start script, not a build" matches this layout.

## 3. Base image

Runtime image: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` (the image built from `apps/steamcmd`). Its tag and digest are UNVERIFIED: this run did not pull or inspect it. Copy the FROM line from the built steamcmd image once it is published, and keep the ubuntu digest from the brief (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) as the underlying base. Closest sibling: none in `apps/` uses steamcmd as a runtime base (checked: no `apps/*/Dockerfile` has `steamcmd` FROM), so `apps/steamcmd` is the only reference.

## 4. Dockerfile

Plan (only if section 10 blockers are cleared):

1. `FROM <steamcmd base> AS final` with the digest pinned.
2. `ARG VERSION` (decision in section 10).
3. `USER root` only if directories must be created: `install -d -o apps -g apps /config`. The steamcmd base already sets `/config` owned by `apps`.
4. No apt install (SteamCMD and 32-bit libs come from the base).
5. `COPY --chmod=0755 start.sh /start.sh` is not needed: the base's `COPY --chmod=0755 . /` covers the `start.sh` in this folder through the allow-list (`include/.dockerignore` lists `start.sh`). Keep `COPY --chmod=0755 . /`.
6. `USER apps`.
7. `EXPOSE 27000/udp 27000/tcp 27020/udp` (only after UNVERIFIED ports are confirmed).
8. `VOLUME /config`.
9. `WORKDIR /config`.
10. `ENTRYPOINT ["/start.sh"]` is not set here: the base image's `/start.sh` runs the SteamCMD wrapper, so our `start.sh` is written to the app folder and copied to `/start.sh` by the base's allow-list copy. Decide the final name and path in the build step; the default is to let our `start.sh` overwrite `/start.sh` with the avorion logic only if the steamcmd base's start is not needed. This needs a read of the base's start.sh and is a blocker (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "avorion"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName for the Avorion build id
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
}
```

Standard four targets and default group copied from `apps/k8s-sidecar/docker-bake.hcl`. Do not run `docker buildx bake --print` with `UNVERIFIED` values: the values must be real before the bake file is committed. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
ports:
  - port: 27000
    protocol: udp
    required: true
  - port: 27000
    protocol: tcp
    required: true
  - port: 27020
    protocol: udp
    required: false
env:
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Ports and env are UNVERIFIED: keep only what is confirmed in section 10 (the steamcmd base's `STEAM_USERNAME`/`STEAM_PASSWORD` are real, from apps/steamcmd/start.sh). Do not list `GAME_*`, `UMASK`, `UID`, `GID` (ich777 names, not read by our start.sh).

## 7. start.sh

Plan, to be confirmed against the Avorion server's launch options (UNVERIFIED):

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config XDG_DATA_HOME=/config
export TMPDIR=/tmp

SERVER_DIR=/config/serverfiles
mkdir -p "${SERVER_DIR}"

# Install or update the dedicated server (app id UNVERIFIED).
/usr/local/bin/steamcmd +force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${AVORION_APPID}" validate +quit

# Seed the default server config only when missing.
if [ ! -s "${SERVER_DIR}/server.ini" ]; then
  : # UNVERIFIED: config file name and default content
fi

cd "${SERVER_DIR}"
exec ./<server binary> <UNVERIFIED launch args>
```

- All writes go to `/config` (game files) and `/tmp` (scratch). Nothing written to `/app`.
- `+login anonymous` for the public server; the steamcmd base handles `STEAM_USERNAME` when set (confirm the base's argument handling before using it, because the base's wrapper builds its own script from env).
- The server binary path, launch args, and config seeding are UNVERIFIED; they must come from the Avorion dedicated-server docs before the script is written. Do not invent them.
- Admin password: the draft says the first start needs an admin password in the server config (UNVERIFIED). Do not set one in the test.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 900
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- `timeoutSeconds` is a guess for a first-run download of the server (UNVERIFIED size). Real runs will show the time: set it from that, not from this value.
- `tcp` and `http` probes need the server running and listening. The first start downloads the server (large download, draft caveat), so the test cannot prove the game port is open inside the default timeout. Do not add a probe that is always true. Options: (a) use a pre-seeded `/config` fixture so the test does not download (needs a checked-in fixture: out of scope unless the user agrees), or (b) keep the test to the file checks above and report the gap honestly in the PR.
- The steamcmd base test lists `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`; keep them, since the base's files are what this app depends on.

## 9. Rootless and read-only-rootfs adaptations

| Upstream (ich777 chart and image) | Remap |
| --- | --- |
| Runs the wrapper as root (chart `runAsUser: 0`) | `USER apps` |
| `/serverdata/serverfiles`, `/serverdata/steamcmd` (PVCs) | `/config/serverfiles` (game), `/config/steamcmd` (base already uses `/config/steamcmd` and `/config/Steam`) |
| `UMASK`, `UID`, `GID`, `DATA_PERM` env | Not used |
| SteamCMD temp (`STEAMCMD_TMP_DIR=/config/steamcmd/tmp` in the base) | Base writes temp under `/config`. Under `--read-only --tmpfs /tmp` that is a rule violation (caches must be in `/tmp`). Blocker: the base's `STEAMCMD_TMP_DIR` must be changed to `/tmp` in `apps/steamcmd`, or the avorion start must override it. Fixing it in `apps/steamcmd` is a separate app change (its own PR). |
| Chart `stdin`/`tty` true | Not used; run detached. |

## 10. Risks, caveats and open questions

Blockers (must be cleared before any Dockerfile is written):

1. The Avorion Steam app id, the server binary, and its launch arguments are UNVERIFIED. Read the Valve wiki page (https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide) and the Avorion server docs first.
2. The Avorion server's ports (27000 udp/tcp, 27020 udp) are UNVERIFIED.
3. The steamcmd base writes SteamCMD temp under `/config` (`STEAMCMD_TMP_DIR`), which breaks the `/tmp` cache rule. Needs a decision: fix the base, or override in this app.
4. The steamcmd base image's tag and digest for `FROM` are not pinned in this run. Pin it after it is built.
5. The Avorion license is UNVERIFIED. The bake `LICENSE` cannot be set until it is read.
6. `VERSION` decision: the Avorion build id (renovate datasource to be picked) or the steamcmd base version. Do not guess.

Other caveats (from the draft, UNVERIFIED): the first start is a large Steam download and needs internet; the galaxy is generated on first start; amd64 only.

No hard `dependencies:` on another ContainerForge app beyond the steamcmd base, which is a `FROM`, not a runtime dependency. The database-dependent exception does not apply.

## 11. Build and test steps

Run only after section 10 blockers are cleared.

```sh
cd apps/avorion
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name avorion-probe --read-only --tmpfs /tmp \
  -v avorion-probe-config:/config avorion:<VERSION>
docker logs -f avorion-probe
forgetool containers test --image avorion:<VERSION> --config ./apps/avorion/container-test.yaml
docker rm -f avorion-probe; docker volume rm avorion-probe-config
```

Readiness signal: SteamCMD reports the app id install as successful, then the server logs its listen message (text UNVERIFIED). The first run will be long; capture the real time and set `timeoutSeconds` from it.

## 12. PR checklist

- Branch `feat/add-avorion`, commit and PR title `feat(avorion): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- State honestly what is untested: the full server download and game port probe, arm64 (not applicable: amd64 only), and any blocker above that stays open.
- Note the steamcmd base temp-path fix as a separate PR, if chosen.
