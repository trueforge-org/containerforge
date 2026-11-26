# Context: bitcoind

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/bitcoin/bitcoin | github-bitcoin-bitcoin.md |
| https://raw.githubusercontent.com/bitcoin/bitcoin/master/README.md | github-bitcoin-bitcoin.md |
| https://raw.githubusercontent.com/bitcoin/bitcoin/v32.1/COPYING | github-bitcoin-bitcoin.md |
| https://github.com/bitcoin/bitcoin/releases/tag/v32.1 | github-bitcoin-bitcoin.md |
| https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS | bitcoincore-org-bitcoin-core-downloads.md |
| https://bitcoincore.org/bin/bitcoin-core-32.1/ (directory listing) | bitcoincore-org-bitcoin-core-downloads.md |
| https://bitcoincore.org | bitcoincore-org-home.md |
| https://bitcoin.org | bitcoin-org-home.md |
| https://github.com/kylemanna/docker-bitcoind (Dockerfile at raw master) | github-kylemanna-docker-bitcoind.md |
| https://github.com/ofawx/docker-bitcoind/blob/master/Dockerfile (fetched as raw) | github-ofawx-docker-bitcoind.md |
| https://hub.docker.com/r/ofawx/bitcoind | dockerhub-ofawx-bitcoind.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoind | truecharts-bitcoind.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitcoind/values.yaml | truecharts-bitcoind.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge `apps/<base>` link.
- ghcr.io/trueforge-org/ubuntu (and `:26.04@sha256`): image reference.
- docker.io/ofawx/bitcoind:latest: image reference (Docker Hub page fetched).
- https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz and `...-aarch64-linux-gnu.tar.gz`: direct archive downloads, not fetched. Names and sha256 values recorded from SHA256SUMS.
- https://bitcoincore.org/bin/bitcoin-core-${VERSION}: templated; the concrete 32.1 directory was fetched.
- https://raw.githubusercontent.com/bitcoin/bitcoin/v${VERSION}/COPYING: templated; the concrete v32.1 COPYING was fetched.
- https://github.com/kylemanna/docker-bitcoind: repo page not fetched; its Dockerfile was.

## Fetch failures / partial

- https://raw.githubusercontent.com/bitcoin/bitcoin/v32.1/doc/release-notes/release-notes-32.1.md: HTTP 404. The blob URL of the same file: HTTP 404. The 32.1 release notes are therefore NOT summarised.
- https://github.com/bitcoin/bitcoin/releases/tag/v32.1: the release notes are not on the page (it links to the file above); asset list not rendered ("Assets 3").
- https://raw.githubusercontent.com/bitcoin/bitcoin/master/README.md: no default ports, no binary names.
- https://hub.docker.com/r/ofawx/bitcoind: no architectures, ports, volumes or env vars.
- kylemanna `scripts`: the entrypoint script `docker-entrypoint.sh` was not fetched.

## plan.md corrections

No in-place edits made.

Unverified (left as is):

- plan.md section 1, "32.1 notes (release page)": RPC disconnect behaviour for `-rpcallowip`, `-rpcmaxconnections` (16), `-maxconnections` (200), 29.x and older EOL, Linux 3.17 minimum. The release notes could not be fetched, and the release page itself does not contain them. The row's "(release page)" label is wrong: the notes are in `doc/release-notes/release-notes-32.1.md`, which was not reachable.
- plan.md section 1, "Tarball layout": `bin/` and `libexec/` at top dir `bitcoin-32.1/` is supported by the kylemanna Dockerfile (symlinks `/opt/bitcoin/bin/*`, `libexec/test_bitcoin`); `bitcoind`/`bitcoin-cli` names are supported by the ofawx and kylemanna entry points; the exact tar layout is still UNVERIFIED until a download.
- plan.md section 1, "Env vars: bitcoind reads none": not checked against source.
- plan.md section 3, `ldd` check: not checked.
- plan.md section 7, `-printtoconsole` and `-datadir`/`-conf` flags: `-printtoconsole` is used by the ofawx entrypoint, `-datadir` and `-conf` are not seen in the fetched sources.
- plan.md section 8/11, `tcp` probes and `getblockchaininfo` cookie auth: not checked.
- plan.md section 9, pid file location (`/config/bitcoind.pid`) and `debug.log` location: not checked.
- Confirmed (no edit): Bitcoin Core 32.1 tag and release date (28 Oct); MIT license (COPYING, 2009-2026 copyright); the amd64 and arm64 sha256 values in plan.md section 1; the two other Linux arches; ports 8332 and 8333 (both upstream Dockerfiles `EXPOSE`); kylemanna and ofawx Dockerfile facts in plan.md section 1; releases 30.5 and 31.3 dated 20 Nov (bitcoincore.org).
