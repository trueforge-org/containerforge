# docs.ipfs.tech (IPFS documentation)

Source URL(s) + fetch date:
- https://docs.ipfs.tech/ (home)
- https://docs.ipfs.tech/install/run-ipfs-inside-docker/ (followed link, one level)
- Fetched 2026-11-26

## Home page
- Covers IPFS building blocks (addressing, routing, data movement, content addressing, peer-to-peer). Sections: getting started, deploying sites, troubleshooting, building apps (Helia, Kubo), concepts, reference, case studies, community.
- Kubo: Go implementation and CLI, with an RPC API.
- Relevant links: `install/` (Get Started), `install/command-line/` (Kubo CLI), `install/ipfs-desktop/`, `install/ipfs-companion/`, `how-to/troubleshooting/`, `reference/kubo/rpc/` (Kubo RPC API), `reference/kubo-rpc-cli/`.

## Run IPFS inside Docker (followed page)
- Image: `ipfs/kubo`. Examples pin `ipfs/kubo:v0.43.1`.
- Host dirs: `ipfs_staging` (mounted at `/export`) and `ipfs_data` (mounted at `/data/ipfs`).
- Basic run:
  - `docker run -d --name ipfs_host`
  - `-v $ipfs_staging:/export` and `-v $ipfs_data:/data/ipfs`
  - Ports: `-p 4001:4001` and `-p 4001:4001/udp` (P2P TCP and QUIC); `-p 127.0.0.1:8080:8080` (gateway); `-p 127.0.0.1:5001:5001` (RPC API)
  - image `ipfs/kubo:v0.43.1`
- Logs `docker logs -f ipfs_host`; CLI `docker exec ipfs_host ipfs swarm peers`; stop `docker stop ipfs_host`.
- Warns never to expose the RPC API publicly (admin-level access).
- First start with empty data dir: runs `ipfs init`, creates a new keypair.
- Profile: `-e IPFS_PROFILE=server`.
- Init scripts: mounted in `/container-init.d`, run in lexicographic order after init and before the daemon, on every start, so should be idempotent. Example mounts `./001-test.sh:/container-init.d/001-test.sh`; env like `PRIVATE_PEER_ID`, `PRIVATE_PEER_IP_ADDR`.
- Resource limits: `--cpus` with `GOMAXPROCS` (not above CPU limit); `--memory` with `GOMEMLIMIT` slightly below memory limit (example `8000m` / `7500MiB`).
- Swarm key: file at `/data/ipfs/swarm.key`. `IPFS_SWARM_KEY` (content) or `IPFS_SWARM_KEY_FILE` (path, overwrites `IPFS_SWARM_KEY` if both set). Docker secret example needs swarm or compose.
- Key rotation: stop the container, run a temp container on the same volume with `key rotate -o old-self -t ed25519`.
- Not covered: `IPFS_PATH`, UID/permissions.
- Host-setup note: docs say `ipfs_data` path is `/data/ipfs`; plan uses `/config/ipfs` (design difference).
