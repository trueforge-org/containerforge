# tasmocompiler — implementation plan
> Source: ./draft.md · Target: apps/tasmocompiler/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v14.0.3 (latest release per GitHub API, published 2026-11-17). Source: https://api.github.com/repos/benzino77/tasmocompiler/releases/tags/v14.0.3 . The chart's `:latest` tag is rolling and may diverge from v14.0.3 (draft caveat, not verified against the image digest). |
| Renovate | `datasource=github-tags depName=benzino77/tasmocompiler versioning=semver` (best judgement; no renovate config checked for this app). |
| License | MIT (GitHub API `spdx_id`). Source: https://api.github.com/repos/benzino77/tasmocompiler |
| Source URL | https://github.com/benzino77/tasmocompiler |
| Download | No release assets. The artifact is the source at git tag v14.0.3, for example `https://github.com/benzino77/tasmocompiler/archive/refs/tags/v14.0.3.tar.gz` (URL shape not fetched; UNVERIFIED that the archive endpoint is used). |
| Checksum source | UNVERIFIED: none published. Git tag only. The tarball is pinned by tag. The tag v14.0.3 resolves to commit `082abee9ea59cdc653fe107b086358e957670575` (GitHub API). The draft's Dockerfile link points to a different commit, `1c863599ac02b435ffb2e8aa907fff9da5829296`, so that Dockerfile is not the v14.0.3 one; re-read the Dockerfile at the v14.0.3 tag before porting. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/benzino77/tasmocompiler/1c863599ac02b435ffb2e8aa907fff9da5829296/Dockerfile : `FROM node:22-bookworm-slim`; apt installs python3, git, python3-setuptools, python3-pip, python3-venv; `npm install -g nodemon`; copies public, server, src, package.json, package-lock.json to `/tasmocompiler`; `npm ci`, `npm run build`, `chown -R node:node`; removes React/MUI frontend packages (comment calls it "a rather dirty hack"); as `node` creates `/home/node/.platformio/penv` with uv and `pioarduino==6.2.0`; `ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 PATH=/home/node/.platformio/penv/bin:/home/node/.local/bin:$PATH`; `WORKDIR /tasmocompiler`; `USER node`; `EXPOSE 3000/tcp`; no VOLUME; `ENTRYPOINT ["nodemon", "server/app.js"]`, no CMD. |
| Ports | 3000/tcp (upstream EXPOSE). Confirms the draft's 3000/http, with the protocol corrected to tcp for the probe. |
| Env vars | Only `LC_ALL`, `LANG`, `PATH` are confirmed, and they are image env, not app config. UNVERIFIED: any app-level env var (server/app.js was not fetched). Do not list env vars in settings.yaml until the source is read. |
| Write paths | `/tasmocompiler` (build output, owned by node), `/home/node/.platformio` (PlatformIO home, venv, toolchains at runtime). |
| arm64 | UNVERIFIED: PlatformIO toolchains for arm64 were not checked. The Node app itself is arch-independent. |
| copy-from | Not applicable as a binary: the app is a Node source tree, so the draft's `COPY --from=ghcr.io/benzino77/tasmocompiler:latest` is not used. Build from the tagged source instead. |

## 2. Target layout

- `apps/tasmocompiler/Dockerfile`
- `apps/tasmocompiler/docker-bake.hcl`
- `apps/tasmocompiler/settings.yaml`
- `apps/tasmocompiler/container-test.yaml`
- `apps/tasmocompiler/start.sh`
- No `app/` folder: the built Node tree reaches `/app/tasmocompiler` through `COPY --from=build` (section 4), not through `COPY . /`. No `defaults/`, `etc/` or `health/` unless the source needs them (UNVERIFIED).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because the app is Node and calls PlatformIO, a Python tool, so the python-node base covers both. The draft's choice is kept. Closest siblings: `apps/budge` (same python-node:3.15.2 digest) and `apps/changedetection` (python-node:3.14.8). UNVERIFIED: the Node major shipped in python-node:3.15.2; the upstream Dockerfile uses Node 22, so check it in the build and record it. If the base's Node is not 22, the `npm ci` step must still work, and the mismatch goes in section 10.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `USER root`.
2. Fetch the v14.0.3 source (tarball or git checkout at the tag). Verify against the tag's commit SHA `082abee9ea59cdc653fe107b086358e957670575` (section 1 checksum note).
3. `npm ci` and `npm run build` in the build stage, with `npm` cache under `/tmp` (`ENV npm_config_cache=/tmp/npm`).
4. Do not copy the upstream "remove frontend packages" hack unless the backend needs it. Instead run `npm prune --omit=dev` after the build, to keep the image small without deleting packages by name. UNVERIFIED that this keeps the server working; test it.
5. Final stage `FROM <python-node>`, `USER root` for installs only:
   - PlatformIO into a venv that is not under `/config`: a venv at `/app/venv-pio` is also valid at build time (read-only at runtime). This plan puts the venv in `/usr/local/lib/platformio-venv` and installs `pioarduino==6.2.0` and `uv` there. The pinned version comes from the upstream Dockerfile at the draft's commit, not re-checked at the v14.0.3 tag (UNVERIFIED).
   - `COPY --from=build` the built app into `/app/tasmocompiler/`.
   - License: `/usr/share/licenses/tasmocompiler/LICENSE`.
