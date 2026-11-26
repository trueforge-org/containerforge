# ofawx/docker-bitcoind (upstream of the draft image ofawx/bitcoind)

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/ofawx/docker-bitcoind/master/Dockerfile (fetched 2026-11-26)
- The draft's link is the blob URL on master; the raw fetch covers it.

**What it is**
- Alpine-based Bitcoin Core image built from source. Not the official glibc tarball.

**Install/build steps (Dockerfile)**
- Two stages: `build` from `alpine`; final from `alpine:latest`. `ARG VERSION` with no default.
- Build apk (no cache): `autoconf automake bash boost-dev coreutils cmake curl git libevent-dev libffi-dev libtool openssl-dev`; then `alpine-sdk build-base`.
- Shallow clone `--depth 1 --branch v$VERSION --single-branch` of bitcoin/bitcoin.
- `make NO_QT=1` in `depends`; zlib 1.3.1 built from zlib.net with SHA-256 check; `./autogen.sh`; `./configure` with `--disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-reduce-exports --disable-bench --disable-tests --disable-gui-tests --without-gui --without-miniupnpc`; CFLAGS `-O2 -g0 --static -static -fPIC`; LDFLAGS `-s -static-libgcc -static-libstdc++ -Wl,-O2`; `make` and `make install`.
- Final: copies `/usr/local` from build; copies `/bitcoin/share/examples/bitcoin.conf` to `/.bitcoin/bitcoin.conf`.
- `VOLUME /.bitcoin`; `EXPOSE 8332 8333 18332 18333 18444`; `ENTRYPOINT ["/usr/local/bin/bitcoind", "-printtoconsole"]`; no USER (root); no CMD.
