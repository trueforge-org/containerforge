# itzg/rcon (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/itzg/rcon (fetched)

## What it is
Container that runs rcon-web-admin. Lets the game server's RCON port stay inside the Docker network. Page labelled Sponsored OSS, 1M+ pulls (about 8,574 per week).

## Tags and arch
- Only `latest`, last updated more than 2 years before fetch, digest sha256:c9521f333..., about 338.6 MB. Pull: `docker pull itzg/rcon`.
- No architectures stated.

## Run example (page)
```
docker run -d --name rcon-web \
  -p 4326:4326 -p 4327:4327 \
  -e RWA_PASSWORD=password \
  itzg/rcon
```
Open http://YOUR_DOCKER_HOST:4326.

## Env vars (page)
- `RWA_ENV` preset to TRUE.
- `RWA_PASSWORD` required; password for the initial user (`admin` default).
- `RWA_RCON_HOST` set to the game server hostname (for example the Compose service name).

## Ports and volumes
- 4326 web UI, 4327 websocket.
- Volume `/opt/rcon-web-admin/db`.

## Compose
- Not inline. Links to docker-compose.yml in itzg/docker-rcon-web-admin, which pairs it with itzg/minecraft-server. Example RCON password "testing" in that setup.
