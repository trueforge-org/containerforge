# Docker Hub: linuxserver/firefox

Source URL(s):
- https://hub.docker.com/v2/repositories/linuxserver/firefox/ (repo JSON)
- https://hub.docker.com/v2/repositories/linuxserver/firefox/tags?page_size=10 (tags JSON)
- Fetched 2026-11-27. Pull counter 2,165,954; last_updated 2026-11-25.

## What it is
- Image `linuxserver/firefox`, pulled as `lscr.io/linuxserver/firefox`. Repo is active, public, not automated.
- Upstream repo: https://github.com/linuxserver/docker-firefox

## Architectures
- amd64 and arm64 (manifest list on `latest`, `1.2404.1`, `version-1161.0build1-1xtradeb1.2404.1`).
- Tags also include `version-<firefox>build<n>-<ppa>` style names.

## Tags seen (page_size=10)
- `latest`, `1.2404.1`, `version-1161.0build1-1xtradeb1.2404.1` (all same digest `sha256:8ab8f9ab...`, pushed 2026-11-25).
- Count 2,244 tags total.

## Run notes (from Docker Hub description)
- Minimal run: `docker run --shm-size=1gb -p 3001:3001 lscr.io/linuxserver/firefox:latest`
- Open `https://<host>:3001`; self-signed cert by default, so scheme is https.
- `--shm-size=1gb` recommended.
- GPU optional: `--device /dev/dri` (Intel/AMD); Nvidia needs `--runtime nvidia --gpus all --device /dev/nvidia-modeset`. `AUTO_GPU=false` disables auto GPU.
- Security: container gives privileged host access per upstream warning; do not expose to internet.
- Base: Docker Baseimage Selkies (linuxserver/docker-baseimage-selkies).
- Update tool recommended: Diun.

## Gotchas
- Hub description says HTTPS is required for some browser features.
- Tag family `version-<fx>build<n>-<ppa>` tracks Firefox version and PPA build.
