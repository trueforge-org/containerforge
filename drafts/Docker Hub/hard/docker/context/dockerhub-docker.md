# docker (Docker Hub official image)

Source URL(s) + fetch date:
- https://hub.docker.com/_/docker
- Fetched 2026-11-26

## What it is
- Docker Official Image "docker" (Docker in Docker, "dind"), maintained by the Docker project, over a billion pulls. Nesting Docker is discouraged except for developing Docker itself.

## Supported architectures
- amd64, arm32v6, arm32v7, arm64v8, ppc64le, riscv64, s390x, windows-amd64.

## Tags
- Simple: `29.10.1-dind`, `29.10-dind`, `29-dind`, `dind`, `latest`, `29.10.1`, `29.10`, `29`, `29.10.1-dind-alpine3.24`, `29.10.1-alpine3.24`.
- Rootless: `29.10.1-dind-rootless`, `29.10-dind-rootless`, `29-dind-rootless`, `dind-rootless`.
- CLI: `29.10.1-cli`, `29-cli`, `cli`.
- Windows Server Core variants (ltsc2025, ltsc2022, client only).
- `stable` and `test` channel tags deprecated, not updated since Dec 2020.
- Page's newest version is 29.10.1 (Docker Hub latest tag is 29.10.1-dind). Not 29.10.0.

## Run command (daemon)
```
docker run --privileged --name some-docker -d --network some-network --network-alias docker \
  -e DOCKER_TLS_CERTDIR=/certs -v some-docker-certs-ca:/certs/ca -v some-docker-certs-client:/certs/client docker:dind
```
- `--privileged` required. Do not use `--network=host` (daemon would recreate host Docker iptables chains).
- Custom daemon flags go after the image name.
- Optional tuning: `--ulimit nofile=-1`, `--ulimit nproc=-1`, `--ulimit core=-1`, `--pids-limit -1`, `--oom-score-adj -500`.

## Client usage
- `docker run --rm --network some-network -e DOCKER_TLS_CERTDIR=/certs -v some-docker-certs-client:/certs/client:ro docker:latest version`, or mount `/var/run/docker.sock`.

## Env vars
- `DOCKER_TLS_CERTDIR`: where certs are generated (ca, server, client). TLS on by default from 19.03: daemon listens 2376; without it, 2375.
- Rootless variant: `docker-entrypoint.sh` sets `DOCKER_HOST` automatically.

## Volumes
- `/certs/ca`, `/certs/client` (certs; share client with clients), `/var/lib/docker` (data directory, bind-mountable).

## Gotchas
- Windows images include the client only.
- Latest tag about 112.2 MB.
