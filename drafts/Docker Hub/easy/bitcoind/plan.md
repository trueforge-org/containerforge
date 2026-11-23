# bitcoind — implementation plan
> Source: ./draft.md · Target: apps/bitcoind/ · Difficulty: easy · Role: main · Verified on 2026-11-23

> Note: the `bitcoin-node` draft describes the same software (same tarball, same ports). Build one image and let both charts use it. Decide the app name once (`bitcoind` matches the binary); if both names are wanted, do not duplicate the Dockerfile, publish one app only.

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Latest stable | Bitcoin Core 32.1 (released 2026-10-27; GitHub marks it Latest; 32.0 was never fully released). Draft version `32.1` matches. Newer maintenance releases 31.3 and 30.5 (2026-11-20) exist on older branches and are not the target. |
| Renovate | `datasource=github-releases depName=bitcoin/bitcoin extractVersion=^v(?<version>.+)$` (tag format `v32.1` is UNVERIFIED, check the GitHub releases page; drop `extractVersion` if tags have no `v`) |
| License | MIT (Bitcoin Core `COPYING`) |
| Source | https://github.com/bitcoin/bitcoin (site https://bitcoincore.org) |
| amd64 URL | https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz |
| arm64 URL | https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-aarch64-linux-gnu.tar.gz (exists in the directory listing, so the draft's `yes*` is confirmed) |
| Checksums | `https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS` (also `SHA256SUMS.asc`, `.ots`). Verified lines: amd64 `61545c17c3120fb7412f896d248b11993af04ec8817aad3649c55b2afb044963`, arm64 `7ed37c7373eb6aa3e3f72842596a1afeba1b223717033cade9842b25773e1922` |
| Other archs in listing | arm-linux-gnueabihf, riscv64, powerpc64 (not targeted; image only builds amd64 and arm64) |
| Tarball layout | UNVERIFIED by download. Release notes say Linux installs copy `bin/` and `libexec/`. Expect top dir `bitcoin-32.1/` with `bin/bitcoind`, `bin/bitcoin-cli`, `bin/bitcoin` wrapper, `libexec/`, `share/`. Inspect with `tar tzf` at implementation time. |
| Upstream Dockerfiles reviewed | https://github.com/kylemanna/docker-bitcoind (ubuntu, user `bitcoin` 1000, `VOLUME /bitcoin/.bitcoin`, EXPOSE 8332 8333, gosu entrypoint) and https://github.com/ofawx/docker-bitcoind (alpine source build, root, `VOLUME /.bitcoin`, ENTRYPOINT `bitcoind -printtoconsole`). We follow neither; we use the official glibc tarball. |
| Ports | 8333/tcp P2P, 8332/tcp JSON-RPC (mainnet defaults; testnet/regtest ports differ, not exposed) |
| Env vars | bitcoind reads none. It is configured by CLI flags and `bitcoin.conf`. Env vars below are our own `start.sh` conventions. |
| 32.1 notes (release page) | RPC clients from addresses not allowed by `-rpcallowip` (default localhost) are now disconnected immediately; new `-rpcmaxconnections` (16); `-maxconnections` default 200; 29.x and older are EOL. Platform minimum Linux 3.17. |

## 2. Target layout

```
apps/bitcoind/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (bitcoind starts without a `bitcoin.conf`; nothing to seed), no `root/`. No `DOWNSTREAM_CHANGES.md` unless another app later uses this as a `FROM` base. Nearest siblings: `apps/adguardhome-sync` (prebuilt binary on ubuntu, `TARGETARCH`), `apps/redis-exporter` (checksum verify against upstream sums plus license copy).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Upstream binaries are glibc (`linux-gnu`), so the ubuntu base is right; no runtime libs beyond the base are expected (UNVERIFIED, check with `ldd /app/bin/bitcoind` during the first build).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`, `ENV PATH=/app/bin:${PATH}`.
2. Arch mapping and verified download:
   ```dockerfile
   RUN set -eux; \
       case "${TARGETARCH}" in amd64) ARCH=x86_64;; arm64) ARCH=aarch64;; *) echo "unsupported ${TARGETARCH}" >&2; exit 1;; esac; \
       BASE="https://bitcoincore.org/bin/bitcoin-core-${VERSION}"; \
       FILE="bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz"; \
       cd /tmp; \
       curl -fsSLO "${BASE}/${FILE}"; curl -fsSLO "${BASE}/SHA256SUMS"; \
       grep " ${FILE}\$" SHA256SUMS | sha256sum -c -; \
       tar -xzf "${FILE}" -C /app --strip-components=1; \
       rm -f /app/bin/bitcoin-qt /app/bin/test_bitcoin* ; \
       mkdir -p /usr/share/licenses/bitcoind; \
       find /app -maxdepth 2 \( -name COPYING -o -name 'LICENSE*' -o -name 'README*' \) -exec cp {} /usr/share/licenses/bitcoind/ \; ; \
       chown -R apps:apps /app; chmod -R 755 /app; rm -rf /tmp/*
   ```
   - `SHA256SUMS` comes from the same host as the tarball, so this guards against corruption only. Optional hardening: verify `SHA256SUMS.asc` with the builder keys from bitcoin-core/guix.sigs (key list not fetched, UNVERIFIED).
   - If no license file is in the tarball, download `https://raw.githubusercontent.com/bitcoin/bitcoin/v${VERSION}/COPYING` (tag format UNVERIFIED).
3. No apt packages.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8333 8332`, `VOLUME /config`, `WORKDIR /config`. No ENTRYPOINT (base tini entrypoint runs `/start.sh`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "bitcoind" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=bitcoin/bitcoin extractVersion=^v(?<version>.+)$
  default = "32.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/bitcoin/bitcoin" }
```

Targets exactly as `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `default` -> `image-local`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/bitcoin/bitcoin"`.

- ports: `8333` tcp and `8332` tcp, both `required: false`.
- env: `TZ` `Etc/UTC`; `BITCOIN_RPCALLOWIP` `""` (comma separated, passed as repeated `-rpcallowip=`; empty means localhost only); `BITCOIN_RPCAUTH` `""` (an `rpcauth` string generated with upstream `share/rpcauth/rpcauth.py`, contains a salted hash, not a password). All three are read by `start.sh`; bitcoind itself reads no env.
- volumes: `/config` `required: true` (datadir: blocks, chainstate, wallets, `bitcoin.conf`, `.cookie`).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
ARGS=(-datadir=/config -conf=/config/bitcoin.conf -printtoconsole -rpcbind=0.0.0.0)
# bitcoind ignores a missing -conf file only if it is the default path; create it so a custom -conf never errors
[ -f /config/bitcoin.conf ] || : > /config/bitcoin.conf
if [ -n "${BITCOIN_RPCALLOWIP:-}" ]; then
  IFS=',' read -r -a ips <<< "${BITCOIN_RPCALLOWIP}"
  for ip in "${ips[@]}"; do ARGS+=("-rpcallowip=${ip// /}"); done
fi
[ -n "${BITCOIN_RPCAUTH:-}" ] && ARGS+=("-rpcauth=${BITCOIN_RPCAUTH}")
exec /app/bin/bitcoind "${ARGS[@]}" "$@"
```

- Idempotent: only creates an empty `bitcoin.conf` when missing, never overwrites; no writes to `/app`; no caches needed.
- P2P binds 0.0.0.0:8333 by default. `-rpcbind=0.0.0.0` makes the RPC listen on all interfaces, but access is still restricted by `-rpcallowip` (default localhost only) and by auth (cookie file in `/config/.cookie` unless `BITCOIN_RPCAUTH`). Other containers need `BITCOIN_RPCALLOWIP` (for example the pod CIDR) to connect. This is the secure default; say so in the log line start.sh prints.
- No `rpcuser`/`rpcpassword` env: they would appear in the process list and are deprecated in favour of `rpcauth`.
- Extra flags (`-prune=550`, `-testnet4`, `-txindex`) pass through `"$@"` (container args).
- Final `exec` keeps bitcoind as the tini child so SIGTERM triggers a clean shutdown (bitcoind flushes the chainstate on SIGTERM; set the pod `terminationGracePeriodSeconds` high).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8333'
- port: '8332'
filePaths:
- /app/bin/bitcoind
- /app/bin/bitcoin-cli
- /usr/share/licenses/bitcoind
```

`tcp` probes run inside the container, so the localhost-only RPC allow-list does not matter. The test needs no env vars. Note the first start begins an initial block download; it does not need network to open the ports, but if the sandbox has no network the node still listens (UNVERIFIED). Add `http` only after confirming that RPC answers a bare GET (it returns 401 without credentials; do not use).

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart path | Remap |
|---|---|
| `/root/.bitcoin/` (chart PVC) | `/config` (datadir via `-datadir=/config`) |
| `$HOME/.bitcoin` | not used; `HOME=/config` and explicit `-datadir` |
| pid file | defaults into the datadir (`/config/bitcoind.pid`) |
| debug.log | stdout via `-printtoconsole`; `/config/debug.log` is still written unless `-nodebuglogfile` is passed (consider adding it to avoid a growing file) |

- Draft/chart expectation: root (UID 0), `readOnlyRootFilesystem: false`. Reconciled: runs as `apps` (568) with read-only rootfs; only `/config` and `/tmp` are written.
- **Migration risk**: existing chain data written by root needs `chown -R 568:568` (or `fsGroup: 568`) on the volume.
- Not privileged. No extra persistence.

## 10. Risks, caveats and open questions

- Disk: mainnet chain is several hundred GB and grows; first sync takes days. Recommend `-prune` for tests.
- Datadir conflict in the draft is settled as `/config`; chart ``/root/.bitcoin/`` must move to `/config`.
- RPC security: default allow-list is localhost; do not default `-rpcallowip=0.0.0.0/0`.
- Tarball layout, license file location and release tag format are UNVERIFIED until the first build; adapt the `find` and renovate `extractVersion`.
- Bitcoin Core 32.x uses a custom HTTP server for RPC (release notes); older clients with sloppy headers may be rejected.
- Bitcoin Core release tarballs include `libexec/` multiprocess binaries; they are kept (not needed, not harmful).
- Duplicate of the `bitcoin-node` draft; only one of the two apps should be created. The draft also flags the arm64 tarball as unconfirmed, now confirmed present.
- No blockers: glibc tarball exists for amd64 and arm64, no GPU, no privileges.

## 11. Build and test steps

```sh
cd apps/bitcoind
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bitcoind-probe --read-only --tmpfs /tmp \
  -v bitcoind-probe-config:/config bitcoind:32.1 -prune=550
docker logs -f bitcoind-probe
# readiness: container still running; log shows "Bitcoin Core version v32.1", "Using the 'x86_64_shani'..." style init lines,
# "init message: Loading block index" then "Done loading" (exact strings UNVERIFIED); ports 8333 and 8332 open; no "Error:" lines
docker exec bitcoind-probe /app/bin/bitcoin-cli -datadir=/config getblockchaininfo   # cookie auth works
docker rm -f bitcoind-probe; docker volume rm bitcoind-probe-config
forgetool containers test --image bitcoind:32.1 --config ./apps/bitcoind/container-test.yaml
```

Also run once with `BITCOIN_RPCALLOWIP` set and connect from a second container. Optionally build `image-all` arm64 (`--set image-all.platform=linux/arm64`) to prove the aarch64 tarball and checksum line. Max 10 rounds; clean up scratch resources.

## 12. PR checklist

- Branch `feat/add-bitcoind`, commit and PR title `feat(bitcoind): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick "New container/image" and only boxes that apply; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- Notes: datadir moved to `/config`, UID 568 migration, RPC allow-list default, no env-based credentials.
- Untested until run: arm64, tarball layout, `ldd` completeness, readiness log strings, behaviour offline, full IBD.
- Checklist: app-scoped, instructions read, `VERSION` aligned between bake and Dockerfile (32.1), rootless and read-only OK, empty `/config` OK, `bake --print` run, no DOWNSTREAM file.
