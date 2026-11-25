# zurg — implementation plan
> Source: ./draft.md · Target: apps/zurg/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Draft pins `v0.9.3-hotfix.11` (chart image `ghcr.io/geek-cookbook/zurg`). Latest release in `debridmediamanager/zurg-public` is **v1.0.0**, published 2026-08-09T23:14:01Z. The draft version is a major release behind; this plan targets v1.0.0. Source: `gh api repos/debridmediamanager/zurg-public/releases/latest` |
| Renovate | `datasource=github-releases depName=debridmediamanager/zurg-public versioning=semver` (suggested; tags `vX.Y.Z`). |
| License | **NOT FOUND.** The repo `license` field is null and the repo has no LICENSE file (v1.0.0 tree: README.md, WINDOWS.md, config.yml, docker-compose.yml, lib/, rclone.conf, scripts/). Redistribution terms are unknown. This is a blocker, see section 10. |
| Source URL | https://github.com/debridmediamanager/zurg-public (public release and config repo; the binary is closed-source per the draft) |
| Release assets | `zurg-v1.0.0-linux-amd64.zip` https://github.com/debridmediamanager/zurg-public/releases/download/v1.0.0/zurg-v1.0.0-linux-amd64.zip (7128418 bytes, sha256 `2c31fa4bb8e99516d4f3ea97ef9a595b3adeff0d1923886182aef1c8cdc96cf9`). `zurg-v1.0.0-linux-arm64.zip` https://github.com/debridmediamanager/zurg-public/releases/download/v1.0.0/zurg-v1.0.0-linux-arm64.zip (6501387 bytes, sha256 `95107e5fb1393e73640e2fbde9eda0919a46086e1c03b46207765a0f3dc9c7ed`). Each zip holds a single file `zurg`. |
| Checksum source | GitHub asset digests (sha256) from the releases API. Downloaded zips were hashed and match. No checksum file in the release. |
| Binary type | `zurg` (amd64 zip) is an ELF x86-64, dynamically linked against the glibc loader `/lib64/ld-linux-x86-64.so.2`, stripped. **Not static**, as the draft claimed. It needs glibc, which the Ubuntu base has. |
| Per-arch | amd64: yes. arm64: yes (zip exists, digest above). |
| Upstream build recipe | None in the public repo. Upstream image `ghcr.io/debridmediamanager/zurg-public:v1.0.0` (and `:latest`) exists for `linux/amd64`, `linux/arm64`, `linux/arm`. Its Dockerfile is UNVERIFIED (not published in the repo). The draft's third-party Dockerfile (`geek-cookbook/containers` at 69a4d32) was not fetched. |
| Upstream image platforms | `ghcr.io/debridmediamanager/zurg-public:v1.0.0` linux/amd64 and linux/arm64 and linux/arm (GHCR manifest, read-only). `ghcr.io/geek-cookbook/zurg:v0.9.3-hotfix.11` linux/amd64 only. |
| Real env vars | `TOKEN` or `RD_TOKEN`: Real-Debrid API token; auto-creates a config on first run. `PORT`: overrides the configured port. Source: https://github.com/debridmediamanager/zurg-public/blob/main/README.md |
| CLI flags | `-c, --config` (default `./config.yml`, cwd-relative). Subcommands: `download-requirements` (downloads `ffprobe` and `rclone` into a directory and updates config paths), `clear-downloads`, `clear-torrents`, `network-test`, `version`. |
| Runtime downloads | The first run without them downloads `bin/ffprobe` and `bin/rclone` (README "Binary"). Exact URLs and checksums: UNVERIFIED. |
| Ports | 9999/tcp HTTP: web dashboard at `/config/`, WebDAV, and `/http/version.txt` used by the upstream compose healthcheck. Source: https://github.com/debridmediamanager/zurg-public/blob/main/docker-compose.yml |
| Default config | `config.yml` in the repo: `zurg: v1`, `token: yourtoken`, `# port: 9999`, `check_for_changes_every_secs: 10`, `enable_repair: true`, `mount_path: "/mnt/zurg"`, `on_library_update: sh plex_update.sh "$@"`, plus `directories:` filters. |
| Upstream data paths | Compose mounts `./config.yml:/app/config.yml`, `./scripts/plex_update.sh:/app/plex_update.sh`, `zurgdata:/app/data`. The binary's own data directory is UNVERIFIED (cwd-relative `data` is the likely default). |
| rclone | The upstream compose runs `rclone/rclone:latest` as a separate container with `SYS_ADMIN`, `/dev/fuse`, `apparmor:unconfined`, mounting `zurg:` to `/data`. Not part of zurg itself. |
| Dependencies | Real-Debrid account and API token (README requirement). No database. |

