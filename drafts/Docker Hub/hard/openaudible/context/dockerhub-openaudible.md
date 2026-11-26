# Docker Hub: openaudible/openaudible

Source URL(s): https://hub.docker.com/r/openaudible/openaudible · fetched 2026-11-26

- Runs OpenAudible desktop app in browser via remote desktop; experimental, unsupported.
- Says built on linuxserver webtop, Ubuntu base. CONFLICT: repo Dockerfile uses `baseimage-kasmvnc:debianbookworm`.
- Tags: `latest` only; last updated ~10 months ago; ~966 MB; digest sha256:de29753b…; 100K+ pulls. Architectures not listed.
- License: GPL-3.0 (wrapper, per page); app is shareware.
- Quick start: `docker run -d --rm -it -v $HOME/OpenAudible:/config/OpenAudible -p 3000:3000 -e PGID=... -e PUID=... openaudible/openaudible:latest`.
- No password by default; one viewer at a time; no native HTTPS (reverse proxy ok).
