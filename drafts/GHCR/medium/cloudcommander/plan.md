# cloudcommander — implementation plan
> Source: ./draft.md · Target: apps/cloudcommander/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Note: the draft image is `coderaiser/cloudcmd` and the app name is `cloudcommander` in this folder. The app directory uses the name `cloudcommander` per the draft folder, with the npm package `cloudcmd`.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v19.24.1 (GitHub release 2026-11-23, tag commit `e854f6b7572890c98f62d5fdb4d65ef1ec1e584a`). npm `cloudcmd` 19.24.1 published 2026-11-23. Draft image tag 19.23.2 is older. |
| Renovate | `datasource=npm depName=cloudcmd versioning=semver` (proposed). Alternative: `github-releases depName=coderaiser/cloudcmd`. |
| License | MIT (repo and npm) |
| Source | https://github.com/coderaiser/cloudcmd |
| Download | npm tarball `https://registry.npmjs.org/cloudcmd/-/cloudcmd-19.24.1.tgz`, installed with `npm install -g cloudcmd@19.24.1` or into an app dir |
| Checksum source | npm `integrity` sha512 `CxZ39vwzOVWcBPww8QjVUntmwWzctg5AWtBHs/QL2/SyUQvo/HxvY19RTGlcKICXaThRnh6VbA6yyeGVI+lq8A==` and shasum `18f8acb9a3d314869eac19da048a4bf5a3ca60b6` |
| Upstream Dockerfile reviewed | `docker/Dockerfile` at `ddf4726` (older): `FROM node` (unpinned), installs bun via `curl https://bun.com/install | bash` (unpinned remote script), `bun r gritty --omit dev`, `ENV cloudcmd_terminal=true cloudcmd_terminal_path=gritty cloudcmd_open=false`, `EXPOSE 8000`, `ENTRYPOINT bin/cloudcmd.js`, no USER. |
| Engines | `node >=22` |
| Port | `process.env.PORT || config('port')`, default 8000 (server/server.js:39, json/config.json). Bind `process.env.IP || config('ip') || '0.0.0.0'` (server.js:41). |
| Env vars | `cloudcmd_<name>` in upper or lower snake case (server/env.js). Read by bin/cloudcmd.js: `cloudcmd_root`, `cloudcmd_auth`, `cloudcmd_username`, `cloudcmd_name`, `cloudcmd_open`, `cloudcmd_terminal`, `cloudcmd_terminal_path`, `cloudcmd_terminal_command`, `cloudcmd_terminal_auto_restart`, `cloudcmd_prefix`, `cloudcmd_theme`, `cloudcmd_editor`, `cloudcmd_engine`, `cloudcmd_menu`, `cloudcmd_columns`, `cloudcmd_console`, `cloudcmd_config_auth`, `cloudcmd_config_port`, `cloudcmd_export`, `cloudcmd_import`, `cloudcmd_import_url`, `cloudcmd_log`, `cloudcmd_show_dot_files`, `cloudcmd_vim`. Plus `PORT`, `IP`. UNVERIFIED: whether a password can be set by env. |
| Defaults (json/config.json) | `auth: false`, `root: "/"`, `open: true`, `terminal: false`, `port: 8000`, `ip: null`, `configAuth: true` |
| Data and config paths | `~/.cloudcmd.json` (`path.join(HOME, '.cloudcmd.json')`, server/config.js:62), HOME from `os.homedir()`. `.cloudcmd.menu.js` is written into the browsed directory (server/cloudcmd.js:274). Other writes UNVERIFIED. |
| Terminal | `gritty ^10.2.0` (MIT), which depends on `node-pty ^1.2.0-beta.2` (native). UNVERIFIED: whether node-pty prebuilds exist for glibc amd64 and arm64. |
| Dependencies | None (no database). |
| Arm64 | Pure JS except node-pty (UNVERIFIED). |

## 2. Target layout

