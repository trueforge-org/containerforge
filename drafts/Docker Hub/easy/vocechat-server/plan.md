# vocechat-server — implementation plan
> Source: ./draft.md · Target: apps/vocechat-server/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/Privoce/vocechat-server-rust (Rust chat server), docs https://doc.voce.chat/ |
| Latest stable | `v0.5.41` (tags seen: v0.5.38 to v0.5.41). Matches the chart tag |
| Renovate | `datasource=github-releases depName=Privoce/vocechat-server-rust versioning=semver` |
| License | UNVERIFIED and restrictive. The repo has no `LICENSE` file (all common names return 404). The README says "Free for personal use, require license for non-personal use" (free up to 20 registered users, 49 USD per version otherwise) and lists the server as "Big Time Public License". The docs call the Docker image "Non-commercial". `Cargo.toml` shows `license = "MIT"` for one crate (version 0.3.3), which conflicts. There is no SPDX id for this license |
| amd64 asset | `https://github.com/Privoce/vocechat-server-rust/releases/download/v0.5.41/vocechat-server-v0.5.41-x86_64-unknown-linux-musl.zip` (17.8 MB) |
| arm64 asset | `https://github.com/Privoce/vocechat-server-rust/releases/download/v0.5.41/vocechat-server-v0.5.41-aarch64-unknown-linux-musl.zip` (17.5 MB) |
| Zip content (both inspected) | `vocechat-server` (52 MB amd64, 49 MB arm64, ELF, no dynamic-loader path found in the first 4 KB, so static musl), `config/config.toml`, `config/config-tls.toml`, `config/templates/register_by_email.html`, `config/templates/login_by_email.html`. No license file |
| Checksum source | No checksum file asset. GitHub lists a `sha256:` digest per asset on the release page (the asset API `digest` field). Pin the two digests as build ARGs at port time (UNVERIFIED mapping of hash to asset: read them from `gh api repos/Privoce/vocechat-server-rust/releases/tags/v0.5.41`) |
| Upstream Dockerfile | Reviewed (`build/docker/Dockerfile` at the commit in the draft): `FROM busybox`, copies the binary to `/home/vocechat-server/vocechat-server` and `config` next to it, `EXPOSE 3000`, `WORKDIR /home/vocechat-server`, `ENTRYPOINT /docker-entrypoint.sh`. The entrypoint runs `./vocechat-server` with optional extra args (`*.toml` or `--*` arguments). The draft's commit hash is not needed |
| Port | `3000/tcp` (`[network] bind = "0.0.0.0:3000"` in `config.toml`) |
| Config | `config/config.toml` relative to the working directory, passed as a positional arg in the official installer (`config/config.toml`). `[system] data_dir = "./data"`, `[webclient] url = "https://sh.voce.chat/web_client/v0.4.x"` (the web UI is fetched from this URL), `[network] bind`, optional `domain`, `[network.tls]` blocks, `[template.*]` mail templates, optional `[[user]]` seed users |
| CLI overrides | `--network.bind <addr>` and `--network.domain <name>` are shown in the official docker docs. Other keys likely follow the same `--section.key` pattern (UNVERIFIED) |
| Env vars | None read by the binary that could be confirmed (a string scan for `VOCECHAT_*` found nothing). The commented-out lines of upstream `docker-entrypoint.sh` (`ADMIN_USER`, `DOMAIN`, ...) are dead code. Upstream Dockerfile sets `VOCECHAT_FCM_*` variables, but this could not be confirmed as read, so they are excluded |
| Data | `data/` directory (SQLite DB under `data/db`, uploads, certs cache). Docs say backup is "copy the data directory while the service is stopped" |
| Health endpoint | UNVERIFIED (no `/health` found in the binary strings) |

## 2. Target layout

