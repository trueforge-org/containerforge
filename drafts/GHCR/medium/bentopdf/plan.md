# bentopdf — implementation plan
> Source: ./draft.md · Target: apps/bentopdf/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.8.12`, published 2026-11-19 (GitHub latest release). Matches the draft tag and the chart image `ghcr.io/alam00000/bentopdf-simple:2.8.12`. Source: https://api.github.com/repos/alam00000/bentopdf/releases/latest |
| Renovate | `// renovate: datasource=github-releases depName=alam00000/bentopdf versioning=semver` (proposed; sibling precedent `apps/it-tools`) |
| License | AGPL-3.0 (GitHub-reported SPDX). Source: https://api.github.com/repos/alam00000/bentopdf. UNVERIFIED: LICENSE file not read; confirm before setting `LICENSE`. |
| Source URL | https://github.com/alam00000/bentopdf |
| Download (prebuilt) | `https://github.com/alam00000/bentopdf/releases/download/v2.8.12/dist-simple-2.8.12.zip` (134181686 bytes). Also `dist-2.8.12.zip` (full variant). Asset names confirmed from the release listing. |
| Download (source) | `https://github.com/alam00000/bentopdf/archive/refs/tags/v2.8.12.tar.gz` (tag archive, content-addressed by tag). |
| Per-arch | Output is arch-neutral static files. One artifact serves amd64 and arm64. |
| Checksum source | None published in the release assets (no SHA256 file). UNVERIFIED: no checksum source. Building from the tag archive avoids trusting an unsigned zip. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/alam00000/bentopdf/v2.8.12/Dockerfile. Build stage `node:26-alpine` runs `npm ci` then `npm run build:with-docs`, with `SIMPLE_MODE`, `BASE_URL`, `SITE_URL` (default https://www.bentopdf.com), `ALLOW_INDEXING` and `DISABLE_TOOLS` as build args. Final stage `quay.io/nginx/nginx-unprivileged:alpine-slim`, `USER nginx`, `EXPOSE 8080`, `CMD nginx -g "daemon off;"`. Copies `/app/dist` to `/usr/share/nginx/html${BASE_URL%/}` and runs `/docker-entrypoint.d/98-noindex.sh` and `99-disable-ipv6.sh`. |
| nginx.conf reviewed | https://raw.githubusercontent.com/alam00000/bentopdf/v2.8.12/nginx.conf (partial read): `pid /etc/nginx/tmp/nginx.pid;`, `listen 8080;`, `listen [::]:8080;`, `root /usr/share/nginx/html;`. The rest (temp paths, includes of `security-headers*.conf`) is UNVERIFIED until read in full. |
| Port | 8080/tcp (confirmed in nginx.conf and EXPOSE). `PORT=8080` is set in the upstream image but nginx.conf does not read it, so it is not a runtime knob. |
| Env vars (real) | Build-time only: `BASE_URL`, `SIMPLE_MODE`, `DISABLE_TOOLS`, `SITE_URL`, `ALLOW_INDEXING`, `DISABLE_GITHUB_STARS`, `VITE_*`. Runtime: `DISABLE_IPV6` (read by the upstream `nginx-ipv6.sh` entrypoint script, which is not fetched; UNVERIFIED). |
| Data and config write paths | None in the app. nginx writes its pid file to `/etc/nginx/tmp` (upstream). |
| Dependencies | None (static site). |
| Blockers | None found. Node build needs roughly 3 GB heap (`NODE_OPTIONS=--max-old-space-size=3072`). |

## 2. Target layout

- `apps/bentopdf/Dockerfile`
- `apps/bentopdf/docker-bake.hcl`
- `apps/bentopdf/settings.yaml`
- `apps/bentopdf/container-test.yaml`
- `apps/bentopdf/start.sh`: not needed. The nginx base's `docker-entrypoint.d` pattern covers config seeding.
- `apps/bentopdf/defaults/nginx.conf`: upstream `nginx.conf` with the pid path moved to `/tmp` and the security header includes adjusted to paths that exist in the image.
- `apps/bentopdf/defaults/default.conf`: only if the server block is split into a site file, as in `apps/it-tools/defaults/default.conf`. Otherwise drop it.
- `apps/bentopdf/docker-entrypoint.d/10-copyconfig.sh`: copies the defaults into `/config`, as in `apps/it-tools/docker-entrypoint.d/10-copyconfig.sh` and `apps/nginx/docker-entrypoint.d/03-copyconfig.sh`.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1`. This is the sibling pattern in `apps/it-tools/Dockerfile`, which serves a Vite-built SPA from `/usr/share/nginx/html`.
- Build stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, which provides node and npm. UNVERIFIED: the Node major version in that base must be checked against the `engines` field of upstream `package.json` (the upstream image uses Node 26).
- Why: the draft's "Alternative runtime image" (`python-node`) is not needed for serving. nginx is the right runtime. `python-node` is only used for the build step.

## 4. Dockerfile

1. Build stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:... AS builder`, `ARG VERSION`, `ARG SIMPLE_MODE=true`, `USER root`.
2. Fetch the source at the tag: `ADD https://github.com/alam00000/bentopdf.git#${VERSION} /src` (same pattern as `apps/it-tools`), or `curl -fsSL .../archive/refs/tags/${VERSION}.tar.gz`. Prefer the tarball, since `ADD` of a git ref pulls the whole history.
3. `ENV HUSKY=0 NODE_OPTIONS=--max-old-space-size=3072 SIMPLE_MODE=${SIMPLE_MODE} SITE_URL=https://www.bentopdf.com ALLOW_INDEXING=false`. Keep `npm config` retries from upstream.
4. `npm ci` then `npm run build:with-docs`, run in `/src` with `HOME=/tmp` and npm cache at `/tmp/npm`. The build does not write into `/app`.
5. Final stage `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:...`, `ARG VERSION`, `USER root`.
6. `COPY --from=builder --chown=568:568 /src/dist/ /usr/share/nginx/html`, as in `apps/it-tools`.
7. Copy the nginx config: `COPY --chmod=0755 ./defaults/ /defaults/`, and the entrypoint script into `docker-entrypoint.d/`.
8. Pid and temp paths: set `pid /tmp/nginx.pid;` in `defaults/nginx.conf`, and point any `*_temp_path` directives at `/tmp/...`. Create the dirs in the image if needed (`mkdir -p /tmp/nginx-temp /tmp/nginx-cache`, as in `apps/nginx/Dockerfile`).
9. License: copy `/src/LICENSE` to `/usr/share/licenses/bentopdf/LICENSE` from the builder stage.
10. `EXPOSE 8080`, `VOLUME /config`.
11. Tail, matching `apps/it-tools`:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
```

The nginx base's `CMD` (`nginx -c /config/nginx.conf -g "daemon off;"`) is inherited. Do not override it.

Note: `BASE_URL` is left empty, so the files are served from `/usr/share/nginx/html`. Do not add a sub-path build arg unless the user asks for one.

## 5. docker-bake.hcl

Copy `apps/it-tools/docker-bake.hcl` and change these values:

```hcl
variable "APP" { default = "bentopdf" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=alam00000/bentopdf versioning=semver
  default = "v2.8.12"
}
variable "LICENSE" { default = "AGPL-3.0-only" }   // UNVERIFIED: confirm against LICENSE file
variable "SOURCE" { default = "https://github.com/alam00000/bentopdf" }
```

Keep the four standard targets (`image`, `image-local`, `image-all`, `docker-metadata-action`) and `group "default" { targets = ["image-local"] }`. Add `SIMPLE_MODE` to `args` of `image` only if the build should be variant-selectable. Otherwise hard-code it in the Dockerfile to match the chart image (`bentopdf-simple`).

Validate with `docker buildx bake --print` from `apps/bentopdf/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/alam00000/bentopdf"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: DISABLE_IPV6
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`DISABLE_IPV6` is listed only because the upstream entrypoint script reads it. Drop it if that script is not shipped. No `dependencies`.

## 7. start.sh

Not needed. The nginx base's own entrypoint handles startup. The only seeding is `docker-entrypoint.d/10-copyconfig.sh`:

```bash
#!/usr/bin/env bash
echo "[10-copyconfig] Copying nginx config for BentoPDF"
mkdir -p /config/sites
cp -n /defaults/nginx.conf /config/nginx.conf
```

Rules: idempotent (`cp -n` never overwrites user edits), writes only to `/config`, nothing written to `/app` or `/usr/share/nginx/html`. If a `start.sh` is added later, it must `exec` nginx.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
- /defaults/nginx.conf
```

The `tcp` and `http` probes match the port in `settings.yaml`. UNVERIFIED: `apps/it-tools` and `apps/nginx` container-test.yaml set no `timeoutSeconds`; 60 is a guess. The test runs without env vars, which this app does not need.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/etc/nginx/tmp` (pid file, upstream `nginx.conf` line 1) | `/tmp/nginx.pid` in `defaults/nginx.conf` |
| nginx `*_temp_path` (client body, proxy, fastcgi; upstream default under `/var/cache/nginx`) | `/tmp/...`, confirmed only after reading the full upstream `nginx.conf` (UNVERIFIED) |
| `/etc/nginx/nginx.conf` | `/config/nginx.conf` (base CMD `-c /config/nginx.conf`) |
| `/etc/nginx/security-headers*.conf` | Ship them under `/defaults/`, then the `include` paths in the seeded `nginx.conf` must point to the same place. Or inline them. |
| `/docker-entrypoint.d/98-noindex.sh`, `99-disable-ipv6.sh` | Not shipped as-is. Re-create the behavior only if the env knobs are kept. `ALLOW_INDEXING` is build-time, so it is set in the build. |

Draft security expectations reconciled: the chart runs as UID 568 (matches `apps` in the nginx base), `readOnlyRootFilesystem: true` (compatible, since all runtime writes go to `/tmp` or `/config`), not privileged. The chart's `extra-persistence` of `/var/cache/nginx` and `/etc/nginx/tmp` is not needed in ContainerForge because nothing writes there.

Run check: `docker run --read-only --tmpfs /tmp` must serve `/` with the empty `/config` volume.

## 10. Risks, caveats and open questions

- Build from source vs the prebuilt zip: the zip has no checksum source. Building from the tag archive is preferred. Confirm that `SIMPLE_MODE=true` at build time gives the same output as `dist-simple-2.8.12.zip`.
- Node version of `python-node` (see section 3). If its Node major is below what the upstream `package.json` requires, the build fails, and the fix is a different base for the build stage, not the runtime.
- `npm ci` plus Vite needs roughly 3 GB of RAM at build time.
- The PDF tools run in the browser, so large files use the client's RAM and CPU (draft caveat, inferred). No container change needed.
- Full variant (`dist-2.8.12.zip`) is not in scope. The chart uses the simple image.
- WASM, OCR and CORS-proxy build args are optional. Leave them empty unless the user asks for air-gapped builds. The `VITE_CORS_PROXY_*` secrets are not needed.
- Version bumps are frequent (draft caveat). Renovate handles the bump.
- No blockers: no musl-only binary (node build stage runs on glibc here), no GPU, no privileged needs, arm64 is architecture-neutral output.

## 11. Build and test steps

```sh
cd apps/bentopdf
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bentopdf-probe --read-only --tmpfs /tmp \
  -p 8080:8080 -v bentopdf-probe-config:/config bentopdf:v2.8.12
docker logs -f bentopdf-probe
curl -sI http://127.0.0.1:8080/ | head -1
forgetool containers test --image bentopdf:v2.8.12 --config ./apps/bentopdf/container-test.yaml
docker rm -f bentopdf-probe; docker volume rm bentopdf-probe-config
```

Expected readiness signal: nginx logs without `[emerg]` and the `/` probe returns `HTTP/1.1 200`. The container stays up. `/config/nginx.conf` exists after first start and is not overwritten on restart.

Not in the standard suite: arm64 build (run `docker buildx bake image-all` or `--set image-local.platform=linux/arm64` as a separate step).

## 12. PR checklist

- Branch `feat/add-bentopdf`, commit and PR title `feat(bentopdf): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- `docker buildx bake --print` passes; `VERSION` in bake equals `ARG VERSION` in the Dockerfile.
- Untested to state honestly: the full Vite build inside the image, the `nginx.conf` temp paths on `--read-only`, the arm64 build, and the license SPDX (not verified from the LICENSE file).
