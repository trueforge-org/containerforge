# vintage-story — implementation plan
> Source: ./draft.md · Target: apps/vintage-story/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.22.7 (vendor stable channel, `http://api.vintagestory.at/stable.json`, first key). Release date: UNVERIFIED (not in the API response). Draft tag `latest` is not a version; pin 1.22.7. |
| Renovate | UNVERIFIED: vendor JSON API has no renovate datasource. Proposed `// renovate: datasource=custom.vintagestory depName=vintagestory versioning=semver` needs a custom manager; confirm against an existing sibling that tracks a non-GitHub vendor before using it. |
| License | UNVERIFIED: closed-source server; no SPDX license on the vendor pages fetched. Use `LICENSE` = `LicenseRef-Proprietary` only after confirmation. |
| Source URL | https://www.vintagestory.at/ (website); upstream packager https://github.com/ich777/docker-vintage-story |
| Download (amd64) | https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_1.22.7.tar.gz (from `stable.json` `.linuxserver.urls.cdn`). Mirror: https://account.vintagestory.at/files/stable/vs_server_linux-x64_1.22.7.tar.gz |
| arm64 download | None. `stable.json` lists no Linux arm64 build (only `mac-arm64`, a client). |
| Checksum source | UNVERIFIED: no checksum in the API response or on the pages fetched. Do not invent one; record the tarball's sha256 at build time and document it in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-vintage-story/master/Dockerfile: base `ich777/mono-baseimage`; apt `dotnet-runtime-10.0` (plus curl, screen, jq); ENV `DATA_DIR=/vintagestory`, `VS_CHANNEL=stable`, `STATIC_V`, `GAME_PARAMS`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=vintagestory`; `ENTRYPOINT ["/opt/scripts/start.sh"]`. No EXPOSE, VOLUME, CMD or USER. |
| Upstream start script reviewed | `scripts/start.sh` (gh api): reads `api.vintagestory.at/${VS_CHANNEL}.json`, downloads the CDN tarball into `${DATA_DIR}`, extracts it, writes `installed-<version>`, runs `chmod -R ${DATA_PERM}`, starts the server under `screen` with `--dataPath ${DATA_DIR}/data`. The Linux launcher (`scripts/start-server.sh`) was not read in full: UNVERIFIED. |
| Ports | 42420 (game). Default `"Port": 42420` in `serverconfig.json` (https://wiki.vintagestory.at/index.php/Server_Config). Protocol TCP vs UDP: UNVERIFIED (wiki does not state it). The draft's inferred TCP+UDP is not confirmed. |
| Env vars (real) | `VS_CHANNEL` (`stable`), `STATIC_V` (pin version, empty = latest), `GAME_PARAMS` (extra server args), `DATA_DIR`, `DATA_PERM`, `UMASK`, `UID`, `GID`, `USER` (ich777 wrapper variables; not vendor settings). Vendor config lives in `serverconfig.json`. |
| Data path | Vendor: `--dataPath` (confirmed by upstream start script, Windows/mono branch). Config `serverconfig.json` and `WorldConfig.SaveFileLocation` (Linux default `/home/user/.config/VintagestoryData/Saves/default.vcdbs`). Exact `serverconfig.json` directory under dataPath: UNVERIFIED. |
| apt on Ubuntu 26.04 (resolute) | `dotnet-runtime-10.0` 10.0.14-0ubuntu1~26.04.1 for amd64 and arm64 (https://packages.ubuntu.com/resolute/dotnet-runtime-10.0). |
| Dependencies | None (no database; SQLite world files are the vendor's). |

## 2. Target layout

- `apps/vintage-story/Dockerfile`
- `apps/vintage-story/docker-bake.hcl`
- `apps/vintage-story/settings.yaml`
- `apps/vintage-story/container-test.yaml`
- `apps/vintage-story/start.sh` (downloads and extracts the server into `/config` on first start)

No `defaults/` needed unless a default `serverconfig.json` is shipped; if added, place it in `defaults/` (allow-listed by `include/.dockerignore`). No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. Ubuntu alone is enough: `dotnet-runtime-10.0` is in the 26.04 archive, so no separate runtime image is needed. Closest sibling for a dotnet-on-ubuntu layout: `apps/webgrabplus`.

## 4. Dockerfile

1. `FROM <ubuntu> ` (single stage; no build stage needed, the server is a downloaded tarball).
2. `USER root`, then `apt-get update && apt-get install -y --no-install-recommends dotnet-runtime-10.0` and `rm -rf /var/lib/apt/lists/*`. The `start.sh` snippet needs `curl`, `jq` and `tar`; check which the base already has (`apps/ubuntu/Dockerfile`) and install `jq` if missing (UNVERIFIED).
3. `ARG VERSION` matching `docker-bake.hcl`; `ENV VS_CHANNEL=stable STATIC_V=""` as defaults for `start.sh`.
4. Install the license notice: `/usr/share/licenses/vintage-story/` only if a vendor license file is available; otherwise record the vendor EULA reference in the PR (UNVERIFIED that a license file is shipped in the tarball).
5. Create no server files at build time. The server is downloaded to `/config` at start (read-only `/app` rule).
6. `COPY --chmod=0755 . /` then `USER apps`.
7. `EXPOSE 42420` and `VOLUME /config`. `ENV HOME=/tmp` only if the server writes to `$HOME`; otherwise leave it.

Key snippet for `start.sh`'s version selection (to mirror upstream, not to copy blindly):

```sh
json="$(curl -fsSL "http://api.vintagestory.at/${VS_CHANNEL:-stable}.json")"
latest="$(printf '%s' "$json" | jq -r 'keys_unsorted[0]')"
version="${STATIC_V:-$latest}"
url="$(printf '%s' "$json" | jq -r --arg v "$version" '.[$v].linuxserver.urls.cdn')"
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "vintage-story"
}

variable "VERSION" {
  // renovate: datasource=custom.vintagestory depName=vintagestory versioning=semver
  default = "1.22.7"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.vintagestory.at/"
}

group "default" {
  targets = ["image-local"]
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync`. `image-all` platforms: `linux/amd64` only (no arm64 build exists; see section 10). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.vintagestory.at/"
ports:
  - port: 42420
    protocol: UNVERIFIED   # tcp or udp: confirm against vendor docs before setting
    required: true
env:
  - name: VS_CHANNEL
    default: "stable"
    required: false
  - name: STATIC_V
    default: ""
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only variables that `start.sh` actually reads are listed. Do not list `UID`, `GID`, `UMASK`, `DATA_PERM`: they are ich777 wrapper options with no effect in ContainerForge. `dependencies: []` (none).

## 7. start.sh

- `set -euo pipefail`; `DATA="/config/vintagestory"`; `mkdir -p "$DATA/data"`.
- Version logic as in section 4 snippet. If `DL_URL` empty and no local install: exit with a clear error (no `sleep infinity`).
- Download only when `$DATA/installed-$version` is missing, into `/tmp` first (`/tmp/vs-$version.tar.gz`), extract into `$DATA`, `rm` the tarball, `touch installed-$version`. Never write into `/app`.
- Seed nothing else; do not overwrite an existing `serverconfig.json` under `$DATA/data`.
- Launch: `cd "$DATA"` then `exec <server-binary> --dataPath "$DATA/data" ${GAME_PARAMS}`. The Linux binary name and whether it needs `dotnet` as launcher are UNVERIFIED (read `start-server.sh` from ich777 and the tarball file list before writing this line).
- Bind: the server listens on all interfaces by default (`"Ip": null`, wiki). Confirm with a probe after start, not by assumption.
- Final process: `exec` so the server is PID 1 under tini/dumb-init.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
```

Then probes: one `tcp` probe to port 42420 (or `udp`, per the verified protocol) with `timeoutSeconds` set UNVERIFIED (no sibling game server sets a reference value; `apps/steamcmd/container-test.yaml` has none). `filePaths`: `/start.sh`. Note: the test runs with no internet access guarantee, so a first-start download may not complete in CI; if the test cannot pass without network, narrow the test to the start script and config seeding and document it in the PR (per the protocol's narrow exception only if all three criteria hold; here there is no DB, so the exception does NOT apply, and a real network dependency must be stated, not hidden).

## 9. Rootless and read-only-rootfs adaptations

- Upstream: runs as root in the chart (`runAsUser 0`, `runAsGroup 0`), `readOnlyRootFilesystem: false`, `privileged` unset (false), extra persistence `/vintagestory` (chart path). Expectations, to verify, not guarantees.
- Adaptation: `USER apps` in the final stage; all writes to `/config` (server and world) and `/tmp` (downloads). `/vintagestory` (chart path) maps to `/config/vintagestory` in ContainerForge.
- `--read-only --tmpfs /tmp` test must pass with an empty `/config`: the download needs internet and `/tmp` space (about 51 MB tarball, larger after extraction; size of the extracted server UNVERIFIED).
- No `privileged`, no capabilities needed (game port above 1024).

## 10. Risks, caveats and open questions

- amd64 only: no vendor arm64 build. arm64 not possible; `image-all` is amd64 only.
- Runtime download from vintagestory.at: the first start needs internet; air-gapped clusters cannot start the server. Record in `settings.yaml` description or the PR.
- Version pinning: `STATIC_V` default is empty (follow latest). Renovate tracks `VERSION` in bake; the runtime download uses the vendor's latest unless `STATIC_V` is set. Document the mismatch in the PR so the image version and the runtime version are not confused.
- Port protocol (TCP vs UDP) for 42420 is unverified. Do not set `protocol` in `settings.yaml` until confirmed.
- Linux launcher and `serverconfig.json` location under dataPath are unverified (section 1).
- Blockers: no arm64; first start needs internet; closed-source EULA needs a license decision before `LICENSE` is set.

## 11. Build and test steps

```sh
cd apps/vintage-story
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name vintage-story-probe --read-only --tmpfs /tmp \
  -v vintage-story-probe-config:/config vintage-story:1.22.7
docker logs -f vintage-story-probe
docker rm -f vintage-story-probe; docker volume rm vintage-story-probe-config
forgetool containers test --image vintage-story:1.22.7 --config ./apps/vintage-story/container-test.yaml
```

Expected readiness signal: the server log reports the listening port (wording UNVERIFIED until a real run) and the container keeps running. Empty `/config` must be tested on every round.

## 12. PR checklist

- Branch `feat/add-vintage-story`; commit `feat(vintage-story): add new container`; target `main`.
- PR title matches the commit. Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what is untested: arm64 (not built), first-start network download, and any assertion that could not be verified locally.
