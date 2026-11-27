# RedisJSON Dockerfile (pinned commit 9ca1c88a)

Source URL(s): https://raw.githubusercontent.com/RedisJSON/RedisJSON/9ca1c88acd9cadfcbc0e4f805ff3de473bd50b60/Dockerfile (fetched 2026-11-27)

## What it does
- Multi-stage build, NOT a runtime server image. It builds `rejson.so` and copies it into a Redis base.
- Stage `redis`: `FROM redisfab/redis:6.2.7-x64-bullseye` (copies `/usr/local/` from it).
- Stage `builder`: `FROM debian:bullseye-slim`, `WORKDIR /build`, `ADD . /build`.
  - `./deps/readies/bin/getupdates`, `./deps/readies/bin/getpy3`, `./sbin/system-setup.py`
  - `make build SHOW=1`
  - Shell: `SHELL ["/bin/bash", "-l", "-c"]`
- Stage `search`: `FROM redisfab/redisearch:master-x64-bullseye` (provides `redisearch.so`).
- Final: `FROM redisfab/redis:6.2.7-x64-bullseye`, `WORKDIR /data`.
  - Module dir `/usr/lib/redis/modules`; copies `rejson.so*` from `/build/bin/linux-x64-release/` and `redisearch.so*`.
  - `chown -R redis:redis /usr/lib/redis/modules`

## Entrypoint / flags
```
CMD ["redis-server", "--loadmodule", "/usr/lib/redis/modules/rejson.so", "--loadmodule", "/usr/lib/redis/modules/redisearch.so"]
```

## Runtime
- Base is Redis 6.2.7 on Debian bullseye, x86_64 only (`-x64-` tags).
- Ports: none declared (Redis default 6379 from base).
- Volumes: `/data` as WORKDIR.

## Gotchas
- Dockerfile header comment says "Redis 6.2.6" while base image is 6.2.7.
- Requires `redisfab/redisearch` as a second base; x64 only.
- Dockerfile is pinned to a commit, not a tag.
