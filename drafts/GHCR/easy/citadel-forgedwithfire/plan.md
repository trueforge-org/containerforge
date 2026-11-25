# citadel-forgedwithfire — implementation plan
> Source: ./draft.md · Target: apps/citadel-forgedwithfire/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No upstream release. Steam dedicated server (app `489650`) is downloaded at start, so the version is whatever Steam serves; base pinned by `apps/steamcmd` VERSION `20180105-5build1`. Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/citadel-forgedwithfire/values.yaml |
| Draft tag | Draft does not name a version. Chart runs `ghcr.io/ich777/steamcmd:citadelfwf@sha256:bcf40be84f6d98cb12a200e838ca01beb7dbd13842d6716c62673b8e1d12eb8d` (same chart URL). |
| Renovate | Base only: `datasource=deb depName=steamcmd` (from `apps/steamcmd/docker-bake.hcl`). Game version is a Steam build, not tracked. |
| License | Game is closed-source (Steam EULA). Base wrapper `apps/steamcmd` is AGPL-3.0-or-later. LICENSE needs a decision (section 10). |
| Source URL | Steam store API `https://store.steampowered.com/api/appdetails?appids=489650` returned `success: false`. UNVERIFIED on Steam side. |
| Per-arch download | amd64 only: SteamCMD bootstrap is 32-bit x86. arm64 not available. |
| Checksum source | None published for the Steam server. SteamCMD tarball fetched by upstream from `http://media.steampowered.com/client/steamcmd_linux.tar.gz` (no checksum). Base installs `steamcmd` from Ubuntu apt. |
| Upstream wrapper | Tag branch `citadelfwf` of https://github.com/ich777/docker-steamcmd-server (last commit 2022-10-25). Dockerfile and scripts layout the same as `chivalrymw`: `FROM ich777/debian-baseimage`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. Confirmed via https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=citadelfwf (branch list via https://api.github.com/repos/ich777/docker-steamcmd-server/branches) |
| Upstream start-server | `citadelfwf` `scripts/start-server.sh`: `+force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate] +quit`, `export LD_LIBRARY_PATH="${SERVER_DIR}/linux64/:$LD_LIBRARY_PATH"`, `cd ${SERVER_DIR}`, then `${SERVER_DIR}/Citadel/Binaries/Linux/CitadelServer-Linux-Shipping ${GAME_PARAMS}`. Source: https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=citadelfwf |
| Env (chart, real) | `GAME_ID="489650 "` (trailing space in chart; trim it), `GAME_PARAMS=""`, `VALIDATE="false"`, `USERNAME=""`, `PASSWRD` (secret). Source: chart values URL above. |
| Ports (chart, real) | udp 7777 (main), udp 27015 (queryport). Source: chart values URL above. |
| Security (chart) | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`; persistence `/serverdata/serverfiles`, `/serverdata/steamcmd`. Source: chart values URL above. |
| Dependencies | None. |
| Blockers | arm64 unsupported. UDP forwarding needed. Steam download on every start. |

Draft corrections: the draft's ports `7777` and `27015` (udp, marked inferred) are confirmed by the chart. The draft's steamcmd `apt` route is superseded by `apps/steamcmd`.

## 2. Target layout

- `apps/citadel-forgedwithfire/Dockerfile`
- `apps/citadel-forgedwithfire/docker-bake.hcl`
- `apps/citadel-forgedwithfire/settings.yaml`
- `apps/citadel-forgedwithfire/container-test.yaml`
- `apps/citadel-forgedwithfire/start.sh`

No `defaults/`, `etc/`, `scripts/`, `health/`, no `root/`, no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>`, `<VERSION>` = `20180105-5build1` (from `apps/steamcmd`). Digest read at build time with `docker buildx imagetools inspect` (UNVERIFIED here). Fits: base provides SteamCMD under `/usr/local/share/steamcmd`, the `steamcmd` wrapper and `/config` owned by `apps`. Closest sibling: `apps/steamcmd`, and `apps/chivalry-medievalwarfare` (same steamcmd family, same plan).

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>`; `ARG VERSION`, `ARG VENDOR`.
2. No apt installs (base already ships SteamCMD and its i386 support).
3. `COPY --chmod=0755 start.sh /start.sh`. UNVERIFIED design flaw to resolve: this overwrites the base image's `/start.sh` (the SteamCMD wrapper that `/usr/local/bin/steamcmd` execs), so the plan's `start.sh` must reimplement the SteamCMD seeding (step 2 of section 7) or use a different file name.
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `EXPOSE 7777/udp 27015/udp`, `VOLUME /config` (the `apps/steamcmd` Dockerfile has no `VOLUME`), `ENV HOME=/config` (the base sets none).
6. No build stage and no downloads. `VERSION` in bake tracks the base.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "citadel-forgedwithfire"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/search/?term=Citadel+Forged+with+Fire"
}
```