```
apps/vocechat-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: the release zip already contains `config/`, which is copied to `/app/vocechat/config` and used as the seed source by start.sh. This keeps the seed in step with each version bump. `root/` is not used. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the binaries are static musl, so they run on glibc ubuntu without extra libraries; `unzip`, `curl` and `ca-certificates` (needed for the runtime web client fetch and HTTPS) are in the base. Closest sibling: `apps/adguardhome-sync` for the prebuilt-binary pattern, `apps/bazarr` for `unzip`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, plus `ARG SHA256_AMD64` and `ARG SHA256_ARM64` (the release digests; read from the release at port time).
2. `USER root`; `ENV HOME=/config`.
3. Arch mapping in the `RUN`: `case "$TARGETARCH" in amd64) A=x86_64; SUM="$SHA256_AMD64";; arm64) A=aarch64; SUM="$SHA256_ARM64";; *) echo unsupported; exit 1;; esac`.
4. Download, verify, extract:
   - `curl -fsSL -o /tmp/vc.zip "https://github.com/Privoce/vocechat-server-rust/releases/download/v${VERSION#v}/vocechat-server-v${VERSION#v}-${A}-unknown-linux-musl.zip"`
   - `echo "${SUM}  /tmp/vc.zip" | sha256sum -c -`
   - `mkdir -p /app/vocechat && unzip -q /tmp/vc.zip -d /app/vocechat`
   - `chmod 755 /app/vocechat/vocechat-server && chown -R apps:apps /app && rm -rf /tmp/*`
5. License: there is no license file upstream, so write `/usr/share/licenses/vocechat-server/README` with the upstream URL and the README's usage terms (personal use, up to 20 registered users). Replace it with real license text if the maintainers obtain one.
6. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 3000`; `VOLUME /config`; `WORKDIR /config`.
7. No apt packages.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "vocechat-server" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Privoce/vocechat-server-rust versioning=semver
  default = "0.5.41"
}
variable "SHA256_AMD64" { default = "a5ec5106a2eb2433aed60777cd2a53b23236f28974d16264161c00e28845e049" }  // GitHub asset digest for v0.5.41 (read via the releases API)
variable "SHA256_ARM64" { default = "04f51c9656f0c040892c73562ef63794752e7d0fa610683052e10a0b3e4e73ac" }
variable "LICENSE" { default = "LicenseRef-Big-Time-Public-License" }  // UNVERIFIED
variable "SOURCE"  { default = "https://github.com/Privoce/vocechat-server-rust" }
```

`image` passes `VERSION`, `SHA256_AMD64` and `SHA256_ARM64` as args. The digests change with every release, which renovate does not update; either accept a manual bump or drop the checksum ARGs and verify with the digest at port time only (open question, section 10). The other targets (`docker-metadata-action`, `image-local`, `image-all`, `group "default"`) follow `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/Privoce/vocechat-server-rust"`.
- `ports`: `3000` / `tcp` / `required: false`.
- `env`: `TZ` / `Etc/UTC` / false. Nothing else (no env names were confirmed). Document `--network.domain` and `--network.bind` as container arguments in the PR notes, not as env.
- `volumes`: `/config` / required true.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/data
# seed config only when missing, never overwrite user edits
if [ ! -f /config/config/config.toml ]; then
  mkdir -p /config/config
  cp -rn /app/vocechat/config/. /config/config/
fi
cd /config
exec /app/vocechat/vocechat-server config/config.toml "$@"
```

- cwd `/config`, so `data_dir = "./data"` resolves to `/config/data` and template paths resolve next to `config/config.toml` (UNVERIFIED: whether `templates/...` is relative to the config file or the cwd. The official zip layout implies relative to `config/`; if the first run logs a template error, also copy `config/templates` to `/config/templates`).
- The default bind is `0.0.0.0:3000`, so other containers can connect.
- `"$@"` allows `--network.domain example.com` and similar overrides.
- Nothing is written under `/app`.
- Idempotent: the seed runs only once; the data directory is created if absent.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
filePaths:
- /app/vocechat/vocechat-server
- /app/vocechat/config/config.toml
```

No `http` probe is added because no health or index path was confirmed (the UI is fetched from the internet at runtime and may fail offline). Add `http` with `/` if the first run shows a stable response.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Runs from `/home/vocechat-server` (chart mounts `/home/vocechat-server/data`) | cwd `/config`; data in `/config/data`, config in `/config/config` |
| Binary and `config/` shipped together | Binary and pristine config in read-only `/app/vocechat`; user copy in `/config/config` |
| Chart: UID 568, read-only rootfs | Matches: `USER apps`, writes only to `/config` (and `/tmp` if needed) |
| TLS cache (`cache_path = "./data/cert"`) when ACME is enabled | Lands in `/config/data/cert`; ports 80/443 would need a capability and are out of scope |

The draft's "extra persistence" (the data PVC) maps onto `/config/data`, so no second volume is needed.

## 10. Risks, caveats and open questions

- The license is the main blocker. There is no license file, no SPDX id, and the README makes the image free only for personal use up to 20 registered users. A maintainer must decide whether ContainerForge can redistribute it; the draft calls it "easy" but this is a policy question.
- The web client is fetched at runtime from `https://sh.voce.chat/web_client/v0.4.x` (UNVERIFIED whether it is cached on disk). Offline or restricted egress could mean no UI; the container still listens on 3000.
- `webclient` URL and `refresh_token_expiry_seconds` in the shipped config differ from the tagged-source config; the plan uses the zip's config because it matches the binary.
- Checksums: the digests must be fetched and updated by hand on version bumps, or the verification step removed.
- The draft says no arm64 for copy-from, but an aarch64 musl zip exists, so arm64 is covered by the zip (verified downloadable; not run).
- Static musl binary on a glibc base: expected to work; not run locally.
- No health endpoint found, so there is no `HEALTHCHECK` beyond the TCP probe.
- Default admin user is created in the web UI on first start (draft says no config is needed up front); not verified.

## 11. Build and test steps

```sh
cd apps/vocechat-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create vocechat-server-probe-config
docker run --rm -d --name vocechat-server-probe --read-only --tmpfs /tmp \
  -v vocechat-server-probe-config:/config vocechat-server:0.5.41
docker logs -f vocechat-server-probe   # expect a listening / "server started" style line on 0.0.0.0:3000 and no panic
curl -sSI http://127.0.0.1:3000/       # via a published port or `docker exec`
forgetool containers test --image vocechat-server:0.5.41 --config ./apps/vocechat-server/container-test.yaml
docker rm -f vocechat-server-probe; docker volume rm vocechat-server-probe-config
```

Restart once with the same volume to confirm the config is not re-seeded and the data persists in `/config/data`. The exact readiness log text is UNVERIFIED, so the pass signal is "process alive, port 3000 open, no panic or fatal lines". Repeat the build for `linux/arm64` if an arm64 runner is available.

## 12. PR checklist

- Branch `feat/add-vocechat-server`; commit and PR title `feat(vocechat-server): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` completely; tick only boxes that apply.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; check `license/cla`.
- Flag the license question prominently in the PR, plus what was not tested (arm64, offline behavior, web client fetch, TLS mode, template path).
- Pre-completion: bake print, build, empty-`/config` read-only run, forgetool test, no weakened assertions, cleanup done.
