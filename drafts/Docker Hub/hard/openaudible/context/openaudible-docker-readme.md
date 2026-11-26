# openaudible_docker README

Source URL(s): https://github.com/openaudible/openaudible_docker (raw README) · fetched 2026-11-26

## Run
- Quick: `docker run -d --rm -it -p 3000:3000 --security-opt seccomp=unconfined --name openaudible openaudible/openaudible:latest`; open http://localhost:3000.
- NAS: `docker run -d --name=openaudible -p 3000:3000 -v /your/nas/path:/config/OpenAudible -e PUID=1026 -e PGID=100 --security-opt seccomp=unconfined --restart unless-stopped openaudible/openaudible:latest`.
- Compose: docker-compose.yml from repo; Synology variant docker-compose.synology.yml.
- From source: clone, `./run.sh` (builds and runs).
- Upgrade: stop, rm, re-run; latest fetched at startup.
- `seccomp=unconfined` required for latest version; without it, run `./bash.sh`, `su abc`, `OpenAudible` manually.

## Env vars
| Name | Default | Meaning |
|---|---|---|
| PUID | not stated (example 1026) | uid of container user `abc` |
| PGID | not stated (example 100) | gid |
| OA_BETA | beta effectively true | false = stable |
| OA_DIR | set in run.sh | host data path (run.sh only) |

## Ports / paths
- Port 3000 HTTP (KasmVNC web GUI). No HTTPS.
- Data: `/config/OpenAudible` (books, metadata, settings); must be mounted to persist.
- Prep: `mkdir -p /path && chown $(id -u):$(id -g) /path`.

## Access
- Browser at http://localhost:3000; no password by default (add via run.sh).
- One viewer at a time.

## Gotchas
- `--rm` deletes container; books survive only in mounted volume.
- Log out of Audible in Control Menu before deleting container/volume.
- Experimental, unsupported, personal use; desktop app recommended.
