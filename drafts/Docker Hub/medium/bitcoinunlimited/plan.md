# bitcoinunlimited — implementation plan
> Source: ./draft.md · Target: apps/bitcoinunlimited/ · Difficulty: medium (prebuilt binary, not a source build) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **2.1.0.0** (BCH Unlimited, GitLab tag `BCHunlimited2.1.0.0`, released 2024-05-29). This differs from the draft, which targets the stale GitHub tag `BCHunlimited1.9.0.1` (2020) and a source build. The project moved to GitLab; the GitHub repo has not had a release since 1.9.0.1, but ready-made Linux binaries for 2.1.0.0 exist, so no C++ build is needed. |
| Renovate | `datasource=gitlab-releases`, `depName=bitcoinunlimited/BCHUnlimited`, `extractVersion=^BCHunlimited(?<version>.+)$`, `versioning=loose` (GitLab releases list `BCHunlimited2.1.0.0`, `2.0.0.1`, `2.0.0.0`, `1.10.0.0`, ...) |
| License | MIT (COPYING at `gitlab.com/bitcoinunlimited/BCHUnlimited` tag `BCHunlimited2.1.0.0`; GitHub mirror also reports MIT) |
| Source | https://gitlab.com/bitcoinunlimited/BCHUnlimited (the draft's https://github.com/BitcoinUnlimited/BitcoinUnlimited is a mirror/older home; the Dockerfile reviewed lives in amacneil/docker-bitcoin `unlimited/1.1.1.1`) |
| amd64 URL | https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/raw/master/bch-unlimited-2.1.0.0-linux64.tar.gz |
| arm64 URL | https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/raw/master/bch-unlimited-2.1.0.0-arm64.tar.gz |
| Checksum | `sign_2.1.0.0.json` in the same repo lists sha256 per file. amd64 `0274e17b...ae7c`, arm64 `a602f511...2b62` (both re-computed from the downloads and matched). |
| Tarball layout | `bch-unlimited-2.1.0.0/bin/{bitcoind,bitcoin-cli,bitcoin-tx,bitcoin-miner,bitcoin-qt,rostrum,test_bitcoin}`, `lib/libbitcoinconsensus*`, `lib/libbitcoincash*`, `include/`, `share/forks.csv`. No license file inside. |
| Binary deps | `bitcoind` (amd64) needs only `libpthread, librt, libanl, libm, libgcc_s, libc`, max GLIBC_2.18, all present on ubuntu. arm64 binary not inspected (UNVERIFIED). |
| Options verified in `init.cpp`/`httprpc.cpp` at the tag | `-conf`, `-listen`, `-bind`, `-server`, `-disablewallet`, `-printtoconsole`, `-prune`, `-maxconnections`, `-rpcuser`, `-rpcpassword`, `-rpcauth`. `-datadir`, `-rpcbind`, `-rpcallowip`, `-rpcport`, `-port` are standard Bitcoin Core options but were not found in the files grepped: UNVERIFIED, confirm with `bitcoind -help` at build time. |
| Ports | mainnet p2p **8333**, RPC **8332** (`chainparamsbase.cpp`: `nRPCPort = 8332`; testnet 18332). The draft's "(inferred)" values hold. |
| Env vars | The daemon reads none (config comes from `bitcoin.conf` and flags). |

## 2. Target layout

```
apps/bitcoinunlimited/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/bitcoin.conf     # seed config
```
`defaults/` is on the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: prebuilt glibc binaries; no extra apt packages. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. One `RUN`:
   - Arch map: `case "${TARGETARCH}" in amd64) A=linux64;; arm64) A=arm64;; *) exit 1;; esac`
   - `curl -fsSL -o /tmp/bu.tar.gz "https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/raw/master/bch-unlimited-${VERSION}-${A}.tar.gz"`
   - `curl -fsSL -o /tmp/sign.json "https://raw.githubusercontent.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/master/sign_${VERSION}.json"`
   - Checksum: `expected="$(grep "bch-unlimited-${VERSION}-${A}.tar.gz'" /tmp/sign.json | sed -E "s/.*: '([0-9a-f]{64})'.*/\1/")"; echo "${expected}  /tmp/bu.tar.gz" | sha256sum -c -` (the file is a Python-style dict with single quotes, as seen in the download; fail the build if `expected` is empty).
   - `mkdir -p /app/bin /app/lib /usr/share/licenses/bitcoinunlimited`; `tar xzf /tmp/bu.tar.gz -C /tmp`; copy only `bitcoind`, `bitcoin-cli`, `bitcoin-tx` into `/app/bin`, `libbitcoin*` into `/app/lib` (skip `bitcoin-qt`, `bitcoin-miner`, `rostrum`, `test_bitcoin`); set `ENV LD_LIBRARY_PATH=/app/lib` only if `ldd` shows the binaries need them (UNVERIFIED).
   - License: `curl -fsSL -o /usr/share/licenses/bitcoinunlimited/COPYING "https://gitlab.com/bitcoinunlimited/BCHUnlimited/-/raw/BCHunlimited${VERSION}/COPYING"`.
   - `chown -R apps:apps /app && chmod -R 755 /app && rm -rf /tmp/*`.
