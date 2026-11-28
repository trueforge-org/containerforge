# grafana-image-renderer — implementation plan
> Source: ./draft.md · Target: apps/grafana-image-renderer/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 5.12.12 (tag `v5.12.12`, published 2026-11-11, marked Latest; matches the draft links) |
| Renovate | `datasource=github-releases depName=grafana/grafana-image-renderer versioning=semver` (tags have a `v` prefix, Dockerfile builds URL with `v${VERSION#v}`) |
| License | AGPL-3.0 (SPDX `AGPL-3.0-only`; UNVERIFIED: confirm LICENSE header) |
| Source URL | https://github.com/grafana/grafana-image-renderer |
| amd64 URL | https://github.com/grafana/grafana-image-renderer/releases/download/v5.12.12/grafana-image-renderer-linux-amd64 (raw executable) |
| arm64 URL | https://github.com/grafana/grafana-image-renderer/releases/download/v5.12.12/grafana-image-renderer-linux-arm64 |
| Checksums | GitHub API asset digests: amd64 `sha256:fc6419daa002fffb3f6f6f5d68c9bad1e52346f59ec4801251a0650ba9822f69`, arm64 `sha256:18ed121c7860695a90865790aa95e66422c06ae9502af19e0d0e725744d5eda7`. No separate checksum file published. Digests change per version, so the Dockerfile cannot hardcode them next to a renovated VERSION; fetch the digest at build time from `https://api.github.com/repos/grafana/grafana-image-renderer/releases/tags/v${VERSION}` (jq is in the ubuntu base) and verify with `sha256sum -c`. |
| Upstream Dockerfile | Reviewed (master). Go builder (`CGO_ENABLED=0`, static) into Debian trixie. Installs fonts (ipaexfont-gothic, wqy-zenhei, thai-tlwg, khmeros, kacst-one, freefont-ttf, unifont, open-sans, roboto, inter, fonts-recommended), libxss1, bash, util-linux, openssl, tini, ca-certificates, locales, libnss3-tools, and `chromium chromium-driver chromium-shell chromium-sandbox` (each at least 156.0.8078.108). `ENV CHROME_BIN=/usr/bin/chromium LANG/LC_ALL=en_US.UTF-8`, `EXPOSE 8081`, `ENTRYPOINT tini -- /usr/bin/grafana-image-renderer`, `CMD server`, HEALTHCHECK `grafana-image-renderer healthcheck`, runs as UID 65532. |
| Config (v5 docs) | `--server.addr` / env `SERVER_ADDR` default `:8081` (all interfaces); `--server.auth-token` / env `AUTH_TOKEN` default `-` (comma-separated for several); `--browser.flag` / env `BROWSER_FLAGS` or `BROWSER_FLAG` (format `--flag=value`, space-separated); TLS `SERVER_CERTIFICATE_FILE`, `SERVER_KEY_FILE`. Source: grafana.com image-rendering flags doc. |
| Ports | 8081/tcp http |
| Dependencies | none |

## 2. Target layout

```
apps/grafana-image-renderer/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No other directories. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Prebuilt static Go binary on ubuntu (no Go stage needed since upstream ships a release binary). Closest siblings: `apps/adguardhome-sync` (binary download) and `apps/changedetection` (headless browser via Playwright, which this plan reuses).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/tmp LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 CHROME_BIN=/app/chromium/chrome` (path finalised after step 4).
2. apt: `fonts-liberation fonts-noto-cjk fonts-freefont-ttf fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst-one fonts-unifont fonts-open-sans fonts-roboto fonts-inter libnss3-tools libxss1` plus the shared libraries Chromium needs. Skip `tini`, `bash`, `openssl`, `ca-certificates`, `curl`, `jq`, `tzdata`, `locales` handling as already in the ubuntu base (re-check `apps/ubuntu/Dockerfile` before adding). Exact package names on Ubuntu 26.04 UNVERIFIED; drop any that do not resolve.
3. Chromium source (main build risk; the `chromium` apt package on Ubuntu is a snap stub and unusable in a container). Plan A: install the Playwright-managed Chromium, which has linux amd64 and arm64 builds: `PLAYWRIGHT_BROWSERS_PATH=/app/browsers npx --yes playwright@<pinned, renovate datasource=npm depName=playwright> install chromium` (node comes from the ubuntu base), then symlink or set `CHROME_BIN` to the `chrome` binary, and run `playwright install-deps chromium` equivalent via apt (UNVERIFIED that Ubuntu 26.04 is supported by that script). Plan B (fallback): add the Debian trixie repo with a signed-by keyring and apt pinning limited to `chromium*`, as upstream uses Debian. Choose A first, record outcome in the PR. Upstream pins a minimum Chromium of 156.0.8078.108; whichever source is used must be a recent stable.
4. Download binary with `curl -fsSL` to `/usr/local/bin/grafana-image-renderer`, URL `.../releases/download/v${VERSION#v}/grafana-image-renderer-linux-${TARGETARCH}`; verify sha256 from the release API digest; `chmod 0755`.
5. Licenses: `curl` the repo `LICENSE` at the tag into `/usr/share/licenses/grafana-image-renderer/LICENSE` (the binary is statically linked, so also note Go module notices are not shipped; UNVERIFIED if upstream ships a NOTICE file).
6. Clean `/var/lib/apt/lists`, `/tmp/*`.
7. `COPY --chmod=0755 . /`, `EXPOSE 8081`, `VOLUME /config`, `WORKDIR /tmp`, `USER apps`.

