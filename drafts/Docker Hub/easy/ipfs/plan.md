# ipfs — implementation plan
> Source: ./draft.md · Target: apps/ipfs/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Software | Kubo (go-ipfs). App folder is named `ipfs` as in the draft. |
| Version | **v0.43.1** (latest GitHub release, same as the draft). |
| Renovate | `// renovate: datasource=github-releases depName=ipfs/kubo` (semver, tag has `v` prefix) |
| License | Dual: MIT and Apache-2.0 (`LICENSE-MIT`, `LICENSE-APACHE` exist at the tag). SPDX `Apache-2.0 OR MIT`. |
| Source URL | https://github.com/ipfs/kubo |
| amd64 download | `https://github.com/ipfs/kubo/releases/download/v0.43.1/kubo_v0.43.1_linux-amd64.tar.gz` (also on `dist.ipfs.tech/kubo/v0.43.1/`) |
| arm64 download | `https://github.com/ipfs/kubo/releases/download/v0.43.1/kubo_v0.43.1_linux-arm64.tar.gz` |
| Checksum | `<asset>.sha512` files published next to each tarball (present on the release for both arches; also `.cid`). Use the `.sha512`. |
| Tarball contents | Expected `kubo/ipfs`, `kubo/install.sh`, license files, README. UNVERIFIED (listing not fetched); confirm after download and adjust the paths. |
| Upstream Dockerfile reviewed | `ipfs/kubo` v0.43.1 `Dockerfile`: builds Go from source, final `busybox:stable-glibc` with gosu, tini, fusermount (SUID); `EXPOSE 4001 4001/udp 5001 8080 8081`; `ENV IPFS_PATH=/data/ipfs`; ENTRYPOINT tini + `bin/container_daemon`; CMD `daemon --migrate=true --agent-version-suffix=docker`. |
| Upstream start logic (`bin/container_daemon`) | If root: chown the repo to uid 1000 and re-exec as `ipfs` via gosu. Then: if `$IPFS_PATH/config` exists, reuse; else `ipfs init ${IPFS_PROFILE:+--profile=$IPFS_PROFILE}`, `ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001`, `ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080`, optional swarm key from `IPFS_SWARM_KEY` (content) or `IPFS_SWARM_KEY_FILE` (copied to `$IPFS_PATH/swarm.key`, mode 0400). Runs `/container-init.d/*.sh`, then `exec ipfs "$@"`. |
| Env vars (real) | `IPFS_PATH`, `IPFS_PROFILE`, `IPFS_SWARM_KEY`, `IPFS_SWARM_KEY_FILE` (container scripts); `IPFS_TELEMETRY`, `IPFS_LOGGING`, `GOLOG_LOG_LEVEL`, `GOMEMLIMIT`, `IPFS_FD_MAX`, `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` (kubo `docs/environment-variables.md`). |
| Ports | 4001/tcp and 4001/udp (swarm, TCP and QUIC), 5001/tcp (RPC API, no auth), 8080/tcp (gateway). Upstream also exposes 8081 (swarm WebSocket), which is not enabled by default; not listed. |

## 2. Target layout