3. `ENV PATH=/app/bin:$PATH`.
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 8333 8332`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "bitcoinunlimited" }
variable "VERSION" {
  // renovate: datasource=gitlab-releases depName=bitcoinunlimited/BCHUnlimited extractVersion=^BCHunlimited(?<version>.+)$ versioning=loose
  default = "2.1.0.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://gitlab.com/bitcoinunlimited/BCHUnlimited" }
```
Standard 4 targets + default group (copy from `apps/adguardhome-sync`); `image-all` has linux/amd64 and linux/arm64. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://gitlab.com/bitcoinunlimited/BCHUnlimited"`.
- ports: `8333/tcp` (p2p) required false; `8332/tcp` (RPC) required false.
- env (all consumed by start.sh, none by the daemon): `TZ` default `"Etc/UTC"`; `BITCOIN_RPC_ALLOW_IP` default `""` (when set, RPC binds all interfaces and allows that CIDR); `BITCOIN_PRUNE_MB` default `""` (when set, passes `-prune=<n>`; the flag is verified in `init.cpp`). Extra daemon flags are passed as container args.
- volumes: `/config` required true (datadir: blocks, chainstate, wallet, `bitcoin.conf`).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config
[[ -s /config/bitcoin.conf ]] || cp /defaults/bitcoin.conf /config/bitcoin.conf
args=(-datadir=/config -conf=/config/bitcoin.conf -printtoconsole)
[[ -n "${BITCOIN_PRUNE_MB:-}" ]] && args+=("-prune=${BITCOIN_PRUNE_MB}")
if [[ -n "${BITCOIN_RPC_ALLOW_IP:-}" ]]; then
  args+=("-rpcbind=0.0.0.0" "-rpcallowip=${BITCOIN_RPC_ALLOW_IP}")
fi
exec /app/bin/bitcoind "${args[@]}" "$@"
```
- `defaults/bitcoin.conf`: `server=1`, `listen=1` (flags verified to exist). No RPC password is written. Auth falls back to the cookie file in the datadir (UNVERIFIED for this fork); users who need static credentials mount their own `/config/bitcoin.conf` with `rpcauth=` (flag verified) so secrets are not on the command line or in the environment.
- P2P (8333) listens on all interfaces; RPC listens on localhost unless `BITCOIN_RPC_ALLOW_IP` is set (a node with no RPC password should not be reachable from other containers). Log this decision at startup.
- No writes to `/app`; everything in `/config`; `exec` for signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240

tcp:
- port: '8333'
- port: '8332'

filePaths:
- /app/bin/bitcoind
- /app/bin/bitcoin-cli
```
Probe per port in section 6 (8333, 8332). The suite runs with no env vars, so RPC is on localhost only, which `tcp` accepts because the check runs inside the container. UNVERIFIED: that RPC (8332) is already open before the initial header sync; RPC server starts early in Bitcoin Core derivatives, confirm in the run step.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data` (BITCOIN_DATA) and `~/.bitcoin` symlink | `-datadir=/config` |
| `bitcoin.conf`, `debug.log`, `.cookie`, `peers.dat` | all under `/config`; `-printtoconsole` keeps the log on stdout instead of `/config/debug.log` |
| entrypoint `gosu`/chown | not needed (UID 568) |

Draft expectations: chart ran UID 0, read-only rootfs false, `/data` persistence. Plan: UID 568, read-only rootfs, one volume `/config`. Not privileged.

## 10. Risks, caveats and open questions

- Draft targeted a 2018 source build; the plan uses official 2.1.0.0 binaries instead. Confirm that is acceptable (it removes the CMake/Boost build entirely).
- The initial block download needs hundreds of GB and days; `BITCOIN_PRUNE_MB` is the only built-in mitigation. Chain data must sit on a persistent `/config` volume.
- The network is Bitcoin Cash (BCH), not Bitcoin BTC, despite the TrueCharts name. Ports 8333/8332 are the same as Bitcoin Core's mainnet ports.
- The GitHub repo's releases are stale; renovate must watch GitLab releases. The binaries live in a separate repo (`BitcoinUnlimitedWebDownloads`) and not on release pages, so a new release may appear a few days before its binaries do.
- arm64 binary was checksum-verified but not inspected for libc requirements.
- RPC authentication defaults are UNVERIFIED (cookie auth) for this fork.
- Executing the downloaded binaries (`bitcoind -help`) to confirm flag names was not done during verification.

## 11. Build and test steps

```sh
cd apps/bitcoinunlimited
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bitcoinunlimited-probe --read-only --tmpfs /tmp \
  -v bitcoinunlimited-probe-config:/config bitcoinunlimited:2.1.0.0
docker logs -f bitcoinunlimited-probe
forgetool containers test --image bitcoinunlimited:2.1.0.0 --config ./apps/bitcoinunlimited/container-test.yaml
docker rm -f bitcoinunlimited-probe; docker volume rm bitcoinunlimited-probe-config
```
Expected readiness: log lines such as `init message: Done loading` / `Bitcoin Unlimited ... starting`, port 8333 open (`ss -ltn`), and the container still running after a minute. Also run `docker run --rm bitcoinunlimited:2.1.0.0 /app/bin/bitcoind -help` once to confirm the flag names marked UNVERIFIED.

## 12. PR checklist

- Branch `feat/add-bitcoinunlimited`; commit and PR title `feat(bitcoinunlimited): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.` and mentions the version change (2.1.0.0 instead of the draft's 1.9.0.1).
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: arm64 run, RPC auth, chain sync, flag names not in the grepped source.
- Check "Built container locally" only if it was built.
