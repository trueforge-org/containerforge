# sethforprivacy/simple-monerod-docker (upstream image wrapper at 08e993d)

**Source URL(s):** https://github.com/sethforprivacy/simple-monerod-docker/blob/08e993d/Dockerfile (fetched via raw); https://raw.githubusercontent.com/sethforprivacy/simple-monerod-docker/08e993d/entrypoint.sh (followed); https://raw.githubusercontent.com/sethforprivacy/simple-monerod-docker/08e993d/healthcheck.sh (followed)
**Fetched:** 2026-11-26

## Dockerfile

### Build args
- `MONERO_BRANCH` = `v0.18.5.4`; `MONERO_COMMIT_HASH` = `85f036ba7019cd36f08e8a38a27c37ea7b522618` (build fails if HEAD does not match).
- `NPROC`, `TARGETARCH` (amd64 -> `x86-64`/`linux-x64`; arm64 -> `armv8-a`/`linux-armv8`; others error).
- `MONERO_USER` default `monero`; `HOME=/home/monero`.
- Ban-list key fingerprint args: `BOOG900_FINGERPRINT`, `RUCKNIUM_FINGERPRINT`, `JEFFRO256_FINGERPRINT`.

### Build stage (Alpine 3.24.4, pinned digest)
- Packages: Boost (several components), bison, ccache, cmake, g++, git, gnupg, make, pkgconf, eudev-dev, libsodium-dev, libusb-dev, linux-headers, miniupnpc-dev, ncurses-dev, openssl-dev, pcsc-lite-dev, protobuf-dev, rapidjson-dev, readline-dev, zeromq-dev.
- Builds expat R_2_6_4 (SHA-256 checked) and libunbound release-1.22.0 (SHA-256 checked) statically.
- Clones monero recursively at `MONERO_BRANCH`, checks HEAD = commit hash, CMake `build/release` with `STATIC=ON`, `BUILD_64=ON`, Release, `STACK_TRACE=OFF`, ccache. Builds `daemon` target. Strips symbols.
- Ban list: clones `Boog900/monero-ban-list`; imports keys from Boog900 (pinned Cuprate commit), Rucknium (rucknium.me, gist fallback), jeffro256 (pinned monero-project commit); verifies `sigs/boog900.sig`, `Rucknium.sig`, `jeffro256.sig` against `ban_list.txt` with pinned fingerprints.

### Final stage (same Alpine digest)
- Runtime packages: curl, ca-certificates, libsodium, ncurses-libs, numactl-tools, readline, su-exec, tzdata, zeromq.
- Creates user `monero` (`/bin/ash`, no password), `/home/monero/.bitmonero` owned by it.
- `COPY entrypoint.sh /entrypoint.sh` (0755), `ENTRYPOINT ["/entrypoint.sh"]`.
- No `USER` (root PID 1 for PUID/PGID handling).
- `COPY healthcheck.sh /healthcheck.sh` (0755).
- `WORKDIR /home/monero`. `monerod` copied to `/usr/local/bin/monerod`; `ban_list.txt` to `./ban_list.txt`.
- No `VOLUME`. `EXPOSE 18080 18089`.
- `HEALTHCHECK` interval 30s, timeout 10s, start period 60s, runs `/healthcheck.sh`.
- `CMD`: `--rpc-restricted-bind-ip=0.0.0.0 --rpc-restricted-bind-port=18089 --no-igd --no-zmq --enable-dns-blocklist --ban-list=/home/monero/ban_list.txt`.

## entrypoint.sh
- Env: `PUID` (default 1000), `PGID` (default 1000). `HOME` not read; `/home/monero/.bitmonero` hardcoded.
- If `id -u` is 0: prefixes `su-exec PUID:PGID`. Otherwise no chown or su-exec.
- Chowns `/home/monero/.bitmonero` recursively to PUID:PGID, only when the owner UID/GID differs.
- Creates no directories.
- Command: `monerod --non-interactive <args>`; prepends `numactl --interleave=all` if numactl exists and works. `set -e`; ends with `exec "$@"`.
- Not used by our build (plan: no PUID/PGID, run as `apps`).

## healthcheck.sh
- Tests `GET http://127.0.0.1:<port>/get_height`. Port from `--rpc-restricted-bind-port` in `/proc/1/cmdline`, then `--rpc-bind-port`, else 18081.
- Reads `--rpc-login` if present: `curl --fail --silent --digest --user <login>`; success = HTTP < 400.
- Without login: `curl --silent` status code; passes on 200 or 401 (401 means alive; credentials may come from `--config-file`, which the script cannot read). Connection failure (000) fails.
- Tools: sh, tr, awk, curl. No jq; response body not parsed. No explicit curl timeouts. `set -eu`.
- Plan.md uses forgetool probes, not this healthcheck. The `/get_height` endpoint is a usable readiness probe if restricted RPC is on (plain GET; the plan's note that RPC is POST-only was for JSON-RPC; `/get_height` is a GET endpoint here).

## Gotchas
- The ban list is fetched and GPG-verified at build; the plan omits `--ban-list` unless the file ships in the tarball (the tarball is a binary download, not inspected).
- Upstream `numactl` is only a runtime tool; not needed.
