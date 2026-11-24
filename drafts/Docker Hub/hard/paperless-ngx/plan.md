# gotenberg — implementation plan
> Source: ./draft.md (folder name `paperless-ngx`; the container in the draft is the chart's gotenberg sidecar) · Target: apps/gotenberg/ · Difficulty: hard (Chromium + LibreOffice on Ubuntu 26.04) · Role: sidecar (gotenbergImage of the paperless-ngx chart) · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 9.10.0 (release `v9.10.0`, published 2026-11-24 UTC, so under a day old; the draft uses 9.9). Pin 9.10.0, or fall back to the previous tag if CI shows a regression. Renovate datasource below. |
| Renovate | `datasource=github-releases depName=gotenberg/gotenberg versioning=semver extractVersion=^v(?<version>.+)$` |
| License | MIT (GitHub SPDX `MIT`), `LICENSE` in repo. `gotenberg/lok` is also MIT. |
| Source URL | https://github.com/gotenberg/gotenberg |
| Upstream Dockerfile | `build/Dockerfile` reviewed at the draft's commit `da5d11a` and at `v9.10.0` (only diff: `LOK_VERSION v0.0.7` -> `v0.0.8`). Final stage `gotenberg` = Chromium + LibreOffice, `debian:13-slim`, user 1001, `tini`, `CMD gotenberg`. |
| Build | Go 1.27.4 (`go.mod`), `CGO_ENABLED=0`, `go build -o gotenberg -ldflags "-s -w -X 'github.com/gotenberg/gotenberg/v9/cmd.Version=$GOTENBERG_VERSION'" cmd/gotenberg/main.go`. The ubuntu base ships Go 1.27.4 (`GO_VERSION` in `apps/ubuntu/docker-bake.hcl`), an exact match. |
| lok (LibreOfficeKit bridge) | `https://github.com/gotenberg/lok/releases/download/v0.0.8/lok_0.0.8_linux_{amd64,arm64}.tar.gz`, checksums in `.../v0.0.8/checksums.txt` (verified to exist), `install.sh` verifies the checksum and runs `lok --version`. Release binaries are linked against the LibreOfficeKit headers of Debian trixie-backports LibreOffice. |
| Packages from the Dockerfile | Fonts: `fonts-crosextra-carlito fonts-crosextra-caladea fonts-liberation fonts-liberation2 fonts-dejavu fonts-noto-cjk fonts-noto-color-emoji fonts-noto-core fonts-urw-base35`; `chromium`; `libreoffice-{writer,calc,impress,draw,math}`; `hyphen-*` dictionaries; `tini`, `curl`, `ca-certificates`. The draft's `qpdf`, `pdftk` and `exiftool` are **not** in the 9.x Dockerfile (PDF engines are built in), so do not install them. |
| Ubuntu 26.04 (resolute) facts | Archive `chromium-browser` is the snap stub (`2:1snap1-0ubuntu4`), confirming the draft caveat. `libreoffice` 4:26.2.7.3-0ubuntu0.26.04.1 (updates). The xtradeb PPA publishes a real `chromium` 156.0.8078.108-1xtradeb1.2604.1 for resolute. |
| Port | 3000 (`EXPOSE 3000`, `API_PORT` default 3000). Health route `GET /health`. |
| Env (docs, every flag has an env var) | `API_PORT`, `API_PORT_FROM_ENV`, `API_TIMEOUT` (30s), `LOG_LEVEL` (info), `CHROMIUM_AUTO_START` (false), `CHROMIUM_MAX_CONCURRENCY` (6), `CHROMIUM_RESTART_AFTER` (100), `CHROMIUM_START_TIMEOUT` (20s), `CHROMIUM_SHARED_BROWSER_CONTEXT`, `LIBREOFFICE_AUTO_START`, `API_ROOT_PATH`. Image-set vars: `CHROMIUM_BIN_PATH`, `CHROMIUM_HYPHEN_DATA_DIR_PATH`, `LIBREOFFICE_BIN_PATH`, `LOK_BIN_PATH`, `GOTENBERG_VERSIONS_DIR_PATH`, `OTEL_*_EXPORTER=none`. |
| Checksum sources | Go modules via `go.sum` (`go mod verify`); lok via `checksums.txt`; apt via signed archives. |

## 2. Target layout

```
apps/gotenberg/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (stateless). Not a `FROM` base for other apps, so no `DOWNSTREAM_CHANGES.md`. Note: the app folder is `gotenberg`, not `paperless-ngx`; the paperless-ngx application and Tika are separate images and out of scope.

## 3. Base image

Build stage and final stage on `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (Go 1.27.4 is already in the base; `go-runtime.instructions.md` applies: Go compiled in a dedicated build stage, `GOCACHE` in `/tmp`). Closest siblings: `apps/adguardhome-sync` (Go binary on ubuntu) and `apps/calibre-web` (the only existing app that installs Chromium).

## 4. Dockerfile

1. Stage `build` (`USER root`, `ARG VERSION`, `ARG TARGETARCH`, `ENV CGO_ENABLED=0 GOCACHE=/tmp/go-build GOPATH=/tmp/go HOME=/tmp`, `WORKDIR /tmp/src`): download `https://github.com/gotenberg/gotenberg/archive/refs/tags/v${VERSION}.tar.gz`, extract, `go mod download && go mod verify`, `go build -o /tmp/gotenberg -ldflags "-s -w -X 'github.com/gotenberg/gotenberg/v9/cmd.Version=${VERSION}'" cmd/gotenberg/main.go`.
2. Same stage: `ARG LOK_VERSION=0.0.8` (add a second renovate comment in the bake file), download `lok_${LOK_VERSION}_linux_${TARGETARCH}.tar.gz` and `checksums.txt`, `grep` the archive line and `sha256sum -c`, extract the `lok` binary (tarball layout UNVERIFIED, check with `tar tzf`).
3. Final stage `FROM` ubuntu 26.04, `USER root`, `ARG VERSION`. Add the xtradeb PPA (`add-apt-repository -y ppa:xtradeb/apps`, `software-properties-common` is in the base), pin it with `/etc/apt/preferences.d/xtradeb` so only `chromium` comes from it, then one `RUN` with `apt-get install -y --no-install-recommends chromium libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math` plus the font packages and `hyphen-*` set from section 1, `rm -rf /var/lib/apt/lists/*`. Verify each package name exists on resolute during the first build (UNVERIFIED for the hyphen and font names). `tini` and `curl` are already in the base: do not reinstall.
4. `COPY --from=build --chmod=0755 /tmp/gotenberg /usr/bin/gotenberg`, same for `lok` to `/usr/bin/lok`.
5. Files from the repo tarball (copy in the build stage, then `COPY --from=build`): `build/fonts.conf` -> `/etc/fonts/conf.d/100-gotenberg.conf`, `build/chromium-hyphen-data` -> `/opt/gotenberg/chromium-hyphen-data`, `build/chromium-policies` -> `/etc/chromium/policies/managed`, `build/capture-version.sh` -> `/opt/gotenberg/capture-version.sh`; license: `LICENSE` -> `/usr/share/licenses/gotenberg/LICENSE` and `lok`'s license.
6. `ENV CHROMIUM_BIN_PATH=/usr/bin/chromium CHROMIUM_HYPHEN_DATA_DIR_PATH=/opt/gotenberg/chromium-hyphen-data LIBREOFFICE_BIN_PATH=/usr/lib/libreoffice/program/soffice.bin LOK_BIN_PATH=/usr/bin/lok GOTENBERG_VERSIONS_DIR_PATH=/opt/gotenberg/versions OTEL_TRACES_EXPORTER=none OTEL_METRICS_EXPORTER=none OTEL_LOGS_EXPORTER=none HOME=/tmp TMPDIR=/tmp LANG=C.UTF-8 LC_ALL=C.UTF-8`. Run `capture-version.sh` at build time for chromium, libreoffice and lok (as upstream) so nothing is written at runtime.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config` (kept for uniformity), `CMD ["/start.sh"]`. Final `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "gotenberg" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=gotenberg/gotenberg versioning=semver extractVersion=^v(?<version>.+)$
  default = "9.10.0"
}
variable "LOK_VERSION" {
  // renovate: datasource=github-releases depName=gotenberg/lok versioning=semver extractVersion=^v(?<version>.+)$
  default = "0.0.8"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/gotenberg/gotenberg" }
```
`target "image"` passes both `VERSION` and `LOK_VERSION` as args. Standard targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"` = `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/gotenberg/gotenberg"`.
- ports: `3000` tcp, `required: false`.
- env (documented gotenberg variables only): `TZ` (`Etc/UTC`); `API_PORT` (`3000`); `API_TIMEOUT` (`30s`); `LOG_LEVEL` (`info`); `CHROMIUM_AUTO_START` (`false`); `CHROMIUM_MAX_CONCURRENCY` (`6`); `CHROMIUM_RESTART_AFTER` (`100`); `LIBREOFFICE_AUTO_START` (`false`). All `required: false`; defaults equal upstream and `start.sh` passes them through untouched.
- volumes: `/config` `required: false` (stateless; listed for uniformity, unused).
- dependencies: none. Consumers: paperless-ngx (not a ContainerForge app yet, so no ✅).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export HOME=/tmp TMPDIR=/tmp
mkdir -p /tmp/gotenberg
exec gotenberg "$@"
```
Idempotent, nothing seeded in `/config`, nothing written outside `/tmp`. Gotenberg reads its own env vars, so no mapping is needed. It listens on `:${API_PORT}` (all interfaces); confirm from a second container. `tini` is PID 1 through the ubuntu entrypoint, which also reaps Chromium zombies.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /health
filePaths:
- /usr/bin/gotenberg
- /usr/bin/lok
- /usr/bin/chromium
- /usr/lib/libreoffice/program/soffice.bin
- /usr/share/licenses/gotenberg/LICENSE
```
Port 3000 has tcp and http probes. No env needed to start; conversions (Chromium, LibreOffice) are exercised by hand in section 11.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0 and `readOnlyRootFilesystem: false`; upstream itself runs as UID 1001 with `chgrp 0` for arbitrary UIDs. Here: UID 568 and read-only rootfs.
- Write paths: temp files, Chromium profile and caches, LibreOffice profile all go under `TMPDIR`/`HOME=/tmp` (draft says the Chromium profile must be under `/tmp`). Chromium's user-data-dir is derived from the temp dir (code reads `userProfileDirPath`; exact parent UNVERIFIED), so `/tmp` must be a tmpfs of adequate size.
- Chromium needs `/dev/shm`; give the container a `--shm-size` or mount a tmpfs there when running. Gotenberg already passes `--no-sandbox`, so no extra capabilities are needed (UNVERIFIED on a hardened seccomp profile).
- No extra persistence (draft lists `/data`, `/consume`, `/media` for the paperless-ngx main container, not this one).

## 10. Risks, caveats and open questions

- Chromium on Ubuntu 26.04 is snap-only; the plan relies on the third-party xtradeb PPA. Alternative if that is unacceptable: use Debian's chromium via a pinned multi-stage copy (large) or the Debian-based upstream approach. Decide with maintainers.
- lok binaries are linked against Debian trixie-backports LibreOffice headers; Ubuntu ships LibreOffice 26.2.7; compatibility UNVERIFIED. Fallback: build lok from source (`gotenberg/lok`, CGO, needs `libreoffice-dev`/headers) or run `gotenberg-chromium` variant only (`cmd/gotenberg-chromium/main.go`) and lose Office conversion.
- Large image and long build; arm64 needs native LibreOffice and Chromium builds (xtradeb arm64 availability UNVERIFIED).
- 9.10.0 is brand new; consider 9.9.x until it has settled.
- Only the gotenberg sidecar is covered; paperless-ngx (ghcr.io/paperless-ngx/paperless-ngx) needs PostgreSQL/Valkey and is a separate port.
- Chromium policy file for the compromised eMudhra roots must stay.

## 11. Build and test steps

```sh
cd apps/gotenberg
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gotenberg-probe --read-only --tmpfs /tmp --shm-size=256m -v gotenberg-probe-config:/config gotenberg:9.10.0
docker logs -f gotenberg-probe     # expect gotenberg logs showing the API listening on port 3000, no fatal module errors
curl -fsS http://<container-ip>:3000/health
curl -fsS -F url=https://example.com http://<container-ip>:3000/forms/chromium/convert/url -o /tmp/out.pdf
curl -fsS -F files=@sample.docx http://<container-ip>:3000/forms/libreoffice/convert -o /tmp/out2.pdf
docker rm -f gotenberg-probe; docker volume rm gotenberg-probe-config
forgetool containers test --image gotenberg:9.10.0 --config ./apps/gotenberg/container-test.yaml
```
Expected readiness signal: `/health` returns status `up` JSON and both conversions return a PDF.

## 12. PR checklist

- [ ] Branch `feat/add-gotenberg`, commit and title `feat(gotenberg): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] Bake and Dockerfile `VERSION` and `LOK_VERSION` aligned; `docker buildx bake --print` run.
- [ ] State untested items: arm64, lok against Ubuntu's LibreOffice, xtradeb Chromium behaviour under a read-only rootfs, real paperless-ngx integration.