```
apps/ipfs/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (init is done by the binary), no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: kubo is a static Go binary from an official release, so no Go build stage is needed (go-runtime rules about build stages apply only when compiling; here we unpack the vendor tarball). Closest sibling: `apps/adguardhome-sync` (tarball binary, `TARGETARCH`, `start.sh` with `exec`, `/config`).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `ARG TARGETARCH`; `USER root`.
2. `ENV IPFS_PATH=/config/ipfs GOCACHE=/tmp/go-build HOME=/config` (the base already sets `HOME=/config`, keep it; any cache or temp goes to `/tmp`).
3. One RUN with `set -eux`:
   - `V="${VERSION#v}"` and file `kubo_v${V}_linux-${TARGETARCH}.tar.gz` (Docker arch names `amd64`/`arm64` equal kubo's, no mapping needed).
   - `curl -fsSL -o /tmp/kubo.tar.gz https://github.com/ipfs/kubo/releases/download/v${V}/kubo_v${V}_linux-${TARGETARCH}.tar.gz` and `curl -fsSL -o /tmp/kubo.sha512 .../kubo_v${V}_linux-${TARGETARCH}.tar.gz.sha512`.
   - Verify: the published file has the form `<hash>  <filename>`; run `cd /tmp && sed "s#  .*#  kubo.tar.gz#" kubo.sha512 | sha512sum -c -` (adjust after inspecting the real file format; build must fail on mismatch).
   - `tar xzf /tmp/kubo.tar.gz -C /tmp`, `install -m 0755 /tmp/kubo/ipfs /app/ipfs`, `ln -s /app/ipfs /usr/local/bin/ipfs`.
   - Licenses: `mkdir -p /usr/share/licenses/ipfs && cp /tmp/kubo/LICENSE* /usr/share/licenses/ipfs/` (only the binary is installed, so the license files must ship; confirm the names in the tarball, otherwise `curl` them from the tag).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
   - No apt packages (curl, tar, ca-certificates in the base). `fusermount`/FUSE (for `ipfs mount`) is intentionally left out: needs SUID/privileges, not rootless.
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `EXPOSE 4001 4001/udp 5001 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` = `ipfs`
- `VERSION`: `// renovate: datasource=github-releases depName=ipfs/kubo` then `default = "v0.43.1"` (Dockerfile strips `v`; same approach as `adguardhome-sync`)
- `LICENSE` = `Apache-2.0 OR MIT`
- `SOURCE` = `https://github.com/ipfs/kubo`
- Standard four targets plus default group from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/ipfs/kubo"`.

- ports: `4001` tcp, `4001` udp, `5001` tcp, `8080` tcp, all `required: false`.
- env:
  - `IPFS_PATH` default `"/config/ipfs"` required false (read by kubo and `start.sh`)
  - `IPFS_PROFILE` default `""` required false (for example `server`, `lowpower`; used only at first init)
  - `IPFS_SWARM_KEY` default `""` required false (private network key content)
  - `IPFS_SWARM_KEY_FILE` default `""` required false
  - `IPFS_TELEMETRY` default `"auto"`? Do not invent: kubo documents `on`, `off`, `auto` and auto when unset; list it with default `""` (unset) required false.
  - `GOLOG_LOG_LEVEL` default `""` required false
  - `TZ` default `"Etc/UTC"` required false
- volumes: `/config` required true (repo at `/config/ipfs`); `/data` required false (alternative location for a large repo via `IPFS_PATH=/data/ipfs`; the base image already provides `/data`).
- dependencies: none.