- `apps/cloudcommander/Dockerfile`
- `apps/cloudcommander/docker-bake.hcl`
- `apps/cloudcommander/settings.yaml`
- `apps/cloudcommander/container-test.yaml`
- `apps/cloudcommander/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/`. `DOWNSTREAM_CHANGES.md` not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft proposes. Closest sibling: `apps/thelounge` (python-node, `WORKDIR /config`). The Node version in python-node is UNVERIFIED against `node >=22`; check with `node --version` in the built image.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install with npm, pinned to VERSION: a local install under `/app/cloudcommander` (`npm install --prefix /app/cloudcommander --omit=dev cloudcmd@${VERSION}`, no `-g`, so `start.sh` finds `node_modules/.bin/cloudcmd`). Remove npm caches afterwards (`npm cache clean --force`).
3. If the terminal feature is kept, the native `node-pty` build needs `build-essential python3` in a build stage only (UNVERIFIED whether prebuilds avoid this). Decide after build test.
4. Do not use the upstream bun installer (unpinned remote script).
5. License: copy `LICENSE` from the installed package to `/usr/share/licenses/cloudcommander/LICENSE`.
6. `ENV HOME=/config NPM_CONFIG_CACHE=/tmp/npm`.
7. `chown -R root:root /app/cloudcommander && chmod -R 755 /app/cloudcommander` (runtime does not write under `/app`).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "cloudcommander" }
variable "VERSION" {
  // renovate: datasource=npm depName=cloudcmd versioning=semver
  default = "19.24.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/coderaiser/cloudcmd" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/coderaiser/cloudcmd"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: cloudcmd_root
    default: "/config"
    required: false
  - name: cloudcmd_auth
    default: "true"
    required: false
  - name: cloudcmd_open
    default: "false"
    required: false
  - name: cloudcmd_terminal
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`cloudcmd_auth` defaults to `true` here, a deliberate hardening against upstream's `auth: false`. Login needs a password; UNVERIFIED how it is set without the config dialog. Keep the root at `/config` (not `/`), so the default does not expose the container filesystem. The draft's `/UNRAID` and `/root` mounts are deployment choices, not defaults. No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

export HOME=/config
export PORT="${PORT:-8000}"
export IP="${IP:-0.0.0.0}"

exec /app/cloudcommander/node_modules/.bin/cloudcmd
```

- Idempotent; writes only to `/config` (`.cloudcmd.json` is created by the app on demand).
- Never writes under `/app`.
- Binds `0.0.0.0` by default (`IP`), which must be confirmed by an outside-container probe.
- `exec` for signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/cloudcommander/node_modules/cloudcmd/bin/cloudcmd.js
- /usr/share/licenses/cloudcommander/LICENSE
```

The HTTP probe is `/`; with `auth` true it may answer with a redirect or 401. UNVERIFIED which status is returned; choose the path or status the probe accepts after a real run, without weakening the check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `~/.cloudcmd.json` (HOME) | `HOME=/config`, so it lands in the persistent volume. |
| `.cloudcmd.menu.js` in browsed dirs | Written into `cloudcmd_root` (`/config` by default). Read-only rootfs is fine as long as root is `/config`. |
| npm cache | `/tmp` (build only). |
| Upstream root `/` | Not the default here; `cloudcmd_root=/config`. Users who mount other paths set `cloudcmd_root` themselves. |

Draft expectations reconciled: the chart runs as UID 0 with writable `/root`. This image runs as `apps` (568); the file-manager root moves to `/config`. The chart's `/root` and `/UNRAID` mounts are not replicated as defaults; the user must mount them and set `cloudcmd_root`.

## 10. Risks, caveats and open questions

- Exposing a file manager is a serious risk. Default auth is off upstream; this plan sets `cloudcmd_auth=true`, which the user must set a password for. Confirm how the password is set.
- `root: "/"` upstream gives access to the container filesystem; the plan avoids that default.
- `node-pty` may compile (UNVERIFIED prebuilds). Terminal is off by default; decide whether to ship node-pty at all.
- Upstream image is 19.23.2 with an unpinned node base and an unpinned bun installer; this plan removes both.
- Node version in python-node is UNVERIFIED against `node >=22`.
- No blockers confirmed (no GPU, no privileged need, no database).

## 11. Build and test steps

```sh
cd apps/cloudcommander
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cloudcommander-probe --read-only --tmpfs /tmp \
  -v cloudcommander-probe-config:/config cloudcommander:19.24.1
docker logs -f cloudcommander-probe
forgetool containers test --image cloudcommander:19.24.1 --config ./apps/cloudcommander/container-test.yaml
docker rm -f cloudcommander-probe; docker volume rm cloudcommander-probe-config
```

Readiness signal expected: cloudcmd's listen log line on port 8000 (exact text UNVERIFIED; confirm in the run). Confirm `/config` remains writable and `.cloudcmd.json` is created only when needed.

## 12. PR checklist

- Branch `feat/add-cloudcommander`, commit and PR title `feat(cloudcommander): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: builds on both architectures, the node-pty build on arm64, runtime on `--read-only`, the probe status code under auth, and the password setup.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
