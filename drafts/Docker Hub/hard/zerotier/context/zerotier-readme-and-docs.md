# ZeroTierOne README, ZeroTier docs, and apt repo index

## Source URL(s) + date
- https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/README.md (fetched 2026-11-26)
- https://docs.zerotier.com (fetched 2026-11-26; main page only)
- http://download.zerotier.com/debian/resolute (directory index, fetched 2026-11-26)

## What it is (README)
- ZeroTier: programmable Ethernet switch / global area network. VL1 (P2P crypto network) + VL2 (Ethernet emulation layer).
- Traffic end-to-end encrypted. Relays available.
- README links: build.md (build instructions), service/README.md, nonfree/controller/README.md.

## License (README)
- `LICENSE-MPL.txt`: code in node/, osdep/, service/ and everywhere except ext/ and nonfree/.
- `nonfree/LICENSE.md`: non-free ("source available") portions.
- `ext/`: external code under its own license.

## Install (docs.zerotier.com)
- Docs point to "Install" and "Downloads" sections; main page only, no install commands extracted.
- Docs page: "Last updated on Oct 6, 2026".

## Apt repo index (download.zerotier.com/debian/resolute/)
- Directory index contains `dists/` and `pool/` only. Package index not fetched.

## Ports / env / volumes / user / healthcheck
- Not in these pages (see zerotier-dockerfile-entrypoint.md).

## Gotchas
- README "License" section points to two files; plan.md's "BSL 1.1 in README.docker.md" note is not checked here.
- Docs main page does not give port or network setup details; skip for build.
