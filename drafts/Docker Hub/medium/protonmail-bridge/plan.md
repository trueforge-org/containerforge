# protonmail-bridge — implementation plan
> Source: ./draft.md · Target: apps/protonmail-bridge/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v3.27.2 (released 2026-11-06), https://api.github.com/repos/ProtonMail/proton-bridge/releases/latest. The draft's container tag `shenxn/protonmail-bridge:3.19.0-1` is older and is not the version we target. |
| Renovate | `datasource=github-releases depName=ProtonMail/proton-bridge versioning=semver` (matches the rule in `docker-bake.instructions.md`). |
| License | GPL-3.0 (GitHub SPDX, https://api.github.com/repos/ProtonMail/proton-bridge). `LICENSE` in docker-bake.hcl uses `GPL-3.0`. |
| Source URL | https://github.com/ProtonMail/proton-bridge |
| Download amd64 | `https://github.com/ProtonMail/proton-bridge/releases/download/v3.27.2/protonmail-bridge_3.27.2-1_amd64.deb` (confirmed in the release asset list). |
| Checksum / signature | Release has `protonmail-bridge_3.27.2-1_amd64.deb.sig` and `bridge_pubkey.gpg` (+ `.sig`). No checksum file is listed. Verify the deb with `gpg --verify` against `bridge_pubkey.gpg`. The key fingerprint: UNVERIFIED (confirm from the key file at build time). |
| Download arm64 | No prebuilt asset. Source build required. |
| Source build | `Makefile` on master (https://raw.githubusercontent.com/ProtonMail/proton-bridge/master/Makefile): `make build-nogui` with `BRIDGE_APP_VERSION?=3.27.2+git`, Go build with `BUILD_TAGS` and `GO_LDFLAGS`. Git tag `v3.27.2` to be checked out for the source build. |
| Upstream image | Dockerfile on master (https://raw.githubusercontent.com/shenxn/protonmail-bridge-docker/master/build/Dockerfile; the draft pins commit `ae5d201`, not checked). Two stages on `debian:sid-slim`. Build stage: installs `golang`, `build-essential`, `libsecret-1-dev`; runs `make build-nogui vault-editor` at `ARG version` (git ref). Final stage: installs `socat`, `pass`, `libsecret-1-0`, `ca-certificates`; copies `bridge`, `proton-bridge`, `vault-editor`, `gpgparams`, `entrypoint.sh` to `/protonmail/`. `EXPOSE 25/tcp 143/tcp`. `ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]`. No USER (root). No VOLUME. No ENV. |
| Upstream entrypoint.sh | UNVERIFIED: not fetched. Keychain setup, config paths and the ports the bridge really binds are in this file. Read it before writing start.sh. |
| Ports | Upstream image EXPOSEs 25 and 143. The draft guesses 1025 and 1143 (Proton defaults, UNVERIFIED). Confirm which ports the bridge binds from the bridge CLI or entrypoint. |
| Docker Hub | `shenxn/protonmail-bridge` has amd64 and arm64 images (https://hub.docker.com/v2/repositories/shenxn/protonmail-bridge/tags). The 3.19.0-1 tag is UNVERIFIED (not on the first page checked). |
| Dependencies | Paid Proton account. Keychain: `pass` and `gpg`, and `libsecret-1-0` (upstream). |

## 2. Target layout

- `apps/protonmail-bridge/Dockerfile`
- `apps/protonmail-bridge/docker-bake.hcl`
- `apps/protonmail-bridge/settings.yaml`
- `apps/protonmail-bridge/container-test.yaml`
- `apps/protonmail-bridge/start.sh`
- `apps/protonmail-bridge/defaults/` only if the keychain seed or gpg parameters file is needed on first start (reason: upstream `gpgparams`). Otherwise none.

Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build stage and the final stage. No runtime base is needed (the draft says ubuntu alone is enough). Closest siblings: an app with a Go build stage on ubuntu (see `.github/instructions/go-runtime.instructions.md`); `apps/ubuntu` as the foundation.

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION` (v3.27.2 tag), `ARG TARGETARCH`, `USER root`.
2. Build stage installs the Go toolchain and build deps from apt: `golang` (version UNVERIFIED for ubuntu 26.04; must be new enough for proton-bridge's `go.mod`, check it), `build-essential`, `libsecret-1-dev`. Not pinned against VERSION yet; pin once the version is confirmed.
3. `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go` so Go caches stay in `/tmp`.
4. amd64 path: download the deb, verify its signature, install without pulling GUI deps where possible.
   - `curl -fL -o /tmp/bridge.deb <deb URL>`, `curl -fL -o /tmp/bridge.deb.sig <sig URL>`, `curl -fL -o /tmp/bridge_pubkey.gpg <pubkey URL>`, `gpg --import` into a temp `GNUPGHOME`, `gpg --verify`.
   - Extract with `dpkg-deb -x` to a staging dir (avoids installing GUI libraries). Copy the `proton-bridge` and `bridge` binaries to `/app/protonmail-bridge/`. Verify the binaries run (`--version`) in the build.
   - Note: a deb extract also needs runtime libs. UNVERIFIED which libs the CLI needs.
5. arm64 path (and also amd64 if the deb extract fails): `git clone --depth 1 --branch v3.27.2` into `/tmp/src`, `make build-nogui` then `make vault-editor` (matching upstream). Copy the outputs to `/app/protonmail-bridge/`.
6. Final stage: `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends pass gnupg libsecret-1-0 ca-certificates socat` (upstream list, socat UNVERIFIED need). Clean apt lists.
7. `mkdir -p /app/protonmail-bridge`, copy binaries from build stage, and license files (GPL-3.0 `LICENSE`) to `/usr/share/licenses/protonmail-bridge/`.
8. `ENV HOME=/config GNUPGHOME=/config/.gnupg PASSWORD_STORE_DIR=/config/.password-store` so the keychain lands in `/config` (decision in section 9).
9. `USER apps`, `COPY --chmod=0755 . /`, `COPY --chmod=0755 start.sh /start.sh`.
10. `EXPOSE` only the ports verified in section 10.

## 5. docker-bake.hcl

- `variable "APP" { default = "protonmail-bridge" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=ProtonMail/proton-bridge versioning=semver` and default `3.27.2`.
- `variable "LICENSE" { default = "GPL-3.0" }`
- `variable "SOURCE" { default = "https://github.com/ProtonMail/proton-bridge" }`
- Standard targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels), `image-local`, `image-all` (amd64, arm64), default group `image-local`.
- Validate: `cd apps/protonmail-bridge && docker buildx bake --print`.

## 6. settings.yaml

- Header: schema line and `schema_version: 1`, as in `apps/java17/settings.yaml`.
- `upstream_env_url: "https://github.com/ProtonMail/proton-bridge"`
- `ports`: only ports confirmed in section 10. Upstream EXPOSE is 25 and 143; the draft guesses 1025 and 1143 (UNVERIFIED). Do not list unverified ports.
- `env`:
  - `TZ`, default `Etc/UTC`, `required: false`.
  - `UMASK`, default `002`, `required: false` (sibling convention).
  - Any bridge env var the entrypoint reads: UNVERIFIED until entrypoint.sh is read. Do not invent one.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -eu`.
- First start: if `/config/.gnupg` or `/config/.password-store` is missing, create the keychain (gpg key from `gpgparams`, `pass init`). Seed only when missing; never overwrite existing keys.
- Config dir: `/config`. Caches and scratch: `/tmp`.
- The bridge needs an interactive login (see section 10). The start script must not block on a prompt; it starts the bridge in its non-interactive/CLI mode as the entrypoint does (UNVERIFIED, read entrypoint.sh).
- Bind address: IMAP and SMTP must listen on 0.0.0.0 for other containers. Check the bridge's bind setting (UNVERIFIED).
- Final line: `exec` the bridge process so signals reach it.
- Do not write to `/app/protonmail-bridge`.

## 8. container-test.yaml

- Header: forgetool schema line, as in `apps/nzbhydra2/container-test.yaml`.
- `tcp` probe for every port in settings.yaml (see section 10: pending the port check).
- `filePaths`: `/app/protonmail-bridge/proton-bridge` exists and is executable.
- `timeoutSeconds`: take from the closest sibling.
- The test runs without env vars or a Proton account. Without a login the IMAP and SMTP ports may not open; see section 10. Do not weaken or remove a port probe to pass.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (no USER). ContainerForge runs as `apps`, so `pass`, `gpg` and `proton-bridge` must work as a non-root user.
- Map the draft's `/root` persistence to `/config`: `HOME=/config`, keychain and bridge state under `/config`. The draft says the chart's `/root` pvc default must point at `/config`.
- `GNUPGHOME` permissions must be `0700` and owned by `apps`; set this in start.sh on first start.
- Read-only rootfs: `/tmp` holds gpg agent sockets if needed (gpg agent socket dir under `/tmp`, UNVERIFIED).
- Privileged ports: ports below 1024 are not bindable as `apps`. Upstream binds 25 and 143 (EXPOSE), so the rootless build must use high ports (for example 1025 and 1143, the draft's guess) and document the change in settings.yaml.

## 10. Risks, caveats and open questions

- **Interactive first login (blocker for full tests).** A paid Proton account is required, and the first login is done through the bridge CLI. The test run cannot log in. Without a login the bridge may not open its IMAP/SMTP ports. Confirm during a local run; if the ports only open after login, the tcp probes cannot pass and the protocol's DB exception does not apply. Escalate to the user, do not weaken the probes.
- **Keychain headless setup.** `pass` and `gpg` need a key and a store on first start. Mechanics are in upstream `entrypoint.sh` (UNVERIFIED, not read).
- **Ports.** EXPOSE 25/143 upstream vs. the draft's 1025/1143. Verify what the bridge binds, and pick non-privileged ports for the rootless build.
- **amd64 vendor deb vs. source.** The deb is verified in the release. Upstream builds from source on all arches, so the deb path is a divergence and runtime behaviour must be checked. The deb's GUI library dependencies may be needed at runtime (UNVERIFIED).
- **arm64 is a source build with Go.** Slower and needs a Go version new enough for the module. Untested.
- **Docker Hub tag `3.19.0-1`.** Existence UNVERIFIED. We target 3.27.2 from GitHub, not the chart's old tag.
- **Upstream Dockerfile version.** The draft pins commit `ae5d201`. The master copy was read, not the pinned commit. Re-read at the pinned commit before writing the port.
- **Signature key.** Fingerprint of `bridge_pubkey.gpg` not confirmed on a fetched page.

Blocker: the first-login step, unless a local run shows the ports open without an account.

## 11. Build and test steps

Per `.github/instructions/build-test-protocol.instructions.md`, `<app>` = protonmail-bridge:

1. `cd apps/protonmail-bridge && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name protonmail-bridge-probe --read-only --tmpfs /tmp -v protonmail-bridge-probe-config:/config protonmail-bridge:<version>`, then `docker logs -f protonmail-bridge-probe`. Expected readiness signal: UNVERIFIED (the bridge's startup line, read from entrypoint or a local run). Cleanup: `docker rm -f protonmail-bridge-probe; docker volume rm protonmail-bridge-probe-config`.
4. `forgetool containers test --image protonmail-bridge:<version> --config ./apps/protonmail-bridge/container-test.yaml`. If forgetool is unavailable, check by hand.
5. arm64 build only after amd64 is green, or if the failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-protonmail-bridge`, commit `feat(protonmail-bridge): add new container`, PR title the same, target `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user.
- State what was not tested: the Proton login, IMAP/SMTP use, the arm64 build, and the deb-vs-source path if not both run.
- `docker buildx bake --print` result and the build and test results reported honestly.
