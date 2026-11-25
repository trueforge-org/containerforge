# wifi-card — implementation plan
> Source: ./draft.md · Target: apps/wifi-card/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No tags and no GitHub releases (`gh api repos/bndw/wifi-card/releases/latest` returns 404). Pin the commit the draft already names: `7a990dd2411f6c8758ad696bf737b509f9672953` (Dockerfile source). The default branch `master` HEAD equals this commit (checked via the GitHub API on 2026-11-25). |
| Renovate | UNVERIFIED: no release or tag. Use `datasource=git-refs depName=https://github.com/bndw/wifi-card currentValue=master` (precedent `apps/fenrus`, `apps/tvheadend`). |
| License | MIT (GitHub API `license.spdx_id` = `MIT`, https://github.com/bndw/wifi-card) |
| Source URL | https://github.com/bndw/wifi-card |
| Download | Source zip `https://github.com/bndw/wifi-card/archive/refs/heads/master.zip` (HTTP 200, `application/zip`). Pinning to the commit is preferred: `https://github.com/bndw/wifi-card/archive/${VERSION}.tar.gz`. Arch-neutral static source, no per-arch binary. |
| Checksum source | None published (no release). The commit-pinned archive is content-addressed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bndw/wifi-card/7a990dd2411f6c8758ad696bf737b509f9672953/Dockerfile: stage 1 `node:24-alpine` (`corepack enable`, `yarn install --immutable`, prettier check on `./src`, project build to `/app/dist`); stage 2 `nginx:stable-alpine` copies `dist` to `/usr/share/nginx/html`. No EXPOSE, USER, VOLUME, ENV, ENTRYPOINT or nginx config. |
| Build script name | `yarn build` (`vite build`, output `dist/`), confirmed in upstream `package.json` and the upstream Dockerfile (`RUN yarn build`, `COPY --from=builder /app/dist`). `packageManager` is `yarn@4.18.0` (corepack). |
| Port | 80 (nginx default, from upstream stage 2). ContainerForge nginx listens on 8080 (see section 3), so the container port is 8080. |
| Env vars | None read at runtime (static frontend). The draft's "runtime settings baked in at build" caveat is inferred, UNVERIFIED against the source. |
| Data paths | None (static frontend, no server state). |
| Helm chart | TrueCharts `charts/stable/wifi-card` runs `docker.io/bndw/wifi-card:latest`, as UID 0 (draft). Not fetched in this run. |

## 2. Target layout

- `apps/wifi-card/Dockerfile`
- `apps/wifi-card/docker-bake.hcl`
- `apps/wifi-card/settings.yaml`
- `apps/wifi-card/container-test.yaml`
- `apps/wifi-card/start.sh` is NOT needed (the nginx base CMD already runs nginx in the foreground, see section 7)

No `defaults/`, `etc/` or `health/` needed unless the nginx site config must change (then add `etc/nginx/...` with the reason). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Build stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (provides Node for the Yarn build, per the draft). UNVERIFIED: Node major version in this base; check `node --version` in the build. Yarn via `corepack enable` as upstream.
- Final stage: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. Fits: serves static files on 8080 and already runs as `apps`. Closest sibling: `apps/it-tools` (static frontend on nginx) and `apps/theme-park`.

Rationale for not using `node:24-alpine` (upstream): musl build stage; ContainerForge builds on glibc. The dist output is arch-neutral JS/CSS/HTML, so the build can run on the python-node base. Alternative: the ubuntu base with Node installed by apt (not confirmed to exist in the archive; UNVERIFIED).

## 4. Dockerfile

1. Build stage: `FROM <python-node digest> AS build`, `ARG VERSION`, `USER root`.
2. `ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 YARN_CACHE_FOLDER=/tmp/yarn`. Caches to `/tmp` only.
3. `curl -fL https://github.com/bndw/wifi-card/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (VERSION = commit SHA).
4. `cd /tmp/src && corepack enable && yarn install --immutable && yarn build`. Output `/tmp/src/dist`.
5. Final stage: `FROM <nginx digest>`, `USER root` only if needed for the copy/chmod.
6. `COPY --from=build /tmp/src/dist/ /usr/share/nginx/html/` (exact nginx web root confirmed by base image config: UNVERIFIED, check `nginx -T` in step 11).
7. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/wifi-card/LICENSE`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

Keep `VOLUME /config`: the `apps/nginx` base starts `nginx -c /config/nginx.conf` (seeded from its `defaults/`), so `/config` is used by nginx itself even though the app has no state. Follow `apps/it-tools` (same nginx base and digest, copies the dist to `/usr/share/nginx/html`, `COPY --chmod=0755 . /`, `WORKDIR /usr/share/nginx/html`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wifi-card" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/bndw/wifi-card currentValue=master
  default = "7a990dd2411f6c8758ad696bf737b509f9672953"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/bndw/wifi-card" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`. The Dockerfile consumes the same value through `ARG VERSION`.

Note: the pinned commit is the Dockerfile's commit. If the source is pinned to a newer master commit, both must still match. Pick one commit for both.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bndw/wifi-card"
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
    required: false
dependencies: []
```

No runtime env vars are confirmed; do not invent any. `/config` is listed because the nginx base reads `/config/nginx.conf` (section 4). Dependencies: none (draft confirms no hard or optional dependency containers).

## 7. start.sh

No `start.sh`: the `apps/nginx` base has `CMD ["nginx", "-c", "/config/nginx.conf", "-g", "daemon off;"]` and seeds `/config/nginx.conf` from its own defaults (`apps/it-tools` ships no `start.sh` either). Skip this file unless the build shows the base config does not serve `/usr/share/nginx/html` on 8080 (then add `defaults/` as `apps/it-tools` does, with the reason). No writes to `/app`. Nginx temp and cache dirs are `/tmp/nginx-temp` and `/tmp/nginx-cache` in the base. Bind and web root: confirm in step 11.

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
- /usr/share/licenses/wifi-card/LICENSE
```

The `index.html` path is a file the build output must contain. UNVERIFIED that `dist/index.html` is the entry point; confirm from the build.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| nginx temp/cache (`/var/cache/nginx`, pid file) | `/tmp` via the nginx base (`apps/nginx/Dockerfile` creates `/tmp/nginx-temp`, `/tmp/nginx-cache`). Confirm pid path in the base config. |
| Static web root | Read-only copy under `/usr/share/nginx/html`, written at build only. |
| Yarn/Node caches | `/tmp` (build stage only, not in the final image). |

Reconciling the draft's security expectations: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. The image runs as `apps` and works with `--read-only --tmpfs /tmp`, so the chart can be tightened later. Not privileged. No extra persistence.

## 10. Risks, caveats and open questions

- No release or tag: Renovate tracks master commits, which creates churn. Pin the commit; accept churn or add a schedule limit.
- Static frontend: any runtime config must be built in. Confirm in the source whether a config file is read at runtime (UNVERIFIED).
- Upstream builder is musl (`node:24-alpine`). The glibc build on python-node may differ in Yarn/Node behaviour. Build the commit and check the output.
- No blockers identified: not privileged, no GPU, arm64 is not a concern for an arch-neutral static build (confirm by `bake` `image-all`).

## 11. Build and test steps

```sh
cd apps/wifi-card
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wifi-card-probe --read-only --tmpfs /tmp \
  -v wifi-card-probe-config:/config wifi-card:7a990dd2411f6c8758ad696bf737b509f9672953
docker logs -f wifi-card-probe
docker exec wifi-card-probe nginx -T | head -60   # confirm web root and listen port
forgetool containers test --image wifi-card:7a990dd2411f6c8758ad696bf737b509f9672953 --config ./apps/wifi-card/container-test.yaml
docker rm -f wifi-card-probe; docker volume rm wifi-card-probe-config
```

Expected readiness signal: nginx stays running with no `[emerg]` lines; `curl -I http://localhost:8080/` returns 200 from inside the container.

## 12. PR checklist

- Branch `feat/add-wifi-card`, commit and PR title `feat(wifi-card): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested (state honestly in the PR): the Yarn build on python-node, the nginx listen port and web root, the read-only run, and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
