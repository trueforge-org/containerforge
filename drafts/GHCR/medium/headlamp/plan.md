# headlamp — implementation plan
> Source: ./draft.md · Target: apps/headlamp/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.46.0`, published 2026-10-15. Matches the chart's `ghcr.io/headlamp-k8s/headlamp:v0.46.0`. Source: https://api.github.com/repos/headlamp-k8s/headlamp/releases/tags/v0.46.0 (via `gh api`). |
| Renovate | `datasource=github-releases depName=headlamp-k8s/headlamp versioning=semver`. UNVERIFIED which repo name renovate resolves: release assets are served from `kubernetes-sigs/headlamp` (the repo redirects). Confirm when the bake is written. |
| License | Apache-2.0 (GitHub SPDX). `LICENSE` in `docker-bake.hcl` = `Apache-2.0`. |
| Source URL | https://github.com/headlamp-k8s/headlamp |
| Application binary amd64 | https://github.com/kubernetes-sigs/headlamp/releases/download/v0.46.0/Headlamp-0.46.0-linux-x64.tar.gz |
| Application binary arm64 | https://github.com/kubernetes-sigs/headlamp/releases/download/v0.46.0/Headlamp-0.46.0-linux-arm64.tar.gz |
| amd64 / arm64 | yes / yes (release tarballs) |
| Checksum source | Release digests from the GitHub API: amd64 `sha256:1747c5de63963be925ded64dc2a5308144d260e43452855169bc771f03846434`, arm64 `sha256:f209486c188b386f558aea39a860929f5f65d40d6546043062182a471b048ff3`. Also `checksums.txt` on the release (https://github.com/kubernetes-sigs/headlamp/releases/download/v0.46.0/checksums.txt, with `checksums.txt.sigstore.json`). |
| copy-from | no. Upstream image is `alpine:3.24.2` (musl), so `COPY --from` is not usable on glibc ubuntu. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/Dockerfile |
| Upstream stages | `backend-build` `golang:1.26.8` builds `./headlamp-server` from `./cmd/` with `CGO_ENABLED=0`; `frontend-build` `node:22` runs `npm ci --only=prod`; `frontend` runs `npm run build`; `static-plugins` runs `fetch-plugins.sh`; `final` creates user `headlamp`, copies `/headlamp/headlamp-server`, `/headlamp/frontend`, `/headlamp/plugins`, `/headlamp/static-plugins`. |
| Entrypoint | `ENTRYPOINT ["/headlamp/headlamp-server", "-html-static-dir", "/headlamp/frontend", "-plugins-dir", "/headlamp/plugins"]`. No CMD. |
| Port | `4466/tcp` (`EXPOSE 4466`). |
| Env (upstream) | `HEADLAMP_STATIC_PLUGINS_DIR=/headlamp/static-plugins`. |
| Data paths (upstream) | `/headlamp/plugins` (plugins). No VOLUME. |
| Release tarball layout | UNVERIFIED: the draft says `resources/headlamp-server` and `resources/frontend` inside the Electron tarball. Not confirmed by a fetched page; confirm with `tar tzf` in step 2. |
| Dependencies | none. Needs a Kubernetes cluster reachable by the operator (kubeconfig or in-cluster). |

Facts file: `/tmp/claude-0/-workspaces-containers/0a36f05f-588d-4ed0-a93b-79dc278b47c9/scratchpad/facts/123.md` (headlamp section).

## 2. Target layout

- `apps/headlamp/Dockerfile`
- `apps/headlamp/docker-bake.hcl`
- `apps/headlamp/settings.yaml`
- `apps/headlamp/container-test.yaml`
- `apps/headlamp/start.sh`

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, for both the download stage and the final stage. The runtime is a Go server plus static frontend, so no language base is needed. The draft's `apps/node` sibling does not exist; the closest pattern is `apps/adguardhome-sync` (prebuilt release tarball on ubuntu, `ARG VERSION`, `TARGETARCH`).

## 4. Dockerfile

1. Stage `fetch` from the ubuntu digest above:
   - `ARG VERSION` (`v0.46.0`), `ARG TARGETARCH`, `USER root`.
   - Map arch: `amd64` to `x64`, `arm64` to `arm64`.
   - Pin the checksum per arch in the Dockerfile (`ARG SHA256_AMD64`, `ARG SHA256_ARM64`, with the values from section 1) and verify: `echo "$SHA256  /tmp/headlamp.tar.gz" | sha256sum -c -`.
   - `curl -fL -o /tmp/headlamp.tar.gz "https://github.com/kubernetes-sigs/headlamp/releases/download/${VERSION}/Headlamp-${VERSION#v}-linux-${ARCH}.tar.gz"`.
   - Extract only what is needed: `tar xzf /tmp/headlamp.tar.gz -C /tmp/hl` (layout to be confirmed), then keep `resources/headlamp-server` and `resources/frontend` (UNVERIFIED paths).
   - Copy the upstream license and third-party notices (if present in the tarball) to `/usr/share/licenses/headlamp/`.
2. Final stage `FROM` the ubuntu digest:
   - `USER root`, `COPY --from=fetch --chmod=0755 /tmp/hl/resources/headlamp-server /app/headlamp/headlamp-server`, `COPY --from=fetch /tmp/hl/resources/frontend /app/headlamp/frontend`.
   - `chown -R apps:apps /app && chmod -R 755 /app`.
   - `ENV HOME=/config XDG_CACHE_HOME=/tmp`.
   - `USER apps`, `COPY --chmod=0755 . /`.
   - `EXPOSE 4466`, `VOLUME /config`, `WORKDIR /app/headlamp`.
   - `ENTRYPOINT ["/app/headlamp/start.sh"]` is not used: `start.sh` is the entrypoint via `CMD`-free `ENTRYPOINT` (see section 7).
3. Do not install apt packages; the base already has curl and tar.

Upstream's `static-plugins` stage and `HEADLAMP_STATIC_PLUGINS_DIR` are dropped: they need `fetch-plugins.sh` and `build-manifest.json`, which are not in the release tarball (UNVERIFIED that the tarball does not already embed them).

## 5. docker-bake.hcl

- `APP` = `headlamp`.
- `VERSION` = `v0.46.0` with `// renovate: datasource=github-releases depName=headlamp-k8s/headlamp versioning=semver` (the tag keeps its `v`; the Dockerfile strips it for the asset name, as `apps/adguardhome-sync` does).
- `LICENSE` = `Apache-2.0`.
- `SOURCE` = `https://github.com/headlamp-k8s/headlamp`.
- Standard targets as in `apps/adguardhome-sync/docker-bake.hcl`; `image-local` tag `${APP}:${VERSION}`.
- Validate with `docker buildx bake --print` in `apps/headlamp/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/headlamp-k8s/headlamp"
ports:
  - port: 4466
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Add no env names unless `start.sh` or the app reads them (for example kubeconfig: UNVERIFIED whether headlamp honors `KUBECONFIG`; do not list it until it is tested). `dependencies: []`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu
mkdir -p /config/plugins
cd /app/headlamp
exec ./headlamp-server -html-static-dir /app/headlamp/frontend -plugins-dir /config/plugins
```