## 2. Target layout

- `apps/zurg/Dockerfile`
- `apps/zurg/docker-bake.hcl`
- `apps/zurg/settings.yaml`
- `apps/zurg/container-test.yaml`
- `apps/zurg/start.sh`
- `apps/zurg/defaults/config.yml` only if the test without a token fails (section 7). It is a minimal seed, not a copy of the upstream file, to avoid shipping the upstream file without a licence (section 10).

No `root/`, no `etc/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits: the binary is glibc dynamic and needs no runtime. The draft's "alpine wrapper" is not used; the plan runs on Ubuntu. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball per `TARGETARCH`, extracted into `/app`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG SHA256_AMD64`, `ARG SHA256_ARM64` (set to the digests in section 1), `USER root`, `ENV HOME=/config`.
2. `apt-get install -y --no-install-recommends unzip` (not in the base; generic tool, not version-coupled to the app), then `rm -rf /var/lib/apt/lists/*`.
3. Map `TARGETARCH` to `amd64` or `arm64` with a `case`. Anything else fails the build.
4. `curl -fsSL -o /tmp/zurg.zip https://github.com/debridmediamanager/zurg-public/releases/download/v${VERSION}/zurg-v${VERSION}-linux-${ARCH}.zip`, then `echo "${SHA256} /tmp/zurg.zip" | sha256sum -c -`.
5. `unzip -o /tmp/zurg.zip zurg -d /app/zurg && chmod 0755 /app/zurg/zurg`.
6. Runtime helper binaries (see section 7, decision): either
   - A (recommended): `/app/zurg/zurg download-requirements /app/zurg/bin` at build time, so the image contains `ffprobe` and `rclone`. Requires build-time network. Their checksums are UNVERIFIED, so record what is downloaded. Or
   - B: leave them to the first run, writing into `/config/bin` (persistent, writable). Use if A cannot be verified.
7. `chown -R root:root /app && chmod -R 755 /app`, then `rm -rf /tmp/zurg.zip /var/lib/apt/lists/*`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 9999
VOLUME /config
```

`WORKDIR /config` makes cwd-relative paths (default `./config.yml`, `./data`) land in the persistent volume.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "zurg"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=debridmediamanager/zurg-public versioning=semver
  default = "1.0.0"
}

variable "LICENSE" {
  // BLOCKER: set to the confirmed licence of the zurg binary. No licence is published
  // (section 1). Do not merge with a placeholder.
  default = "UNLICENSED-PENDING"
}

variable "SOURCE" {
  default = "https://github.com/debridmediamanager/zurg-public"
}
```

Then the default group and the four standard targets copied from `apps/adguardhome-sync/docker-bake.hcl`. `docker buildx bake --print` must pass before the LICENSE placeholder is replaced; the placeholder is only for the draft and is not to be merged.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/debridmediamanager/zurg-public"
ports:
  - port: 9999
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "9999"
    required: false
  - name: TOKEN
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`TOKEN` is listed because the binary reads it (README). It is not required to start, only to serve a library, so `required: false` with an empty default (the rule requires a default or start-time handling for required vars). `RD_TOKEN` is an alias and is not listed. No `dependencies`: rclone is not an image dependency. The chart's configmap mounts are not reproduced.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

# Seed a config only when missing. Never overwrite user state.
if [ ! -f /config/config.yml ] && [ -f /defaults/config.yml ]; then
  cp -n /defaults/config.yml /config/config.yml
fi

cd /config
exec /app/zurg/zurg --config "${CONFIG_FILE:-/config/config.yml}"
```

- Decision (open question 11): whether `defaults/config.yml` is needed. The README says `TOKEN` auto-creates a config on first run, so the seed may be unnecessary. Without a token, the binary's behaviour is UNVERIFIED: it may exit. Run the no-env test first; if zurg exits, add the minimal seed (`zurg: v1`, `token: ""`, `port: 9999`, `mount_path: /config/mnt`) rather than weaken the test.
- Token: passed through the environment (`TOKEN`), not argv. Do not echo it.
- If `download-requirements` ran at build (6A), the config paths for `ffprobe` and `rclone` must point at `/app/zurg/bin`; otherwise use `/config/bin` (6B). Confirm which the binary reads.
- `mount_path` (default `/mnt/zurg`) is not mounted in this image (no FUSE). Leave it unused; WebDAV on 9999 is the consumer interface.
- `exec` so PID 1 is zurg.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9999'
http:
- port: '9999'
  path: /http/version.txt
filePaths:
- /app/zurg/zurg
```

