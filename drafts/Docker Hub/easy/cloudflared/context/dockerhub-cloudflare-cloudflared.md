# Docker Hub: cloudflare/cloudflared

Source URL(s) + fetch date:
- https://hub.docker.com/r/cloudflare/cloudflared · 2026-11-26

## What it is
Official Cloudflare image for the cloudflared Tunnel client. Publisher: cloudflare. Image size shown: 28.4 MB. Shows only the `latest` tag.

## Install/usage
- `docker pull cloudflare/cloudflared`
- Quick test (no account): `docker run cloudflare/cloudflared:latest tunnel --no-autoupdate --hello-world` (uses trycloudflare.com).
- Real use: create a tunnel in the Zero Trust dashboard (Access -> Tunnels), which gives a one-line `docker run` command with a token.

## Env vars
- None listed on the page.

## Arch support / user / entrypoint
- Architectures: not stated on the page. User: not stated. Entrypoint/CMD: not stated on the page (Dockerfile shows `ENTRYPOINT ["cloudflared"]`, `CMD ["version"]`; see github-cloudflare-cloudflared-dockerfile.md).

## Use cases described
1. Exposing private HTTP services on a public DNS hostname, optionally behind Cloudflare Access.
2. WARP-enrolled users get TCP/UDP access to private networks by IP and port.

## Version info
- Page showed digest beginning `sha256:55c7e3e8d…`, updated 3 days before fetch.
- TrueCharts chart uses `docker.io/cloudflare/cloudflared:2026.11.2@sha256:55c7e3e8d89d5e8d20b75a82f3602cbf98e06db406e73e282073cfdc5a9a3af6` (see truecharts-cloudflared.md). Draft.md's `2026.11.1` is therefore older than what the chart uses.
