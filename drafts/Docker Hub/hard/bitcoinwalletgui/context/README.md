# bitcoinwalletgui context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://bitcoincore.org/en/download/, https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS, https://bitcoincore.org/, https://bitcoincore.org/en/doc/, release notes @ v32.1 | bitcoincore-org-download-and-checksums.md |
| https://github.com/bitcoin/bitcoin (README) | github-bitcoin-bitcoin.md |
| https://hub.docker.com/r/ulisses1478/bitcoinwallet-gui | dockerhub-ulisses1478-bitcoinwallet-gui.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoinwalletgui | truecharts-bitcoinwalletgui.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz and `...-aarch64-linux-gnu.tar.gz`: direct binary downloads. Filenames and checksums recorded in the bitcoincore summary; not downloaded.
- `ghcr.io/trueforge-org/*`, `docker.io/ulisses1478/*`, `bitcoin/bitcoin`: image refs (the GitHub repo itself is summarised).
- `/headless/.bitcoin`, `/config/.bitcoin`: paths, not URLs.

## Fetch failures
- Release asset names on the Core release page: not fetched (download page used instead).

## plan.md corrections
- plan.md section 1 Ports row: `6080 noVNC, 5900 VNC (draft, inferred)` -> `6901 noVNC, 5901 VNC (Docker Hub run examples and chart)`. Source: dockerhub-ulisses1478-bitcoinwallet-gui.md and truecharts-bitcoinwalletgui.md.

## Unverified (not changed in plan.md)
- plan.md section 1 licence MIT for Bitcoin Core: README says MIT (COPYING not read). The wrapper's own licence is not stated anywhere.
- plan.md section 1 port 8333 and `listen=0` note in section 1 or 2: not checked.
- Draft copy-from `ulisses1478/bitcoinwallet-gui:latest`: image ships an unknown Bitcoin Core version and was last updated over 7 years ago. Whether it carries a `bitcoin-qt` binary is not confirmed.
- plan.md section 1 `Renovate` `v32.1` tag: release-notes raw path at `v32.1` resolved, consistent with the tag existing.