The draft places the repo in `/data/ipfs` (like upstream) and lists `/export`, `/ipfs`, `/ipns` PVCs. Here `/config/ipfs` is the default (draft's own "Reason" says repo and config under `/config`); `/ipfs` and `/ipns` are FUSE mount points and are dropped, `/export` is not part of upstream and is dropped.

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.

1. `export IPFS_PATH="${IPFS_PATH:-/config/ipfs}"`; `mkdir -p "$IPFS_PATH"`.
2. If `"$IPFS_PATH/config"` is missing: `ipfs init ${IPFS_PROFILE:+--profile="$IPFS_PROFILE"}`, then `ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001` and `ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080` (all interfaces, as other containers must reach them; kubo defaults to 127.0.0.1). Seed the swarm key at init only, like upstream: `printf '%s\n' "$IPFS_SWARM_KEY" > "$IPFS_PATH/swarm.key"` (never echoed to logs) or `install -m 0400 "$IPFS_SWARM_KEY_FILE" "$IPFS_PATH/swarm.key"`; then `unset IPFS_SWARM_KEY IPFS_SWARM_KEY_FILE`.
3. If the config exists, reuse it untouched (user edits survive). Optionally, when `ipfs config Addresses.API` still reads `127.0.0.1`, leave it: do not rewrite user choices.
4. `exec ipfs daemon --migrate=true --agent-version-suffix=containerforge`. (`--migrate=true` lets repo upgrades run on version bumps, as upstream's CMD.)

Writes only to `$IPFS_PATH` (under `/config` or `/data`) and `/tmp`; nothing in `/app`. Secrets stay out of the process list (key goes through a file, not arguments).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '4001'
- port: '5001'
- port: '8080'
filePaths:
- /app/ipfs
- /usr/share/licenses/ipfs/LICENSE-MIT
healthCommands:
- command: ipfs --api=/ip4/127.0.0.1/tcp/5001 diag healthy
```

Every TCP port from `settings.yaml` is probed. The UDP 4001 (QUIC) listener cannot be probed by `tcp`; it is covered by the log line "Swarm listening on /ip4/.../udp/4001/quic-v1" checked by hand. `diag healthy` is the command upstream's own HEALTHCHECK uses (kubo v0.43.1 Dockerfile). No env needed: a fresh empty `/config` runs `ipfs init` at start. The `timeoutSeconds` is higher than siblings because key generation and repo init take longer. Exact license file name `LICENSE-MIT` UNVERIFIED in the tarball; adjust.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| Repo `/data/ipfs` as uid 1000 (gosu from root) | `IPFS_PATH=/config/ipfs`, runs directly as `apps` (568); no gosu, no chown |
| `fusermount` SUID, `/ipfs`, `/ipns`, `/mfs` mounts | Dropped (`ipfs mount` unsupported; document) |
| tini | Provided by the ubuntu base entrypoint |
| Go/temp files | `/tmp` |

Draft expectations: chart UID 0 and `readOnlyRootFilesystem: false` are not needed; run as 568 with read-only rootfs and `/tmp` tmpfs. No privileged, no capabilities. Extra persistence of the chart (`/data/ipfs`, `/export`, `/ipfs`, `/ipns`) is collapsed into `/config` (plus optional `/data`).

## 10. Risks, caveats and open questions

- Swarm ports 4001 tcp and udp must be reachable from outside (draft caveat); behind NAT the node connects to few peers. Kubo's own port mapping (UPnP) needs host networking.
- The repo grows large; size `/config` or point `IPFS_PATH` to `/data`. Moving an existing `/data/ipfs` repo from the TrueCharts or upstream image: mount it and set `IPFS_PATH`; ownership must be 568.
- The RPC API on 0.0.0.0:5001 has no authentication (as in the upstream image): never publish it. Draft caveat about localhost default is handled by `start.sh`, but only on first init; existing repos keep their address.
- Config is created at first init only; later kubo config changes are made by the user.
- Existing upstream UID is 1000; our 568 means an existing volume needs a chown.
- UNVERIFIED: tarball layout, `.sha512` file format, gateway `/` HTTP code (not probed with `http` for that reason; `tcp` used).
- No blockers (glibc, arm64 available, rootless works).

## 11. Build and test steps

```sh
cd apps/ipfs
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create ipfs-probe-config
docker run --rm -d --name ipfs-probe --read-only --tmpfs /tmp \
  -v ipfs-probe-config:/config ipfs:v0.43.1
docker logs -f ipfs-probe
```

Readiness: `initializing IPFS node at /config/ipfs`, then `Daemon is ready`, plus `RPC API server listening on /ip4/0.0.0.0/tcp/5001` and `Gateway server listening on /ip4/0.0.0.0/tcp/8080`. Restart on the same volume: expect no re-init. From a second container: `curl -X POST http://ipfs-probe:5001/api/v0/version` returns JSON. Then `forgetool containers test --image ipfs:v0.43.1 --config ./apps/ipfs/container-test.yaml`; remove container and volume. Run once with `-e IPFS_PROFILE=server` and with a swarm key because the harness cannot set env.

## 12. PR checklist

- Branch `feat/add-ipfs`, commit and PR title `feat(ipfs): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only applicable boxes.
- Notes: `🤖 This PR is AI generated.`; note the UID change versus the upstream image and the dropped FUSE mounts.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to state: arm64, UDP/QUIC reachability, private swarm key path, migration from an existing upstream repo.
