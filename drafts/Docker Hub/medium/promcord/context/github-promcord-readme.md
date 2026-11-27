# GitHub README: promcord (Biospheere/promcord)

Source URL(s):
- https://raw.githubusercontent.com/nimarion/promcord/master/README.md (content is the Biospheere/promcord README)
Fetched: 2026-11-27

## What it is
Discord bot that collects server metrics for Prometheus; visualised with Grafana. License: MIT (LICENSE file).

## Runtime deps (documented)
- JDK, Maven (dev build), Prometheus, Grafana.
- Config via env var only: `DISCORD_TOKEN=<token>` (in `.env` for docker-compose).

## Install methods (documented)
- Docker Compose (local and production). Uses `prometheus.yml` and `grafana.json` from repo.
- Kubernetes: points to a community Helm chart (k8s-at-home), not this app's image.
- Developer: fork, clone, Maven build.

## Metrics / data collected (summary)
Voice/text channel IDs, message word count and length, guild ID, emote name, game name (Discord RPC), toxicity score (Perspective API), member and online counts, voice/stream time, nitro boosts, gateway and REST ping.

## Ports (documented in compose setup)
- Grafana on 80 (local) / 3000; Prometheus on 9090. The bot itself: not stated in README (chart uses 8080).

## Gotchas
- Perspective API is optional external dependency for the toxicity metric.
- Dockerfile and README sit in the nimarion fork and Biospheere upstream; README links the Biospheere repo.
