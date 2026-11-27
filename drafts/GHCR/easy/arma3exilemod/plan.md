# arma3exilemod — implementation plan
> Source: ./draft.md · Target: apps/arma3exilemod/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No pinned game version: the server is installed from Steam at start. Steam app id **233780** (Arma 3 dedicated server; `GAME_ID "233780"` in https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3exilemod/values.yaml). Chart image: `ghcr.io/ich777/steamcmd:arma3exilemod@sha256:c664f8b47d669e3893f767f099c62792a070f295e52d7610dcd6a5391ea13994`. |
| Renovate | Base steamcmd only: `apps/steamcmd` uses `datasource=deb depName=steamcmd`. The game and ExileMod are not pinned. |
| License | Image LICENSE: open question (section 10). ExileMod is a third-party community mod; its license is UNVERIFIED. The Arma 3 server is commercial (EULA, not fetched: UNVERIFIED). |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (draft link). The ExileMod source is UNVERIFIED (not in the fetched chart or upstream files). |
| Download | Same as arma3: the server via SteamCMD (`+app_update 233780`); steamcmd tarball https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz (HTTP 200). The ExileMod files are **not** in the image and the chart sets `EXILEMOD_SERVER_URL` = http://www.exilemod.com/ExileServer-1.0.4a.zip (chart values.yaml; zip not fetched). |
| Checksum source | None published (UNVERIFIED). |
| Upstream Dockerfile reviewed | Same as arma3: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile and `scripts/start.sh` (Source engine `srcds_run`, not Arma 3). |
| Chart-bundled MariaDB | The chart exposes port **3306** (`mariadb`-style) and sets env `MARIA_DB_ROOT_PWD` (placeholder value `ExileMod` in values.yaml line 103). The fetched upstream image files do not show a MariaDB process: UNVERIFIED whether the image itself runs one. |
| Ports (chart) | 2302 (game), 2303, 2304, 2305 (`udpvonport`), 2306, plus 3306 (tcp, MariaDB). |
| Data paths (chart) | `/serverdata/.local/share`, `/serverdata/serverfiles`, `/serverdata/steamcmd`. |
| Arch | amd64 yes; arm64 no (Docker Hub `ich777/steamcmd` tag `arma3exilemod` is amd64 only, last pushed 2024-12-19: https://hub.docker.com/v2/repositories/ich777/steamcmd/tags/?page_size=100&name=arma3exilemod). |
| copy-from | amd64: `ghcr.io/ich777/steamcmd:arma3exilemod` (not used). arm64: no. |
| Server binary and launch line | UNVERIFIED (as arma3): Arma 3 Linux binary name and arguments not fetched from https://community.bistudio.com/wiki/Arma_3_Dedicated_Server. |

## 2. Target layout

- `apps/arma3exilemod/Dockerfile`
- `apps/arma3exilemod/docker-bake.hcl`
- `apps/arma3exilemod/settings.yaml`
- `apps/arma3exilemod/container-test.yaml`
- `apps/arma3exilemod/start.sh` (install and launch; same design as `apps/arma3`)
- `apps/arma3exilemod/defaults/server.cfg` (seeded only when missing)

`defaults/server.cfg` holds only the base server config; ExileMod files are not shipped (see section 10). No `root/`, no `DOWNSTREAM_CHANGES.md`.

Reuse: build this app from `apps/arma3` once that plan is implemented, and keep the two `start.sh` files the same except for the Exile-specific steps.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<UNVERIFIED: digest of the published steamcmd image>`

Why: same as arma3. The steamcmd base provides the 32-bit steamcmd, `USER apps`, `/config`, and the install wrapper. Closest sibling: `apps/steamcmd` (base) and the planned `apps/arma3` (same game, same start path).

## 4. Dockerfile

Same as the arma3 plan (section 4 there):

```dockerfile
ARG VERSION
COPY --chmod=0755 start.sh /start.sh
COPY --chmod=0644 defaults/server.cfg /defaults/server.cfg
USER apps
COPY --chmod=0755 . /
EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp
VOLUME /config
ENTRYPOINT ["/start.sh"]
```

Add `3306/tcp` to `EXPOSE` **only if** the decision in section 10 keeps MariaDB in this container. If MariaDB moves to `apps/mariadb` (recommended below), do not expose 3306 here.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "arma3exilemod" }

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" { default = "LicenseRef-Arma3-EULA" }   // open question, section 10
variable "SOURCE" { default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide" }
```

- Four standard targets and `group "default" { targets = ["image-local"] }`. `image-all` platforms: `linux/amd64` only.
- Validate with `docker buildx bake --print` from `apps/arma3exilemod/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
ports:
  - port: 2302
    protocol: udp
    required: true
  - port: 2303
    protocol: udp
    required: false
  - port: 2304
    protocol: udp
    required: false
  - port: 2305
    protocol: udp
    required: false
  - port: 2306
    protocol: udp
    required: false
env:
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: STEAM_APP_IDS
    default: "233780"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mariadb   # recommended, see section 10; remove if the decision is to bundle
```

- Do not invent env vars: the chart's `MARIA_DB_ROOT_PWD` belongs to the bundled MariaDB. If MariaDB is a separate dependency, the Exile database settings are the ones `apps/mariadb` already defines (`MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD`, port 3306 in https://github.com/trueforge-org/containerforge/blob/main/apps/mariadb/settings.yaml). The Exile server's own DB env names are UNVERIFIED and must be taken from the ExileMod docs before they are listed here.

## 7. start.sh

Same shape as `apps/arma3/start.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
ARMA_DIR="/config/arma3exilemod"
mkdir -p "${ARMA_DIR}"

[ -f "${ARMA_DIR}/server.cfg" ] || cp /defaults/server.cfg "${ARMA_DIR}/server.cfg"

STEAMCMD_PRE_UPDATE=false STEAM_INSTALL_DIR="${ARMA_DIR}" \
  /start.sh +force_install_dir "${ARMA_DIR}" +login anonymous +app_update 233780 +quit

# ExileMod install step: UNVERIFIED source (section 10). Only add when the source is confirmed.

cd "${ARMA_DIR}"
exec ./arma3server_x64 -config=server.cfg -port=2302   # binary name and flags: UNVERIFIED
```

- UNVERIFIED / needs human: this app's `start.sh` is copied to `/start.sh` and so replaces the steamcmd base's `/start.sh` (`apps/steamcmd/start.sh`, which bootstraps `/config/Steam/steamcmd` and handles `STEAM_APP_IDS`); the line above that calls `/start.sh` would then call itself. Rename the script (and keep the `COPY . /` allow-list in mind) or call `/config/Steam/steamcmd/steamcmd.sh` directly after the bootstrap. `apps/arma3` does not exist yet, so its plan is not a precedent.
- Idempotent: seeds files only when missing; reinstalls via steamcmd each start (as the base does); no writes to `/app`.
- If MariaDB is an external dependency, the start script waits for it (for example a TCP check on the DB host and port from env) and applies DB passwords from env on every start (start-script rule). Do this only after the DB env names are verified.
- `exec` the final server process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 1800   # first start downloads the server; size and time UNVERIFIED
udp:                   # forgetool udp probe support: UNVERIFIED
- port: '2302'
filePaths:
- /start.sh
- /defaults/server.cfg
```

- Every settings.yaml port should have a probe; UDP-only game ports need forgetool udp support (UNVERIFIED). See arma3 section 8.
- If MariaDB is a hard dependency (`dependencies:` in settings.yaml), the protocol's **database-dependent exception** can apply: the test may narrow to smoke assertions (process running, port open, file exists, startup line in logs), with the required comment `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`. Do not disable the test.
- The test runs without env vars, so the ExileMod and DB code paths are not exercised; put their files in `filePaths`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream / chart write path | Remap in this plan |
| --- | --- |
| `/serverdata/.local/share` (profiles pvc) | `XDG_DATA_HOME=/config`. |
| `/serverdata/serverfiles`, `/serverdata/steamcmd` | `/config/arma3exilemod` (server), `/config/Steam/steamcmd` (base). |
| SteamCMD temp | `/config/steamcmd/tmp` (base design; deviation from the `/tmp` cache rule, see arma3 section 7). |
| Chart `runAsUser 0` | `USER apps`. |
| Chart `MariaDB` data directory | Not in this image. If bundled anyway, its data dir must be under `/config`, not `/app` (UNVERIFIED need). |

Draft expectations reconciled: non-root yes (`apps`), read-only-rootfs possible with `--tmpfs /tmp` (steamcmd writes stay in `/config`), not privileged. The chart's bundled MariaDB (port 3306, root password env) is the main security concern: it should not run as root in this image, and the root password must come from a secret, not the placeholder `ExileMod`.

## 10. Risks, caveats and open questions

- **Decision needed: MariaDB.** The draft says "Dependency containers: none", but the chart bundles MariaDB (port 3306, `MARIA_DB_ROOT_PWD`). Options:
  1. (Recommended) Declare `apps/mariadb` as a hard dependency (`dependencies: [mariadb]`), so this image stays a single game server and the database is ContainerForge's own app. This triggers the protocol's DB-dependent exception (section 8).
  2. Bundle MariaDB in this image. This needs a process supervisor, a DB data dir under `/config`, and its own user. It is harder to make rootless and read-only, and the draft's "no dependencies" would stay wrong.
- **ExileMod files**: the image does not contain them and the chart gives no install source. The source, version and license are UNVERIFIED. Until confirmed, the image can only run the base Arma 3 server, which is not ExileMod.
- **Image LICENSE**: same open question as arma3 (`LicenseRef-Arma3-EULA` proposed). ExileMod license UNVERIFIED.
- **Unpinned game and mod**: both install at runtime from Steam or vendor sources, so builds are not reproducible.
- **First-start size and time**: large downloads; CI timeout must be checked.
- **Server binary and launch args**: UNVERIFIED (as arma3).
- **Port protocols**: UDP per the chart's game ports is inferred; confirm.
- **Blockers**: amd64 only; ExileMod source UNVERIFIED; the DB decision above.

## 11. Build and test steps

```sh
cd apps/arma3exilemod
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name arma3exilemod-probe --read-only --tmpfs /tmp \
  -v arma3exilemod-probe-config:/config arma3exilemod:20180105-5build1
docker logs -f arma3exilemod-probe
forgetool containers test --image arma3exilemod:20180105-5build1 --config ./apps/arma3exilemod/container-test.yaml
docker rm -f arma3exilemod-probe; docker volume rm arma3exilemod-probe-config
```

- Readiness signal: steamcmd reports `Success! App '233780' fully installed`, then the server's own startup line (UNVERIFIED text). With a hard `mariadb` dependency, `docker-compose`-style dependency wiring is not available in the single-container test: use the narrowed smoke assertions and note it in the PR.
- Empty `/config` must work; a restart with the same volume must reuse the install.

## 12. PR checklist

- Branch `feat/add-arma3exilemod`, commit and PR title `feat(arma3exilemod): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows status.
- State what is not tested: a full ExileMod server with a database and a client connection.
- `docker buildx bake --print` passes; `VERSION` equals `ARG VERSION`; the steamcmd base digest is filled in from the published image; the MariaDB decision is recorded in the PR.
- Downstream: not a FROM base, so no `DOWNSTREAM_CHANGES.md`.
