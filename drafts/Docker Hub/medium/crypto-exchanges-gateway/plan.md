# crypto-exchanges-gateway — implementation plan
> Source: ./draft.md · Target: apps/crypto-exchanges-gateway/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: **blocked** on a successful source build (section 10, blockers 1 to 3). The plan is written so that the build can be tried, but no image can be claimed until `npm` installs and the app starts on amd64.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.13.2` (latest release, published 2023-11-11T22:34:16Z, source tag only, no release assets). The draft names no version. |
| Image the chart uses today | `apendergast/crypto-exchanges-gateway:latest` (Docker Hub, amd64, pushed 2023-11-11). `rpi-latest` is 32-bit arm. No arm64 tag in the first 100 tags. |
| Renovate | Candidate: `datasource=github-releases depName=aloysius-pgast/crypto-exchanges-gateway versioning=semver` (the release `1.13.2` exists; tags have no `v` prefix). Not checked against the repo convention in this step. |
| License | ISC (`package.json` on `master`). Ship the upstream license file: its file name in the tarball is UNVERIFIED. |
| Source URL | https://github.com/aloysius-pgast/crypto-exchanges-gateway |
| Download | Tag archive `https://github.com/aloysius-pgast/crypto-exchanges-gateway/archive/refs/tags/${VERSION}.tar.gz` (the `.zip` form is confirmed; the `.tar.gz` form is the standard GitHub form and was not fetched). |
| Checksum source | None published. The archive is pinned by tag only. |
| Upstream Dockerfile reviewed | `master` `docker/Dockerfile` (https://raw.githubusercontent.com/aloysius-pgast/crypto-exchanges-gateway/master/docker/Dockerfile): stages built on `apendergast/ceg-docker-base:gateway-latest` and `ui-latest`; `git clone`, `npm install --unsafe-perm`, `docker/config.docker.json` copied to `config/config.json`, `npm run build` for the UI; runtime `apendergast/alpine-node:runtime-latest` (musl alpine); `WORKDIR /root/crypto-exchanges-gateway/`; no `USER` (root); `VOLUME` for `ssl`, `storage/db`, `custom_config`; `EXPOSE 8000` and `8001`; `CMD ["node","./gateway.js"]`. The tag's Dockerfile is not fetched (UNVERIFIED). |
| Ports | `8000` (API and UI, http) and `8001` (websocket). Confirmed in the Dockerfile and README. |
| Env vars | README (https://raw.githubusercontent.com/aloysius-pgast/crypto-exchanges-gateway/master/README.md) documents `cfg.logLevel`, `cfg.listen.externalEndpoint`, `cfg.listenWs.externalEndpoint`, `cfg.sessions.{maxSubscriptions,maxDuration,hideIpaddr}`, `cfg.auth.apikey`, `cfg.ui.enabled`, `cfg.tickerMonitor.enabled`, `cfg.marketCap.enabled`, `cfg.pushover.{user,token}`, and `cfg.exchanges.<poloniex|bittrex|binance|kucoin|okex>.{enabled,key,secret,password,requirePair}`. UNVERIFIED: how these dotted keys map to environment variable names. Take the real names from the Dockerfile `ENV` lines at the pinned tag before writing `settings.yaml`. |
| Config file | `custom_config/config.json` overrides the environment variables (README). |
| Data paths | `storage/db` (sqlite3), `custom_config`, `ssl`, all under the app directory. |
| Node version | README says the build "won't build unless you use node 14.x" (line 5). Current Node is UNVERIFIED. |

## 2. Target layout

- `apps/crypto-exchanges-gateway/Dockerfile`
- `apps/crypto-exchanges-gateway/docker-bake.hcl`
- `apps/crypto-exchanges-gateway/settings.yaml`
- `apps/crypto-exchanges-gateway/container-test.yaml`
- `apps/crypto-exchanges-gateway/start.sh`

No `defaults/` or `etc/` are needed if the config comes from the environment. Add `defaults/config.json` only if the upstream `config.docker.json` is needed as a seed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

- Build and final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`.
- Why: the app is Node, and the base provides Node. `apps/budge` is a Node app on this base. The porter table maps Node to `ubuntu`, but the ubuntu base does not provide Node (UNVERIFIED for every ubuntu version), so `python-node` is the closer fit. The exact Node version in this base is UNVERIFIED: check `node --version` in the build.
- Closest siblings: `apps/budge` (Node app, native module build, `sqlite3` in apt) and `apps/bookstack` (symlinks from `/app` into `/config`).
- Not `ghcr.io/trueforge-org/ubuntu` alone: no Node.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends build-essential python3 git sqlite3`. `build-essential` and `python3` are needed to compile `sqlite3` (native). `git` is needed for the `git+https` dependency (`bittrex-signalr-client`). Remove `build-essential` in the same layer after `npm install`, as `apps/budge` does.
3. `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/npm-cache`. Node's cache and build output go to `/tmp`.
4. Fetch and unpack: `curl -fL https://github.com/aloysius-pgast/crypto-exchanges-gateway/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /app/crypto-exchanges-gateway --strip-components=1`.
5. In `/app/crypto-exchanges-gateway`: `npm install` (not `--unsafe-perm` unless the build fails without it, UNVERIFIED), then `npm run build` for the UI (UNVERIFIED: check the scripts in `package.json`). Then `npm prune --omit=dev`, and remove `/tmp/*`.
6. Copy the upstream license into `/usr/share/licenses/crypto-exchanges-gateway/` (file name UNVERIFIED).
7. Final stage: the same `python-node` base. If the build stage is kept in one stage, skip this. Otherwise `COPY --from=build /app/crypto-exchanges-gateway /app/crypto-exchanges-gateway` and `COPY --from=build /usr/share/licenses/ /usr/share/licenses/`. Build-time `node_modules` must match the final Node version, so one stage is safer for the first attempt.
8. Symlinks from upstream writable paths into `/config` (dangling links are fine until `start.sh` creates the targets, as in `apps/bookstack`):

```dockerfile
RUN cd /app/crypto-exchanges-gateway && \
    rm -rf storage/db custom_config ssl && \
    ln -s /config/storage/db storage/db && \
    ln -s /config/custom_config custom_config && \
    ln -s /config/ssl ssl
```

The `rm -rf` clears any directory the tarball ships, so the link is not created inside it (as `apps/bookstack` does).

9. Ownership and modes: `chown -R apps:apps /app/crypto-exchanges-gateway && chmod -R 755 /app/crypto-exchanges-gateway`, as `apps/adguardhome-sync` does.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000 8001
VOLUME /config
WORKDIR /config
ENV HOME=/config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "crypto-exchanges-gateway" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=aloysius-pgast/crypto-exchanges-gateway versioning=semver
  default = "1.13.2"
}
variable "LICENSE" { default = "ISC" }
variable "SOURCE" { default = "https://github.com/aloysius-pgast/crypto-exchanges-gateway" }
```

Use the four standard targets and the default group, copied from `apps/adguardhome-sync`. Run `docker buildx bake --print` from `apps/crypto-exchanges-gateway`. The Dockerfile reads `VERSION` through `ARG VERSION`, and both must be `1.13.2`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/aloysius-pgast/crypto-exchanges-gateway"
ports:
  - port: 8000
    protocol: tcp
    required: false
  - port: 8001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  # Add the cfg.* variables here, using the real names from the upstream Dockerfile ENV lines (section 1).
volumes:
  - path: /config
    required: true
```

Dependencies: none. Upstream uses embedded sqlite3, and no database server is needed. Optional, not listed: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/storage/db /config/custom_config /config/ssl

cd /app/crypto-exchanges-gateway
exec node ./gateway.js
```

- Idempotent. Seeds nothing: the app starts on its own defaults. Add a `custom_config/config.json` seed only if the app cannot start without one (UNVERIFIED: test an empty `/config`).
- Nothing is written to `/app` at runtime except through the symlinks, which point at `/config`.
- Scratch and npm caches go to `/tmp`.
- `exec` gives PID 1 to Node.
- Listen addresses: UNVERIFIED. Confirm that `8000` and `8001` bind to `0.0.0.0` (or `::`) and not `127.0.0.1` with `ss -ltn`, and reach the ports from the host.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8000'
- port: '8001'
http:
- port: '8000'
  path: /
filePaths:
- /app/crypto-exchanges-gateway/gateway.js
- /usr/share/licenses/crypto-exchanges-gateway/LICENSE   # file name UNVERIFIED
```

- Both ports have a `tcp` probe, per the coverage rule. The `http` probe on `8000` needs a path that returns 200 without an exchange key (UNVERIFIED: the UI may redirect or need config).
- The test runs with no env vars. The app must start with its defaults, so the exchange keys stay out of the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/crypto-exchanges-gateway/storage/db` (sqlite3) | Symlink to `/config/storage/db`. |
| `/root/crypto-exchanges-gateway/custom_config` | Symlink to `/config/custom_config`. |
| `/root/crypto-exchanges-gateway/ssl` | Symlink to `/config/ssl`. |
| Chart PVC `/root/crypto-exchanges-gateway/custom_config` | Image path is `/config/custom_config`. Chart users must move their `custom_config` to `/config/custom_config`. |
| npm and node caches | `/tmp` (`NPM_CONFIG_CACHE`, `HOME=/tmp` in the build stage). |

Reconciliation of the draft's expectations: the chart runs as UID 0 (`runAsUser 0`), and this image runs as `apps`. The chart sets `readOnlyRootFilesystem: false`; the image is intended to be compatible with `--read-only --tmpfs /tmp`, which is UNVERIFIED until the test. Not privileged, as in the draft.

## 10. Risks, caveats and open questions

Blockers:

1. **Node version.** The README says the build needs Node 14.x. Node 14 is far out of date, and the base's Node version (24 per `apps/budge`) is UNVERIFIED for this project. Try `npm install` on the base's Node first. Do not pin an old Node without evidence.
2. **Git dependency.** `bittrex-signalr-client` is a `git+https` dependency on a fork (`package.json`). The build needs network access to GitHub. Check that it resolves and that it can be pinned to a commit.
3. **Native `sqlite3` on arm64.** No arm64 image is published upstream, and the `sqlite3` native build has not been tested on arm64. Build amd64 first. arm64 is UNVERIFIED and may not work.

Other caveats:

- Upstream says the project is "unlikely to be updated". Expect ContainerForge to own the maintenance.
- The draft's binary link (release `1.13.2`) has no assets, so there is no prebuilt binary to fetch. The app is built from source, as in the plan.
- Many exchange libraries (`ccxt`, `binance`, `poloniex-api-node`, `node-bittrex-api`) are pulled in at install time. Their versions are not pinned by this plan (UNVERIFIED: check `package-lock.json` in the tarball).
- The app needs API keys or accounts for real data, and `custom_config/config.json` is the documented way to configure it. The test does not provide keys.
- No musl-only, GPU or privileged needs were found. The runtime is glibc (`python-node`), so the upstream musl alpine base is not reused.

## 11. Build and test steps

```sh
cd apps/crypto-exchanges-gateway
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name crypto-exchanges-gateway-probe --read-only --tmpfs /tmp \
  -v crypto-exchanges-gateway-probe-config:/config crypto-exchanges-gateway:1.13.2
docker logs -f crypto-exchanges-gateway-probe
forgetool containers test --image crypto-exchanges-gateway:1.13.2 --config ./apps/crypto-exchanges-gateway/container-test.yaml
docker rm -f crypto-exchanges-gateway-probe; docker volume rm crypto-exchanges-gateway-probe-config
```

Readiness signal: UNVERIFIED log text. Expect a line for each listen address, on `8000` and `8001`, and no exit. Confirm that `/config/storage/db` is created after start, and that the container still runs after a restart.

## 12. PR checklist

- Branch `feat/add-crypto-exchanges-gateway`, commit and PR title `feat(crypto-exchanges-gateway): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and tick only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say honestly what is untested: the Node version, the git dependency, the amd64 and arm64 builds, the `--read-only` start, the empty `/config` start, the `http` probe status, and any exchange connection (no keys used).
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion is weakened.