6. `ENV PLATFORMIO_CORE_DIR=/tmp/platformio HOME=/tmp/home LC_ALL=C.UTF-8 LANG=C.UTF-8 PATH=/usr/local/lib/platformio-venv/bin:$PATH`. PlatformIO caches and toolchains go to `/tmp`, never `/config` (brief and protocol rule).
7. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config` (declared regardless; whether the app persists state there is UNVERIFIED, see section 7), `WORKDIR /app/tasmocompiler`.

## 5. docker-bake.hcl

- `APP = "tasmocompiler"`, `LICENSE = "MIT"`, `SOURCE = "https://github.com/benzino77/tasmocompiler"`.
- `VERSION` default `"14.0.3"` with `// renovate: datasource=github-tags depName=benzino77/tasmocompiler versioning=semver`. The Dockerfile builds from the tag `v${VERSION}`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`.
- Validate with `docker buildx bake --print` in `apps/tasmocompiler`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/benzino77/tasmocompiler"`.
- `ports`: `port: 3000`, `protocol: tcp`, `required: true`.
- `env`: none confirmed yet. Add entries only after the app source confirms the var names and defaults. Do not invent.
- `volumes`: `/config` only if the app persists settings there (UNVERIFIED); otherwise none.
- `dependencies`: none found (no DB in the upstream Dockerfile or compose).

## 7. start.sh

1. Create the PlatformIO runtime directories under `/tmp` if absent. Do not write to `/app`.
2. Seed `/config` only if the app needs persistent state, and only when missing (UNVERIFIED; the source was not read).
3. `cd /app/tasmocompiler` and `exec node server/app.js`. The upstream entrypoint is `nodemon`, a dev tool. Running `node` directly is a deliberate change that keeps signals on PID 1. Record the decision in the PR. Watch for an upstream dependency on nodemon's restart behaviour.

## 8. container-test.yaml

- Schema header copied from the sibling (`apps/changedetection`).
- `tcp` probe on `3000` (every port in settings.yaml needs a probe).
- `http` probe on `/` on `3000` if the app returns 200 without setup (UNVERIFIED).
- `timeoutSeconds` from the python-node sibling.
- `filePaths`: the app entry file and the PlatformIO venv binary (`/usr/local/lib/platformio-venv/bin/pio`), so the toolchain install is covered.
- No DB, so the narrowing exception does not apply. The first real firmware build needs internet and is not covered by the container test; note this in the PR.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `node` with a writable `/tasmocompiler` and `/home/node`. Here `/app` is read-only, so build output stays in the image, and runtime writes go to `/tmp`.
- `HOME` moves from `/home/node` to `/tmp/home` (or `/config` only if the app must persist its PlatformIO state across restarts; default is `/tmp`).
- `chown -R node:node` is replaced by `apps` ownership on read-only paths. Nothing under `/app` is written at runtime.
- No privileged, no extra persistence. The draft's "non-root: no" and "read-only-rootfs: no" are the TrueCharts chart state, not the image.
- Toolchain downloads on first build need outbound internet, which the test environment may not have; see section 10.

## 10. Risks, caveats and open questions

- UNVERIFIED: app-level env vars and config paths (server/app.js not read).
- UNVERIFIED: Node version in python-node:3.15.2 versus Node 22 upstream.
- UNVERIFIED: arm64 PlatformIO toolchains.
- UNVERIFIED: whether `npm prune --omit=dev` leaves the server working (the upstream frontend removal is a hack and may hide a dependency).
- Caveat: `:latest` on the chart is rolling; v14.0.3 is pinned here. Divergence is possible and not checked.
- Caveat: PlatformIO downloads large toolchains on first build. The first firmware build needs internet and minutes, and fails offline.
- Caveat: firmware builds are CPU heavy. Low-power hosts build slowly.
- Blockers: none that stop a rootless build. The draft's "hard" rating comes from the PlatformIO runtime downloads and the tool chain, not from musl, GPU or privileged needs.

## 11. Build and test steps

```sh
cd apps/tasmocompiler
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker rm -f tasmocompiler-probe 2>/dev/null; docker volume rm tasmocompiler-probe-config 2>/dev/null
docker run --rm -d --name tasmocompiler-probe --read-only --tmpfs /tmp \
  -v tasmocompiler-probe-config:/config tasmocompiler:14.0.3
docker logs -f tasmocompiler-probe
forgetool containers test --image tasmocompiler:14.0.3 --config ./apps/tasmocompiler/container-test.yaml
docker rm -f tasmocompiler-probe; docker volume rm tasmocompiler-probe-config
```

- Expected readiness signal: the server logs that it is listening on port 3000. The exact line is UNVERIFIED until the first build.
- Empty `/config` start must be tested on a fresh volume.
- Do not claim a firmware build works unless one was run; the container test does not cover it.

## 12. PR checklist

- Branch `feat/add-tasmocompiler`, commit `feat(tasmocompiler): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge . Only the user can sign it.
- Say what was not tested (arm64, first firmware build, the UNVERIFIED items above). Do not tick "Built container locally" unless the build ran.
