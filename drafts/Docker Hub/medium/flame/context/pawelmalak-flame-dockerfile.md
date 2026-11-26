# pawelmalak/flame (.docker/Dockerfile + repo)

Source URL(s): https://github.com/pawelmalak/flame ; https://github.com/pawelmalak/flame/blob/069b6690d9fa7a24a6e7727386ab85148c89b90e/.docker/Dockerfile (raw fetched: https://raw.githubusercontent.com/pawelmalak/flame/069b6690d9fa7a24a6e7727386ab85148c89b90e/.docker/Dockerfile) ; https://github.com/pawelmalak/flame/wiki (5 pages, sub-pages failed to load, no container facts)
Date: fetched 2026-11-26

## What it is
- Self-hosted startpage with built-in apps and bookmark editor. Node.js app (server.js) + React client (built into public/).

## Build (.docker/Dockerfile @ 069b669)
- Stage builder: `FROM node:20`, WORKDIR `/app`; COPY package*.json; `npm install --production`; COPY whole context; mkdir `./public` `./data`; in `./client`: `npm install --production` + `npm run build`; move `client/build` -> `./public`; delete `./client`.
- Stage final: `FROM node:20-alpine`; `COPY --from=builder /app`; WORKDIR `/app`.
- `EXPOSE 5005`
- ENV `NODE_ENV=production`, `PASSWORD=flame_password`.
- `CMD sh -c "chown -R node /app/data && node server.js"`
- No ARG, USER, VOLUME, ENTRYPOINT, HEALTHCHECK. Runs as root (chown needs it).
- Multiarch variant file exists upstream: `.docker/Dockerfile.multiarch` (not fetched).

## Runtime deps
- node:20-alpine. Optional: docker.sock mount for Docker integration only.

## Entrypoint/flags
- `node server.js` via sh -c.

## Env vars
| Var | Default (Dockerfile) | Meaning |
| --- | --- | --- |
| NODE_ENV | production | |
| PASSWORD | flame_password | login password (README run example sets it) |
| enable_integration | "true" (chart only) | Docker integration toggle (chart value) |

## Ports
- 5005/tcp (EXPOSE; README `-p 5005:5005`).

## Volumes/paths
| Path | Use |
| --- | --- |
| `/app/data` | data dir (README `-v /path/to/data:/app/data`); chown'd to node at startup |
| `/var/run/docker.sock` | optional, Docker integration only |

## User/UID
- Image: root (no USER). App data chown'd to `node` user (UID 1000 in node images) at start.

## Healthcheck
- None.

## Version/asset naming
- GitHub release `v2.4.0` (published 2026-04-24); API lists no assets.
- Docker Hub tags: `latest`, `2.4.0`, `multiarch`, `multiarch2.4.0` (amd64, arm64, arm/v7).

## Arch
- Upstream provides `.docker/Dockerfile` (amd64) and `.docker/Dockerfile.multiarch` (linux/arm/v7, linux/arm64, linux/amd64).

## Gotchas
- Default PASSWORD is hardcoded `flame_password` in image ENV.
- Wiki sub-pages (Installation without Docker, Authentication, etc.) did not load; env/config facts beyond README unavailable.
- License not stated in fetched pages.