Four standard targets and the default group copied from `apps/steamcmd/docker-bake.hcl`; `image-all` `platforms = ["linux/amd64"]`. Validate with `docker buildx bake --print`. `SOURCE` uses the draft's store search link because no Steam app page was confirmed (UNVERIFIED); switch to `https://store.steampowered.com/app/489650/` once confirmed.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/search/?term=Citadel+Forged+with+Fire"
ports:
  - port: 7777
    protocol: udp
    required: true
  - port: 27015
    protocol: udp
    required: false
env:
  - name: GAME_ID
    default: "489650"
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: VALIDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. `GAME_ID` is written without the chart's trailing space. The chart's `PASSWRD` secret is not listed because `start.sh` does not read it (section 7 step 6). Do not list env vars the app does not read.

## 7. start.sh

Plan (idempotent, empty `/config` safe, writes only under `/config` and `/tmp`):

1. `set -euo pipefail`; `export HOME=/config`; `SERVER_DIR=/config/serverfiles`; `GAME_ID="${GAME_ID//[[:space:]]/}"` (trim, as chart value has a trailing space); validate it is numeric.
2. Seed SteamCMD into `/config/Steam/steamcmd` only when missing, same as `apps/steamcmd/start.sh`.
3. `mkdir -p "${SERVER_DIR}"`; run `steamcmd +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate] +quit`. Anonymous login only, as upstream does when `USERNAME` is empty; `USERNAME` is not exposed in this plan (no secret handling).
4. `export LD_LIBRARY_PATH="${SERVER_DIR}/linux64/:${LD_LIBRARY_PATH:-}"`.
5. `cd "${SERVER_DIR}"`; `exec "${SERVER_DIR}/Citadel/Binaries/Linux/CitadelServer-Linux-Shipping" ${GAME_PARAMS}` (`exec` so signals reach the server).
6. Password: the chart passes `PASSWRD`, but the upstream start script does not use it for the server launch; do not invent a flag. UNVERIFIED how the game reads `PASSWRD`. Leave it out of the command.
7. Bind address and port: the server uses UDP 7777 and 27015 per the chart; confirm the listen address in the test run (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

Probe gap: both ports are UDP, and the repo's test primitives are `tcp` and `http`. No port probe can run for either port. The UDP case is UNVERIFIED for forgetool (check the schema for a `udp` key before the run). The full Steam download is not part of CI, so the readiness check is manual (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (chart PVC) | `/config/Steam/steamcmd` (base behaviour). |
| `/serverdata/serverfiles` (chart PVC) | `/config/serverfiles`. |
| `chmod -R ${DATA_PERM} ${DATA_DIR}` upstream | Not needed; image runs as `apps`, `/config` owned by `apps`. |
| `/opt/scripts` (ich777 wrapper) | Not used; replaced by `/start.sh`. |
| SteamCMD caches | `HOME=/config` from base; UNVERIFIED which SteamCMD cache path can be moved to `/tmp`. |

Security reconciliation: chart expects `runAsUser: 0` and `readOnlyRootFilesystem: false`. The plan runs as `USER apps` and writes only to `/config` and `/tmp`, so `--read-only --tmpfs /tmp` should work. Not privileged. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- **Steam app ID**: `489650` is from the chart. Steam store API returned no data, so it is UNVERIFIED on Steam itself.
- **Launch binary**: `Citadel/Binaries/Linux/CitadelServer-Linux-Shipping` is from upstream `start-server.sh` (`citadelfwf`), not from a running test. UNVERIFIED that the current build keeps the path.
- **Password**: `PASSWRD` handling is UNVERIFIED (no upstream flag found). Not wired in this plan.
- **First start**: Steam download of the full server; slow, needs internet access. Each start re-checks Steam.
- **UDP**: the host must forward UDP (7777 and 27015), not only TCP.
- **arm64**: SteamCMD's 32-bit bootstrap does not run on arm64; `image-all` is amd64 only.
- **LICENSE**: proprietary game, AGPL-3.0-or-later base wrapper. Decide the bake `LICENSE` value (proposal `LicenseRef-Proprietary`); UNVERIFIED against project policy.
- **Draft's `apt steamcmd` route**: superseded by the base image; no apt install in the plan.

## 11. Build and test steps

From `apps/citadel-forgedwithfire`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty config: `docker run --rm -d --name citadel-probe --read-only --tmpfs /tmp -v citadel-probe-config:/config -e GAME_ID=489650 citadel-forgedwithfire:<VERSION>`, then `docker logs -f citadel-probe`. Pass signal: the Steam install completes (`Success! App '489650' fully installed.`) and the server process stays up with no fatal line from `start.sh`. Record how long the download takes.
4. Cleanup: `docker rm -f citadel-probe; docker volume rm citadel-probe-config`.
5. `forgetool containers test --image citadel-forgedwithfire:<VERSION> --config ./container-test.yaml` (or by-hand checks if forgetool is missing).

## 12. PR checklist

- Branch `feat/add-citadel-forgedwithfire`, commit `feat(citadel-forgedwithfire): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; tick only what applies.
- Notes section has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: full Steam download, UDP probes, the `PASSWRD` path, and every UNVERIFIED item above.
- Do not tick "Built container locally" unless the bake and build actually ran.