## 5. docker-bake.hcl

`APP = "grafana-image-renderer"`, `LICENSE = "AGPL-3.0-only"`, `SOURCE = "https://github.com/grafana/grafana-image-renderer"`, `VERSION` default `"5.12.12"` under `// renovate: datasource=github-releases depName=grafana/grafana-image-renderer versioning=semver`. Standard targets: `docker-metadata-action`, `image` (args VERSION, labels), `image-local`, `image-all` (amd64+arm64), group default `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/grafana/grafana-image-renderer"`.
- ports: `8081 tcp required: false`.
- env: `SERVER_ADDR` (`":8081"`), `AUTH_TOKEN` (`"-"`; matches upstream default, set to a secret in production, Grafana `GF_RENDERING_RENDERER_TOKEN` must match), `BROWSER_FLAGS` (default `"--no-sandbox --disable-dev-shm-usage"`, applied by start.sh), `CHROME_BIN` (path), `TZ` (`"Etc/UTC"`). All `required: false`.
- volumes: `/config` required false (nothing persisted; kept for the standard layout; no state is documented as persistent).
- dependencies: none.

## 7. start.sh

- `#!/usr/bin/env bash`; export `HOME=/tmp`, `XDG_CONFIG_HOME=/tmp/.config`, `XDG_CACHE_HOME=/tmp/.cache`; `mkdir -p` those.
- Default `SERVER_ADDR=:8081` (all interfaces) and `BROWSER_FLAGS` when unset. Warn in log when `AUTH_TOKEN` is the default `-`.
- `exec grafana-image-renderer server` (tini is PID 1 from the base; upstream uses `tini --`, the repo handoff is automatic). Do not put the token on the command line; rely on env `AUTH_TOKEN`.
- Never write to `/app` or `/usr`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8081'
filePaths:
- /usr/local/bin/grafana-image-renderer
- /start.sh
- /usr/share/licenses/grafana-image-renderer/LICENSE
```

Optionally add `http` port 8081 path `/` only after confirming it returns 2xx (UNVERIFIED; check `/healthz` or similar from upstream source). Timeout 120 is a guess from sibling changedetection (180); use 180 if Chromium start is slow.

## 9. Rootless and read-only-rootfs adaptations

- Draft: chart runs UID 0, writable rootfs; target is UID 568 with read-only rootfs.
- Chromium writes profile, crashpad and cache dirs: force them to `/tmp` via `HOME=/tmp`, `XDG_*`, and a `--user-data-dir` default in browser flags if the renderer does not already create a temp dir (UNVERIFIED). Add `--disable-dev-shm-usage` since `/dev/shm` is small and `/tmp` is a ramdisk.
- The chromium setuid sandbox is not available rootless without privileges; default `--no-sandbox` (flagged as a security trade-off in the PR). Upstream uses `chromium-sandbox` setuid helper as a non-root user.
- No extra persistence (matches draft).

## 10. Risks, caveats and open questions

- Browser source on Ubuntu (snap issue): Plan A/Plan B above; this decides feasibility. No arm64 Debian fallback issue expected, Playwright publishes arm64 Chromium.
- Binary is useless alone: it only serves a Grafana instance; tests prove only that the server listens.
- `latest` tag in the chart means version drift; document the pin.
- Fonts list is large; image size grows.
- Not a blocker: no GPU, no privileged.

## 11. Build and test steps

```sh
cd apps/grafana-image-renderer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name grafana-image-renderer-probe --read-only --tmpfs /tmp \
  -v grafana-image-renderer-probe-config:/config grafana-image-renderer:5.12.12
docker logs -f grafana-image-renderer-probe
forgetool containers test --image grafana-image-renderer:5.12.12 --config ./apps/grafana-image-renderer/container-test.yaml
docker rm -f grafana-image-renderer-probe; docker volume rm grafana-image-renderer-probe-config
```

Also request a real render from the host: `curl -H 'X-Auth-Token: <token>' 'http://localhost:8081/render?url=https://example.com'` style call (endpoint UNVERIFIED, check upstream docs) to prove Chromium launches. Expected readiness log: a server "listening" line on `:8081` (exact text UNVERIFIED).

## 12. PR checklist

- Branch `feat/add-grafana-image-renderer`; commit and title `feat(grafana-image-renderer): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA reminder: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Version alignment bake/Dockerfile, `USER apps`, empty `/config`, read-only rootfs.
- Untested at plan time: build, run, Chromium package choice, render request, arm64, exact apt package names and license identifier.
