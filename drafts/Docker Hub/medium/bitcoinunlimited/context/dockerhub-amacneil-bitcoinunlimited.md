# hub.docker.com/r/amacneil/bitcoinunlimited

Source: https://hub.docker.com/r/amacneil/bitcoinunlimited (fetched 2026-11-26)

## Facts
- Maintainer amacneil; last updated ~9 years ago (stale); ~40 MB; 10K+ pulls
- Tags shown: only `latest` on this repo page; sibling repos bitcoin, bitcoinclassic, bitcoinxt, btc1
- Image supplies `bitcoin`, `bitcoin-cli`, `bitcoin-tx`
- Data: `/data` (volume); bitcoin.conf generated there
- Config: pass args to bitcoind (e.g. `-testnet`) or edit bitcoin.conf
- RPC 8332 mentioned; no `-p` mapping shown
- bitcoin-cli: `docker run --rm --network container:bitcoind ... bitcoin-cli getinfo`
- Env vars: none documented
- License: MIT
- Dockerfiles generated from templates (versions.yml, Dockerfile.erb, `make update`)

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/amacneil/bitcoinunlimited/ and /tags?page_size=10
- namespace amacneil; name bitcoinunlimited; pull_count 48832; star_count 0; last_updated 2018-02-16 (stale)
- Tags: 23 pages total; first page: 1.0.0, 1.0.1.0, 1.0.1.3, 1.1.0, 1.1.1, 1.0.1.2, 0.11, 0.12.1, 1.0.1, 1.0.2.0 (all linux/amd64, ~41 MB)
- Note: `latest` not in first page of JSON; HTML view showed `latest`. Image pinned to BU 1.1.1.1 in upstream Dockerfile; 1.1.1 tag exists.
