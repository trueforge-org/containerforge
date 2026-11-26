# Docker Hub: chvb/docker-kerio-connect

Source URL(s): https://hub.docker.com/r/chvb/docker-kerio-connect. Fetched 2026-11-26.

- Description: containerized Kerio Connect, version 9.2.9 Patch 1. Unofficial, unaffiliated; use at own risk.
- Tags: `latest` only. Size ~588 MB. Last updated >7 years ago. 50K+ pulls.
- Pull: `docker pull chvb/docker-kerio-connect:latest`. Architectures not stated.
- Run: `docker run --name="kerio"` with port + volume mappings, `-t chvb/docker-kerio-connect`.
- Volumes: config -> `/opt/kerio`, data -> `/kerio_store`, backup -> `/backup`.