- Idempotent: `mkdir -p` only.
- Plugins move from `/headlamp/plugins` (read-only in our layout) to `/config/plugins`, which is persistent.
- Nothing is written to `/app`.
- `exec` for signal handover.
- The image `ENTRYPOINT` is `/app/headlamp/start.sh` (set in the Dockerfile) or the `start.sh` at `/` per the `apps/adguardhome-sync` pattern. Pick the one that matches the sibling in step 4.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '4466'
http:
- port: '4466'
  path: /
```

- `tcp` for `4466` (the only port in `settings.yaml`).
- `http` on `/`: UNVERIFIED that `/` returns 200 with no kubeconfig. Keep it only if step 3 confirms; otherwise keep `tcp` alone and say so in the PR.
- `timeoutSeconds`: match sibling (`apps/it-tools` or `apps/adguardhome-sync`).
- No `filePaths` needed unless the server writes files at startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Adapted |
| --- | --- |
| `headlamp` user (uid from base) | `USER apps`. |
| `/headlamp/plugins` (static path) | `/config/plugins` (persistent). |
| Chart emptyDir `/.config` and `/headlamp/plugins` | `HOME=/config`, `XDG_CACHE_HOME=/tmp`. Chart's emptyDir is not needed. |
| `plugins.yaml` configmap mounted read-only | Not used. |
| Read-only rootfs | `/app` is not written at runtime. |

Run check: `docker run --read-only --tmpfs /tmp -v headlamp-probe-config:/config <image>`.

## 10. Risks, caveats and open questions

- The image is built from an Electron release tarball. The first build downloads roughly 100+ MB per arch from GitHub (size UNVERIFIED). Build time and network are the main cost.
- Tarball layout UNVERIFIED (see section 1). If `resources/` is not where the draft says, the `COPY` paths change; do not guess, list the tarball in step 2.
- Static plugins: the upstream image bakes plugins into `/headlamp/static-plugins`; this plan does not ship them. The UI works without them, but plugin parity with the chart's image is UNVERIFIED.
- Kubernetes access: without a reachable cluster the UI shows no data (draft inference, UNVERIFIED for this version). The container test cannot prove cluster access.
- Upstream release tarball is per-arch and pinned by digest here; a version bump changes all three values (URL, two digests).
- Blockers: none known. No GPU, no privileged need.

## 11. Build and test steps

1. `cd apps/headlamp && docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. In the build log, confirm the checksum passes and `tar tzf` shows the `resources/` layout.
3. Probe run: `docker run --rm -d --name headlamp-probe --read-only --tmpfs /tmp -v headlamp-probe-config:/config headlamp:v0.46.0`, then `docker logs -f headlamp-probe`. Expected readiness: the server's listen line on `4466` (wording UNVERIFIED) with the process still running and no fatal error.
4. Test: `forgetool containers test --image headlamp:v0.46.0 --config ./apps/headlamp/container-test.yaml`.
5. Cleanup: `docker rm -f headlamp-probe; docker volume rm headlamp-probe-config`.
6. arm64 build only if amd64 fails for arch-specific reasons.

## 12. PR checklist

- Branch `feat/add-headlamp`, commit and PR title `feat(headlamp): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, check only what applies.
- Notes section must contain `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it.
- Say what was not tested: arm64, the probe run, forgetool test, and the tarball layout if not confirmed.