- `/http/version.txt` is the path the upstream compose healthcheck uses, so it is the right probe; its status is confirmed in the run.
- `timeoutSeconds: 120`: the first start may download or check requirements (section 4 step 6). Shorten only if the run is fast and sibling practice supports it.
- The test runs with no env vars, so the authenticated code path (a real token) is NOT covered. Per the protocol, run it yourself (section 11) with a token that the user provides; do not invent one.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or behavior | Plan |
| --- | --- |
| `/app/data` (compose volume `zurgdata`) | `/config/data` via `WORKDIR /config` and the cwd-relative default. Confirm in run. |
| `/app/config.yml`, `/app/plex_update.sh` (compose mounts) | `/config/config.yml` (`--config`). `plex_update.sh` is a Plex-specific hook: not shipped. The `on_library_update` line is removed from the seed or left unset; confirm the binary does not fail without it. |
| Auto-download of `ffprobe` and `rclone` on first run | Decision in section 4 step 6: build-time (A) or `/config/bin` (B). Never write to `/app` at runtime. |
| `rclone` FUSE mount (compose `rclone` container, `SYS_ADMIN`, `/dev/fuse`) | Out of scope: no FUSE or `SYS_ADMIN` in this image. Consumers use WebDAV on 9999. |
| Chart security (draft): non-root yes (568), read-only rootfs yes, privileged no | Matches the plan: runs as `apps`, read-only rootfs compatible, not privileged. Run with `--read-only --tmpfs /tmp`. |

## 10. Risks, caveats and open questions

- **Licence (blocker).** No licence is published in the repo or release. Shipping the binary in a published image needs the user to confirm redistribution terms. Do not publish or merge until confirmed. The draft also flagged this.
- **Stale draft version.** The draft pins v0.9.3-hotfix.11 (third-party image). Latest is v1.0.0. The plan targets v1.0.0; the user should confirm this is wanted, since v1.0.0 is a major release.
- **Binary is glibc dynamic, not static.** The draft's "glibc is fine for the static binary" is wrong; it works on Ubuntu, but do not describe it as static in the PR.
- **Runtime downloads.** `ffprobe` and `rclone` come from the network; no checksums are published on the fetched pages. Decision A or B (section 4). Record the sha256 of what is downloaded if A is used.
- **Real-Debrid token required** for a useful service. Not required to start; the authenticated path is untested in CI.
- **Upstream build unknown.** No Dockerfile in the public repo; the draft's geek-cookbook recipe was not fetched. The image is built from the release zip, not from an upstream recipe.
- **Plex hook.** `on_library_update` and `plex_update.sh` are Plex-specific. Not shipped.
- **Draft `copy-from` value.** The draft says `copy-from: no`. The upstream image exists for amd64 and arm64 (GHCR manifest). COPY --from is not chosen because the upstream recipe is unknown and the zips are simpler. Recorded here, not changed.
- Open question 11: keep `defaults/config.yml` seed or rely on `TOKEN` (section 7).
- Blockers: licence (above).

## 11. Build and test steps

```sh
cd apps/zurg
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name zurg-probe --read-only --tmpfs /tmp \
  -v zurg-probe-config:/config zurg:1.0.0
docker logs -f zurg-probe         # expected readiness: zurg listening on :9999 (exact line UNVERIFIED)
curl -fsS http://localhost:9999/http/version.txt   # after publishing 9999 or docker exec

# Authenticated path (manual, only with a token the user supplies):
docker rm -f zurg-probe
docker run --rm -d --name zurg-probe --read-only --tmpfs /tmp \
  -e TOKEN="$RD_TOKEN" -v zurg-probe-config:/config zurg:1.0.0
docker logs -f zurg-probe         # check it reaches the library scan without auth errors

forgetool containers test --image zurg:1.0.0 --config ./container-test.yaml

docker rm -f zurg-probe; docker volume rm zurg-probe-config
```

- Empty `/config` on the first start, then a restart on the same volume.
- arm64: only if the amd64 build fails in an arm64-specific way.
- Do not paste the token into logs, PR text or chat; keep it in the shell environment only.

## 12. PR checklist

- Do not open the PR until the licence blocker (section 10) is resolved by the user. Branch `feat/add-zurg` from `main`, commit and PR title `feat(zurg): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, every section and checkbox kept, only applicable boxes checked. Notes contains `🤖 This PR is AI generated.`
- State what was not tested: the authenticated path (no token in CI), arm64, the runtime downloads if option B is used, and the rclone mount (out of scope). Do not tick "Built container locally" unless the build ran.
- Pre-completion: app-scoped change; bake and Dockerfile version-aligned; LICENSE in bake is the confirmed licence, not the placeholder; no `DOWNSTREAM_CHANGES.md` (not a base).
