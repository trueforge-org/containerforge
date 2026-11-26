# storj-node — implementation plan
> Source: ./draft.md · Target: apps/storj-node/ · Difficulty: easy to build, hard to test (needs a node identity) · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.166.4` (GitHub release `v1.166.4`, 15 Nov; the draft's version). As of 2026-11-26 the latest stable is `v1.167.1` (25 Nov, marked Latest; its candidate was `v1.167.1-rc`), so `v1.166.4` is one release behind. The version server suggests `1.166.4` (minimum `1.164.2`). |
| Renovate | `datasource=github-releases depName=storj/storj versioning=semver extractVersion=^v(?<version>.+)$`. The `-rc` releases are flagged "prerelease" on GitHub (checked v1.167.1-rc, v1.167.0-rc, v1.166.0-rc), which Renovate ignores by default. |
| License | AGPL-3.0 (repo LICENSE is "GNU AFFERO GENERAL PUBLIC LICENSE Version 3"). SPDX `AGPL-3.0-only` (UNVERIFIED whether "or later"). |
| Source URL | https://github.com/storj/storj/ |
| Download (amd64) | https://github.com/storj/storj/releases/download/v1.166.4/storagenode_linux_amd64.zip (HTTP 206 checked) |
| Download (arm64) | https://github.com/storj/storj/releases/download/v1.166.4/storagenode_linux_arm64.zip (HTTP 206 checked) |
| Draft links | The draft links `identity_linux_*.zip`, which is the **identity generator**, not the node. The node is `storagenode_linux_<arch>.zip`. Both exist per arch. |
| Archive content | Each zip holds one file: `storagenode` (about 101 MB; amd64) or `identity` (about 69 MB; amd64). No LICENSE inside. |
| Checksum source | **None found.** The release has no checksums file (assets are only zips). Cross-check of the zips as observed on 2026-11-24 (not an upstream source): `storagenode_linux_amd64.zip` sha256 `cc4897d06990d25d6ba9af9f9c0f0756941211bc441e3550f9909548300ba7d9`, `identity_linux_amd64.zip` sha256 `605717adb2af3deacff100e5a980809aa5ea6b2f26a664d579a398700f249f90`. Mark checksum verification UNVERIFIED in the PR (downloads come over TLS from the release); do not pin these hashes in the Dockerfile because they break Renovate bumps. |
| Upstream Dockerfile | https://github.com/storj/storagenode-docker/blob/main/Dockerfile reviewed: `debian:bookworm-slim` with `supervisor unzip wget ca-certificates`, `EXPOSE 28967`, `EXPOSE 14002`, `WORKDIR /app`, `ENTRYPOINT ["/entrypoint"]`, `ENV ADDRESS="" EMAIL="" WALLET="" STORAGE="2.0TB" SETUP="false" AUTO_UPDATE="true" LOG_LEVEL="" BINARY_STORE_DIR="/app/config/bin"`. The binary is downloaded at container start from the version server and kept in `/app/config/bin`. |
| Upstream entrypoint | https://raw.githubusercontent.com/storj/storagenode-docker/main/docker/entrypoint reviewed. Runs `storagenode run --config-dir config --identity-dir identity [--storage.allocated-disk-space=$STORAGE] [--contact.external-address=$ADDRESS] [--operator.email=$EMAIL] [--operator.wallet=$WALLET] [--log.level=$LOG_LEVEL]`; `SETUP=true` runs `storagenode setup` with the same flags instead; `STORJ_CONSOLE_ADDRESS` defaults to `0.0.0.0:14002`. Supervisor also runs `storagenode-updater` when `AUTO_UPDATE=true`. |
| Ports | 28967/tcp and 28967/udp (node public port), 14002/http (dashboard, `STORJ_CONSOLE_ADDRESS`). The private API port is localhost-only and not exposed. |
| Paths | Upstream: config at `/app/config`, identity at `/app/identity` (both volumes, from the chart), storage at `<config>/storage`. |
| Env (upstream image) | `ADDRESS`, `EMAIL`, `WALLET`, `STORAGE` (2.0TB), `SETUP`, `AUTO_UPDATE`, `LOG_LEVEL`, `STORJ_CONSOLE_ADDRESS`, `VERSION_SERVER_URL` (default https://version.storj.io), `RUN_PARAMS`. `STORJ_<FLAG>` environment mapping is evidenced by `STORJ_CONSOLE_ADDRESS` in the entrypoint. |

## 2. Target layout

```
apps/storj-node/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
`unzip` is already in `apps/ubuntu` so no apt packages. No `defaults/`, `etc/` or `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: the Go binaries are static enough for glibc (upstream runs them on Debian), and ubuntu already has `unzip`, `ca-certificates` and `curl` (checked in `apps/ubuntu/Dockerfile`). Closest sibling: `apps/adguardhome-sync` (release download, `/app`, `exec` start.sh). Unlike the upstream image there is no supervisor, no updater, and the binaries are baked in at build time.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `ARG TARGETARCH` (values `amd64`/`arm64` match upstream names, no mapping).
2. `USER root`, one RUN:
   ```sh
   base="https://github.com/storj/storj/releases/download/v${VERSION}"
   for bin in storagenode identity; do
     curl -fsSL -o "/tmp/${bin}.zip" "${base}/${bin}_linux_${TARGETARCH}.zip"
     unzip -o "/tmp/${bin}.zip" -d /app
   done
   chmod 0755 /app/storagenode /app/identity
   mkdir -p /usr/share/licenses/storj-node
   curl -fsSL -o /usr/share/licenses/storj-node/LICENSE "https://raw.githubusercontent.com/storj/storj/v${VERSION}/LICENSE"
   chown -R apps:apps /app && chmod -R 755 /app
   rm -rf /tmp/*
   ```
   No upstream checksum exists (section 1), so say so in a comment. `identity` is shipped so users can create their identity with the same image (`docker run --entrypoint /app/identity ... create storagenode`).
3. `ENV HOME=/config`.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 28967/tcp 28967/udp 14002`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP = "storj-node"`
- `VERSION` preceded by `// renovate: datasource=github-releases depName=storj/storj versioning=semver extractVersion=^v(?<version>.+)$`, default `"1.166.4"`
- `LICENSE = "AGPL-3.0-only"`, `SOURCE = "https://github.com/storj/storj/"`
- Targets: `docker-metadata-action`, `image` (args.VERSION, OCI source and licenses labels), `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/storj/storj/"
ports:
  - port: 28967
    protocol: tcp
    required: true
  - port: 28967
    protocol: udp
    required: true
  - port: 14002
    protocol: tcp
    required: false
env:
  - {name: ADDRESS, default: "", required: false}      # public host:port, passed as --contact.external-address
  - {name: EMAIL, default: "", required: false}         # --operator.email
  - {name: WALLET, default: "", required: false}        # --operator.wallet
  - {name: STORAGE, default: "2.0TB", required: false}  # --storage.allocated-disk-space
  - {name: LOG_LEVEL, default: "", required: false}
  - {name: STORJ_CONSOLE_ADDRESS, default: "0.0.0.0:14002", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies: []
```
Write env entries in the multi-line form used by siblings. `ADDRESS`, `EMAIL`, `WALLET`, `STORAGE`, `LOG_LEVEL` are the upstream image's variable names, translated by `start.sh` into flags (the node binary itself reads `STORJ_*`, not these). Identity files live in `/config/identity` and storage in `/config/storage` (one volume, as the draft says). Optionally list a second volume `/data` if a separate disk for pieces is wanted (see section 10); then also set `--storage.path`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export STORJ_CONSOLE_ADDRESS="${STORJ_CONSOLE_ADDRESS:-0.0.0.0:14002}"
CONF=/config
ID=/config/identity

if [ ! -s "${ID}/identity.cert" ] || [ ! -s "${ID}/identity.key" ] || [ ! -s "${ID}/ca.cert" ]; then
  echo "storj-node: no identity in ${ID}. Create one first, for example:" >&2
  echo "  docker run --rm -v <config>:/config --entrypoint /app/identity <image> create storagenode --identity-dir /config/identity" >&2
  echo "  then authorize it with your token (docs.storj.io/node) and restart." >&2
  # stay alive and idle so an empty /config does not crash-loop; no port is opened
  exec sleep infinity
fi

args=(--config-dir "${CONF}" --identity-dir "${ID}")
[ -n "${STORAGE:-}" ]   && args+=("--storage.allocated-disk-space=${STORAGE}")
[ -n "${ADDRESS:-}" ]   && args+=("--contact.external-address=${ADDRESS}")
[ -n "${EMAIL:-}" ]     && args+=("--operator.email=${EMAIL}")
[ -n "${WALLET:-}" ]    && args+=("--operator.wallet=${WALLET}")
[ -n "${LOG_LEVEL:-}" ] && args+=("--log.level=${LOG_LEVEL}")

# first start with a fresh config volume: create config.yaml (what SETUP=true does upstream)
if [ ! -e "${CONF}/config.yaml" ]; then
  /app/storagenode setup "${args[@]}"
fi
exec /app/storagenode run "${args[@]}"
```
- Idempotent: `setup` only runs while `config.yaml` is absent; the identity is never generated or overwritten (the 4 files are the node's identity and must be backed up).
- Nothing written to `/app`; cache/temp in `/tmp` (Go's default).
- Public port binds all interfaces by default (`setup` writes `server.address` `:28967` and the private API on `127.0.0.1:7778`, `cmd/storagenode/cmd_setup.go`); the dashboard is forced to `0.0.0.0:14002`, so check it from outside the container.
- Wallet, email and the address are passed as flags, not written to the process list beyond the node's own flags (they are not secrets). Never print the identity keys.
- `setup` refuses only when `config.yaml` already exists, loads the identity, writes `config.yaml`, then creates the databases and the storage verification file (`cmd_setup.go`). If it fails after writing `config.yaml`, the next start skips `setup` and `run` fails: remove `config.yaml` by hand after a failed first start. Upstream runs `setup` only on an explicit `SETUP=true`; auto-running it is a deliberate difference for the maintainers to accept (a missing separate storage mount on a fresh config volume would be initialised silently). UNVERIFIED: the full flow with a real identity.
- The idle `sleep infinity` branch is a deliberate design choice: see section 8 and 10.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: a storage node needs a pre-created, authorized identity and cannot listen
# without it; the test runs with no env and no identity, so ports 28967 and 14002 are never
# opened. Port probes are replaced by binary/file checks. See apps/storj-node plan, section 10.
filePaths:
- /app/storagenode
- /app/identity
- /usr/share/licenses/storj-node/LICENSE
```
Open point: `settings.yaml` lists three ports but the test cannot probe them, which conflicts with "every port needs a probe" and the DB exception does not apply (its 3 criteria describe databases). Options, in order of preference: (a) get maintainers to accept the narrowed `filePaths` test above; (b) add a runner with `entrypoint: /app/storagenode`, `cmd: version`, `expectedOutput: v1.166.4` after confirming that the subcommand and output format exist (UNVERIFIED); (c) generate a throw-away identity in CI (takes hours of proof-of-work, not feasible). Do not weaken: do not replace with always-true checks. The real runtime path (identity, setup, run) must be run by hand per the protocol (section 11). Copy `timeoutSeconds` from a sibling if a runner is added.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `config.yaml`, `storage/` (pieces, `storage-dir-verification`, SQLite DBs like `piece_expiration.db`), `identity/`, logs on stdout, the downloaded binaries (`/app/config/bin`) and supervisor files (`/var/log/supervisor`, `/etc/supervisor`). Here: binaries are baked in `/app` (read-only), no supervisor, no updater, no auto-update; everything else under `/config`.
- Draft/chart extra persistence `/app/identity` and `/app/config` are merged into `/config/identity` and `/config/config.yaml` + `/config/storage`; existing users must remount (and keep the same files).
- Identity files must be readable by UID 568; document `chown 568:568` for migrating volumes. The chart runs as root (`runAsUser 0`); not needed here (port 28967 is unprivileged) but existing data owned by root must be re-owned (draft: "identity permissions need a check").
- Runs with `--read-only --tmpfs /tmp`; `/config` is the only writable path.

## 10. Risks, caveats and open questions

- **Identity is mandatory.** Without `/config/identity/{ca.cert,ca.key,identity.cert,identity.key}` the node cannot start; creating and authorizing one needs a Storj auth token and hours of CPU. The idle behaviour in `start.sh` is a decision for the maintainers: idle (current plan) vs exit non-zero (honest but fails the empty-`/config` criterion). Flag in the PR.
- **Test gap**: no port probe is possible; see section 8. Test coverage is weaker than for other apps.
- **Updates**: the Storj version server enforces a minimum node version and nodes that fall behind get disqualified/suspended. Upstream auto-updates binaries inside the container; this image does not (the updater and supervisor are dropped). The image tag must follow upstream releases quickly; Renovate patch bumps should be auto-merged and users must pull new tags. Consider whether to add `storagenode-updater` later (it needs a writable binary location, which conflicts with the read-only `/app`).
- Version server: the node contacts https://version.storj.io on start; it needs outbound internet.
- Network: inbound 28967 TCP and UDP must be forwarded from the internet, and `ADDRESS` must be the public host:port or the node is unreachable.
- Large disk: storage lives in `/config/storage` by default; for a big disk mount it there or set `STORJ_STORAGE_PATH` (not verified) plus a separate `/data` volume.
- Draft download links point at the identity zip, not the node zip (fixed). Draft says apt `unzip` is needed: already in the base.
- No checksum published (section 1). No musl/GPU/privileged blocker; arm64 zip exists (draft: yes).
- `SETUP` and `AUTO_UPDATE` from upstream are intentionally not supported; list that difference in the PR.

## 11. Build and test steps

```sh
cd apps/storj-node
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create storj-node-probe-config
docker run --rm -d --name storj-node-probe --read-only --tmpfs /tmp \
  -v storj-node-probe-config:/config storj-node:1.166.4
docker logs -f storj-node-probe
forgetool containers test --image storj-node:1.166.4 --config ./apps/storj-node/container-test.yaml
docker rm -f storj-node-probe; docker volume rm storj-node-probe-config
```
With an empty `/config` the expected log is the "no identity" message, and the container stays up (this is the only empty-start signal; ports are not open). Real success needs a prepared volume with a valid authorized identity: then expect storagenode log lines for starting the server (for example `Node ... started`, `server started` listening on `:28967`, console on `:14002`; exact text UNVERIFIED) and `curl localhost:14002` to answer. Run this by hand, ideally with `--read-only --tmpfs /tmp`, and check that a second `docker run` on the same volume does not run `setup` again.

## 12. PR checklist

- Branch `feat/add-storj-node`, commit and PR title `feat(storj-node): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Be explicit about what is untested unless run: the real node start with an authorized identity, `setup` behaviour, UDP reachability, arm64, update policy, and that no checksum verification is possible.
- Mention the dropped supervisor/updater and the `/app/*` to `/config` volume move in Notes. Do not tick "Built container locally" or "Ran container tests" unless done.
