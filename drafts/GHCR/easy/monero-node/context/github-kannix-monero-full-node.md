# kannix/monero-full-node (listed resource, older community image)

**Source URL(s):** https://github.com/kannix/monero-full-node
**Fetched:** 2026-11-26

## Summary
- Docker image project for a Monero full node. MIT licensed. Files: Dockerfile, LICENSE, README.md.
- Image: `kannix/monero-full-node`. No compose file.
- Software version not stated. The README calls the non-root change a breaking change dated October 2018.
- Ports listed: 18080 and 18081.
- Volume: named `xmrchain` mapped to `/home/monero/.bitmonero` (older setups used a host path `/var/data/blockchain-xmr`).
- Run: `docker run -tid --restart=always -v xmrchain:/home/monero/.bitmonero -p 18080:18080 -p 18081:18081 --name=monerod kannix/monero-full-node`.
- Migration from pre-2018 images: lmdb "Permission denied" unless the volume is chowned to `monero:monero` with a one-off root container.

## Relevance to the plan
- Listed as a "source code repository" in the draft. Not used: the plan uses the official monero tarball and the sethforprivacy wrapper (github-sethforprivacy-simple-monerod-docker.md). The 18081 port here is the unrestricted RPC, which the plan does not use.
- Useful only as a reminder that `/home/monero/.bitmonero` ownership is a common upgrade gotcha.
