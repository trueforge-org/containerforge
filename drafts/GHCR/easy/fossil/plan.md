# fossil — implementation plan
> Source: ./draft.md · Target: apps/fossil/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Ubuntu 26.04 (resolute) apt package `fossil` `1:2.26-2` (https://packages.ubuntu.com/resolute/fossil). Upstream stable is UNVERIFIED: the download page lists `fossil-src-2.23.tar.gz` (https://fossil-scm.org/home/uv/download.html), and the change log shows "Changes for version 2.29 (pending)" with a timeline entry "Fossil 2.29 [525a137617] 2026-11-20" (https://fossil-scm.org/home/doc/trunk/www/changes.wiki). The draft tag `2.15.1-ls4` is stale and is not used. |
| Draft vs. verified | Draft says `apt:fossil` and the chart image `ghcr.io/nicholaswilde/fossil:2.15.1-ls4` (Alpine, source built). This plan does not reuse that image: the apt package is used instead. |
| Renovate (proposed) | `datasource=deb depName=fossil registryUrl=https://archive.ubuntu.com/ubuntu` (same form as `apps/steamcmd`). Open question: the deb version carries an epoch (`1:2.26-2`), so renovate will not bump `VERSION` directly; see section 10. |
| License | UNVERIFIED: no license file was fetched. Confirm the SPDX ID on https://fossil-scm.org before writing `LICENSE`. |
| Source URL | https://fossil-scm.org (SOURCE). Documentation: https://fossil-scm.org/home/doc/trunk/www/permutedindex.html |
| Download / arch | amd64 and arm64 both available from the Ubuntu archive (`amd64, arm64, armhf, ppc64el, riscv64, s390x`). No release binary URL is needed. |
| Checksum source | Ubuntu archive signed metadata (apt). Upstream tarball checksums are not used. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/Dockerfile: Alpine 3.13.5 build stage that compiles `fossil-src-${VERSION}.tar.gz` (sha256 `CHECKSUM` arg) with `--json --with-th1-docs --with-th1-hooks --with-tcl`; final `ghcr.io/linuxserver/baseimage-alpine:3.13`; `ENV HOME /app`; `EXPOSE 8080`; `VOLUME /app`. No USER, ENTRYPOINT or CMD. Alpine-only, so it is not copied (the chart image is musl). |
| Port | 8080/tcp (`EXPOSE 8080` upstream). Bind address and HTTP mode for the apt build are UNVERIFIED. |
| Env vars (real) | UNVERIFIED: the upstream Dockerfile sets only `HOME=/app`. No start script was fetched, so no further variables are confirmed. Do not add any until `fossil help server` or the Fossil docs confirm them. |
| Data/config write paths | Upstream writes to `/app` (`HOME`, `VOLUME /app`). ContainerForge uses `/config` for repositories (`HOME=/config`). |
| Dependencies | None. Fossil ships with its own SQLite, and the apt package pulls only the libraries it needs. |

## 2. Target layout

- `apps/fossil/Dockerfile`
- `apps/fossil/docker-bake.hcl`
- `apps/fossil/settings.yaml`
- `apps/fossil/container-test.yaml`
- `apps/fossil/start.sh`: seeds `/config` and `exec`s `fossil server`.

No `defaults/`, `etc/`, `health/` or `DOWNSTREAM_CHANGES.md`. Fossil is not used as a `FROM` base, so `DOWNSTREAM_CHANGES.md` is not needed. `root/` is not used.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. Fossil is a single C binary from the Ubuntu archive, so the ubuntu base covers it. Closest siblings: `apps/valkey` (single server binary from apt, pinned package version, `start.sh`) and `apps/steamcmd` (apt package with renovate `deb` datasource).

## 4. Dockerfile

1. `ARG VERSION` (`2.26`) and `ARG PACKAGE_VERSION` (`1:2.26-2`). Pass both through `docker-bake.hcl`.
2. `USER root`.
3. `RUN test "$(echo "${PACKAGE_VERSION}" | sed 's/^[0-9]*://; s/-.*//')" = "${VERSION}" && apt-get update && apt-get install -y --no-install-recommends "fossil=${PACKAGE_VERSION}" && rm -rf /var/lib/apt/lists/*`. The check ties the image to `VERSION`, as `apps/valkey` does.
4. `COPY --chmod=0755 start.sh /start.sh`.
5. `ENV HOME=/config FOSSIL_PORT=8080`. (Variable name is ours, not upstream's; document it in `settings.yaml`.)
6. `USER apps`, then `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `CMD ["/start.sh"]`.
7. License: `COPY` or `RUN` the Fossil license file to `/usr/share/licenses/fossil/` (taken from `/usr/share/doc/fossil/copyright` in the package, UNVERIFIED path).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "fossil"
}

variable "VERSION" {
  // renovate: datasource=deb depName=fossil registryUrl=https://archive.ubuntu.com/ubuntu versioning=loose
  default = "2.26"
}

variable "PACKAGE_VERSION" {
  default = "1:2.26-2"
}

variable "LICENSE" {
  default = "UNVERIFIED"   # confirm SPDX ID before merging
}

variable "SOURCE" {
  default = "https://fossil-scm.org"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION         = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source"   = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output   = ["type=docker"]
  tags     = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits  = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `cd apps/fossil && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://fossil-scm.org"`.
- `ports`: `port: 8080`, `protocol: http` (or `tcp`, following the sibling schema), `required: true`.
- `env`: `FOSSIL_PORT` (default `8080`, required false); `TZ` (default `Etc/UTC`, required false, as in `apps/steamcmd`). Do not add other variables until verified.
- `volumes`: `/config`, required `true`.
- `dependencies`: none.

## 7. start.sh

- `set -euo pipefail`; `export HOME=/config`.
- `mkdir -p /config/repos`. Create a default repository only when `/config/repos/default.fossil` is missing (`fossil new` on first start). Never overwrite an existing file.
- Do not write under `/app` (the image has none).
- Server command: `exec fossil server --port "${FOSSIL_PORT}" --ipaddr 0.0.0.0 /config/repos/default.fossil`. The exact flags are UNVERIFIED: confirm with `fossil help server` in the built image before using them. If `fossil server` needs a repolist instead, use `--repolist /config/repos`.
- Bind to all interfaces (`0.0.0.0`), per the start-script rule.
- Caches go to `/tmp` (`TMPDIR=/tmp`), never `/config`.

## 8. container-test.yaml

- Header: the forgetool schema comment used by siblings.
- `tcp`: `port: '8080'`, (`apps/valkey/container-test.yaml` sets no `timeoutSeconds`, so omit it unless the first run needs it).
- `filePaths`: `/start.sh`, `/usr/bin/fossil`.
- No HTTP probe unless a fixed path is confirmed. A TCP probe is enough for the port in `settings.yaml`.
- No database dependency, so the narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (`USER apps`). The apt install is the only `root` step.
- Read-only rootfs: the repository lives in `/config/repos`, and `HOME=/config`. Fossil temp files go to `/tmp`.
- Upstream `VOLUME /app` becomes `/config`. The chart's `/config` pvc is the correct persistent path.
- Default port 8080 is above 1024, so no privilege is needed.
- Draft security expectations (non-root false, readOnlyRootFilesystem false, runAsUser 0) are chart defaults that this image does not need. The image runs non-root with a read-only rootfs, which is a deviation from the chart and must be called out in the PR.

## 10. Risks, caveats and open questions

- Upstream version: the latest stable Fossil is UNVERIFIED (2.23 on the download page, 2.29 pending in the change log). Ubuntu's `2.26` may lag. The chart pins an older tag, so confirm which version the PR should track.
- Renovate: the deb datasource returns the epoch version (`1:2.26-2`), so automatic bumps of `VERSION` may need a custom rule. Open question.
- Server flags: `fossil server` flags and the repolist behaviour are UNVERIFIED for the Ubuntu build. Verify in the image before writing `start.sh`.
- License: UNVERIFIED, see section 1.
- Upstream image is third-party (nicholaswilde) and Alpine-based; this plan uses the official Ubuntu package instead, so it does not copy that image.
- Initial admin user and first repository are created by hand after start (draft caveat, not confirmed on a fetched page).
- No blockers found for amd64 or arm64.

## 11. Build and test steps

From `apps/fossil`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name fossil-probe --read-only --tmpfs /tmp -v fossil-probe-config:/config fossil:2.26`, then `docker logs -f fossil-probe`. Expected readiness signal: a line from `fossil server` showing it is listening on port 8080 (exact text UNVERIFIED until the first run). Then `docker rm -f fossil-probe; docker volume rm fossil-probe-config`.
4. `forgetool containers test --image fossil:2.26 --config ./apps/fossil/container-test.yaml` (fall back to the manual checks in the protocol if forgetool is missing).
5. Scratch containers and volumes are removed between rounds.

## 12. PR checklist

- Branch `feat/add-fossil`, commit `feat(fossil): add new container`.
- PR title `feat(fossil): add new container`, targets `main`.
- PR description uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and checks only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it, and the `license/cla` check shows status.
- State what is not tested: if the image is not built or run locally, say so and do not tick "Built container locally".
- Unverified items from section 1 are listed in the PR for reviewer attention.
