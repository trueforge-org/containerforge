# Docker Hub: cooleye72/xmrig

Source URL(s) + fetch date: https://hub.docker.com/r/cooleye72/xmrig · fetched 2026-11-26

## What it is
- Compact Alpine container (under 10 MB) packaging the XMRig CPU miner. Listing: "XMRIG crypto miner". 50K+ pulls. Last updated almost 3 years before capture.
- Author notes: referral code is fixed to fund development, so some proceeds may go to the author; author cautions the image may not be flawless. Lists donation addresses.

## Architectures
- linux/amd64 and linux/arm64/v8.

## Run (verbatim patterns)
- `sudo docker run -e YOUR_ADDRESS='{XMRig Address Format}' -e YOUR_WORKER_NAME='{Input Worker Name}' cooleye72/xmrig:latest`
- With pool and algorithm: `-e ALGO_MODE=... -e POOL_URL=...` added.
- Pull: `docker pull cooleye72/xmrig`.

## Env vars
- `ALGO_MODE` (default `rx/0`), `POOL_URL` (default `rx.unmineable.com:3333`), `YOUR_ADDRESS` (wallet), `YOUR_WORKER_NAME` (default `MyMining1`).

## Ports, volumes
- None documented.

## Version/release info
- Only `latest` tag shown (digest `sha256:f7e590b2...`, 8.9 MB). Versioned tags follow x.x.x per the page.

## Gotchas
- Chart pins `6.21`; the image has no Dockerfile or source link on the page.
