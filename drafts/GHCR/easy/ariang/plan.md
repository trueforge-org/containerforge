# ariang — implementation plan
> Source: ./draft.md · Target: apps/ariang/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **1.3.15** (latest stable; https://github.com/mayswind/AriaNg/releases/tag/1.3.15). The draft and TrueCharts chart pin 1.3.13 (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ariang/Chart.yaml, appVersion 1.3.13). |
| Renovate | `datasource=github-releases depName=mayswind/AriaNg versioning=semver` (the upstream image's own Dockerfile uses the same annotation: https://raw.githubusercontent.com/leonismoe/docker-images/3b6bca6db6513787ad225d555778f7f31c7d3f36/ariang/Dockerfile) |
| License | MIT (https://raw.githubusercontent.com/mayswind/AriaNg/master/LICENSE, "Copyright (c) 2016-2026 MaysWind"). The zip contains `LICENSE` at its root. |
| Source URL | https://github.com/mayswind/AriaNg |
| Download | `https://github.com/mayswind/AriaNg/releases/download/${VERSION}/AriaNg-${VERSION}.zip` (HTTP 200, 1161055 bytes for 1.3.15). Arch-independent static files. |
| Checksum source | No checksum is published by upstream (`AriaNg-1.3.15.zip.sha256` returns 404). Two independent downloads of the 1.3.15 zip gave sha256 `d2317e441966ad31f1e342cb6a6cc1c51808fb0a10cf6e39cb30b0517b3e7823`. Pin it as an ARG and verify at build time (see section 4). This is our own hash, not an upstream one. |
| Upstream image | `ghcr.io/leonismoe/ariang:1.3.13`, built by the Dockerfile above: alpine:edge (musl) stage downloads the zip and builds darkhttpd, final `FROM scratch`, `EXPOSE 8080`, `ENTRYPOINT ["/darkhttpd"]`, `CMD ["/www", "--chroot", "--uid", "nobody", ...]`. Static musl, so `copy-from` is **no** (the draft's rule for musl builds). We do not copy the binary; we serve the zip with the nginx base. |
| Port | 8080 (upstream EXPOSE and darkhttpd `--port 8080`). The draft's "80/http" is inferred and not confirmed. |
| Env vars | None. The upstream Dockerfile declares no ENV. Settings live in the browser's local storage. |
| Data / config paths | None on the server. The static site only. |
| Dependencies | None inside the container. The UI needs a reachable aria2 RPC endpoint from the browser (a separate service, not a ContainerForge dependency). |
| Arch | amd64 yes, arm64 yes (same zip for both). |
| Apt packages | `curl` and `tar` are used by other ContainerForge apps on the ubuntu base (`apps/kopia/Dockerfile`), so they are available there. `unzip` is not confirmed in the base: UNVERIFIED. Install it in the build stage only if missing. |

## 2. Target layout

- `apps/ariang/Dockerfile`
- `apps/ariang/docker-bake.hcl`
- `apps/ariang/settings.yaml`
- `apps/ariang/container-test.yaml`
- `apps/ariang/start.sh` is **not** needed: the nginx base runs its own `docker-entrypoint.d` scripts (see section 4). Add it only if a startup step is required beyond copying the nginx config.
- `apps/ariang/defaults/default.conf` (nginx server block, the it-tools pattern)
- `apps/ariang/docker-entrypoint.d/10-copyconfig.sh` (seeds `/config/sites/default.conf`)

No `etc/`, `root/`, `DOWNSTREAM_CHANGES.md` (not a FROM base). Use the `defaults/` and `docker-entrypoint.d/` paths that `include/.dockerignore` already allows.

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (digest from the brief's current base-image list).

Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (only used to download and unpack the zip).

Closest sibling: `apps/it-tools` (static SPA served by nginx from a release, same two-stage layout, `defaults/default.conf` listening on 8080). Copy its patterns.

## 4. Dockerfile

Two stages, following `apps/it-tools/Dockerfile`:

1. Build stage on the ubuntu base:
   - `ARG VERSION` and `ARG ARIANG_SHA256`, both matching `docker-bake.hcl`/renovate (see section 5).
   - `USER root`; `apt-get install -y --no-install-recommends unzip` (not in base: UNVERIFIED), then `apt-get clean` and remove lists.
   - `curl -fsSL -o /tmp/ariang.zip https://github.com/mayswind/AriaNg/releases/download/${VERSION}/AriaNg-${VERSION}.zip`
   - `echo "${ARIANG_SHA256}  /tmp/ariang.zip" | sha256sum -c -` (fail the build on mismatch).
   - `mkdir -p /tmp/dist && unzip -q /tmp/ariang.zip -d /tmp/dist`.
2. Runtime stage on the nginx base:
   - `USER root`, `COPY --from=build --chown=568:568 /tmp/dist/ /usr/share/nginx/html`, then `COPY --chmod=755 ./ /` for `defaults/` and `docker-entrypoint.d/`.
   - Licence: copy `/tmp/dist/LICENSE` from the build stage to `/usr/share/licenses/ariang/LICENSE` (`COPY --from=build` into that path). The web root keeps its own copy from the zip, which is harmless.
   - Keep the nginx base's own tmp/log symlinks; do not change them.
   - `EXPOSE 8080`, `VOLUME /config` (neither `apps/nginx` nor `apps/it-tools` declares it; add per repo rule), `USER apps`, `COPY --chmod=0755 . /`.
   - Do not set `CMD`/`ENTRYPOINT`: the nginx base already runs `nginx -c /config/nginx.conf -g "daemon off;"`.

Key snippet (runtime stage tail):

```dockerfile
USER apps
COPY --chmod=0755 . /
EXPOSE 8080
VOLUME /config
```

The `ARIANG_SHA256` ARG value is the sha256 in section 1.

## 5. docker-bake.hcl

Copy the `it-tools` layout, with these variables:

```hcl
variable "APP" { default = "ariang" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=mayswind/AriaNg versioning=semver
  default = "1.3.15"
}
variable "ARIANG_SHA256" { default = "d2317e441966ad31f1e342cb6a6cc1c51808fb0a10cf6e39cb30b0517b3e7823" }
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/mayswind/AriaNg" }
```

- Four standard targets (`image`, `image-local`, `image-all`, `docker-metadata-action`) and `group "default" { targets = ["image-local"] }`. Pass `ARIANG_SHA256` in `args` of `image`.
- `image-all` platforms: `linux/amd64` and `linux/arm64` (the nginx base is multi-arch; the zip is arch-independent).
- Validate with `docker buildx bake --print` from `apps/ariang/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mayswind/AriaNg"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- No app env vars (the UI has none). Do not list the chart's `SYS_CHROOT` or any other security settings here.
- `dependencies`: none. The aria2 RPC endpoint is configured in the browser, so it is not a dependency.
- `/config` holds only the nginx config (`/config/nginx.conf`, `/config/sites/default.conf`) seeded at start.

## 7. start.sh

Not needed (see section 2). The seeding step is `docker-entrypoint.d/10-copyconfig.sh`:

```bash
#!/usr/bin/env bash

echo "[10-copyconfig] Seeding nginx site config for AriaNg"
mkdir -p /config/sites
cp -n /defaults/default.conf /config/sites/default.conf
```

`cp -n` (not `cp`, as `it-tools` does) follows the start-script rule: seed only when missing, do not overwrite user state. `defaults/default.conf` is the `it-tools` server block with `listen 8080`, `root /usr/share/nginx/html`, and `try_files $uri $uri/ /index.html`. Do not write to `/usr/share/nginx/html` at runtime.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/nginx/html/js/aria-ng-c92dd15ec8.min.js
- /usr/share/licenses/ariang/LICENSE
- /config/sites/default.conf
```

- One `tcp` and one `http` probe for port 8080 (coverage minimum). `http` path `/` expects 200 on `index.html`.
- `filePaths` proves the unpack and the seeded config. The JS filename has a content hash that changes with the release, so **verify the name in the 1.3.15 zip listing before publishing** (it is `js/aria-ng-c92dd15ec8.min.js` in that zip). Prefer `index.html` and `LICENSE` if the hash makes the test brittle.
- No `timeoutSeconds` needed beyond the sibling default (`it-tools` has none); use the sibling family default.
- No env-gated code paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this plan |
| --- | --- |
| Upstream darkhttpd `--chroot` as `nobody` | Not used. nginx base runs as `apps` (UID 568) and listens on 8080 (no privileged port, no capability needed). |
| Upstream image state | None. Static files only. |
| nginx temp/cache | `/tmp/*` (nginx base already sets `client_body_temp_path`, `proxy_temp_path`, `proxy_cache_path /tmp/nginx-cache`). |
| nginx config | `/config/nginx.conf` (seeded by the base's `03-copyconfig.sh` with `cp -n`), `/config/sites/default.conf` (our `10-copyconfig.sh`). |
| Web root | `/usr/share/nginx/html` is read-only at runtime (owned by 568, not written). |

Draft security expectations reconciled with the plan:
- non-root: yes (`USER apps`), not chart `runAsUser 0`.
- read-only-rootfs: yes; test with `--read-only --tmpfs /tmp`.
- privileged: no.
- other-security: drop `SYS_CHROOT` and `allowPrivilegeEscalation: true`; neither is needed for a static nginx server on 8080.
- extra persistence: none.

## 10. Risks, caveats and open questions

- **Version drift**: the chart pins 1.3.13; this plan targets 1.3.15. A deliberate bump is needed in TrueCharts and downstream charts, not here. Renovate keeps `VERSION` current.
- **Checksum**: upstream publishes none. The pinned sha256 is our own hash of the zip, confirmed by two downloads. If upstream republishes the asset, the build fails by design (review, do not just update the hash).
- **`unzip` in the ubuntu base**: UNVERIFIED. If it is missing, install it in the build stage only (it is a build tool, not runtime).
- **Hashed filenames in the zip** (`aria-ng-<hash>.min.js`) change between releases; avoid them in `filePaths` if possible (section 8).
- **Port**: draft said 80; upstream and this plan use 8080. Confirm the chart's service port in TrueCharts only if a downstream chart needs port 80 (UNVERIFIED).
- **Runtime dependency**: the UI is useless without an aria2 RPC endpoint reachable from the browser (inferred; the README was not fetched).
- **Blockers**: none. Not musl-only, no GPU, not privileged, arm64 supported.

## 11. Build and test steps

```sh
cd apps/ariang
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ariang-probe --read-only --tmpfs /tmp \
  -v ariang-probe-config:/config ariang:1.3.15
docker logs -f ariang-probe
forgetool containers test --image ariang:1.3.15 --config ./apps/ariang/container-test.yaml
docker rm -f ariang-probe; docker volume rm ariang-probe-config
```

- Readiness signal: nginx logs no `[emerg]` lines and the process stays up; `curl -fsS http://127.0.0.1:8080/` returns the AriaNg `index.html`.
- Empty `/config` must seed `/config/sites/default.conf`; a second start with the same volume must not overwrite it.
- Also check that port 8080 answers from outside the container (`docker run -p 8080:8080`), not only inside.
- Build arm64 only if the amd64 build fails in an arm64-specific way (protocol rule).

## 12. PR checklist

- Branch `feat/add-ariang`, commit and PR title `feat(ariang): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections; only tick boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested if the image is not built or run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; `ARIANG_SHA256` matches the zip; no assertion weakened.
- Downstream: ariang is not a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
