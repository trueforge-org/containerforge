# kylemanna/docker-bitcoind (upstream Dockerfile, reviewed)

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/kylemanna/docker-bitcoind/master/Dockerfile (fetched 2026-11-26)

**What it is**
- Docker image for Bitcoin Core, maintained by Kyle Manna. Uses the official glibc release tarballs with signature verification.

**Install/build steps (Dockerfile)**
- Builder: `docker.io/library/ubuntu:latest`. Per-arch `ARCH`: amd64 -> `x86_64`, arm64 -> `aarch64`, riscv64 -> `riscv64`.
- ARG `VERSION=32.1`; `BITCOIN_CORE_SIGNATURES` (three key fingerprints); `GROUP_ID=1000`, `USER_ID=1000`.
- Apt (build): `ca-certificates gnupg libatomic1 wget`. Apt (final): `gosu libatomic1`.
- Steps: receive keys from `hkp://keyserver.ubuntu.com`; download `SHA256SUMS.asc`, `SHA256SUMS` and `bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz` from `bitcoincore.org/bin/bitcoin-core-${VERSION}/`; verify GPG (VALIDSIG must match a listed fingerprint); `sha256sum --ignore-missing --check SHA256SUMS`; extract into `/opt`; symlink `/opt/bitcoin` -> `bitcoin-${VERSION}`; run `/opt/bitcoin/libexec/test_bitcoin --show_progress`; delete `test_bitcoin` and `bin/bitcoin-qt`.
- Rationale in comments: distro packages lag or generate `/etc/bitcoin.conf`; the signed tarball is preferred.
- Alpine is ruled out in a comment because the Bitcoin Core binary is glibc, not musl.

**Final stage**
- Base `docker.io/library/ubuntu:latest`. `ENV HOME=/bitcoin`. Creates group and user `bitcoin` (uid/gid 1000, home `/bitcoin`). `COPY --from=build /opt/ /opt/`. Symlinks `/opt/bitcoin/bin/*` into `/usr/local/bin`. Copies `./bin` and `docker-entrypoint.sh` to `/usr/local/bin/`.
- `EXPOSE 8332 8333`; `VOLUME ["/bitcoin/.bitcoin"]`; `WORKDIR /bitcoin`.
- No `USER` (runs as root); the `bitcoin` user is created but unused.
- `ENTRYPOINT ["docker-entrypoint.sh"]`; `CMD ["btc_oneshot"]`. The entrypoint script was not fetched (it uses `gosu`).

**Gotchas**
- Tarball top dir: `bitcoin-32.1/` with `bin/`, `libexec/` (this is what plan.md expects).
