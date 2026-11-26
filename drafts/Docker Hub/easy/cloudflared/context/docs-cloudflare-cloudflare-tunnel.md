# Cloudflare docs: Cloudflare Tunnel (connectors)

Source URL(s) + fetch date:
- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/ · 2026-11-26

## What it is
- `cloudflared` is a lightweight daemon that runs in your infrastructure and opens outbound-only connections to Cloudflare's network.
- A tunnel is a persistent object identified by a UUID. Multiple `cloudflared` processes (connectors) can run in one tunnel; each sends traffic to the nearest Cloudflare data center.
- Once connected, traffic flows both ways. Firewalls can block all inbound traffic so the origin is reachable only through Cloudflare.
- Supported protocols: HTTP, SSH, RDP, and other protocols.
- Authenticated Origin Pulls has no effect on Tunnel hostnames; origin traffic uses the tunnel's connector credentials.
- Tunnels are created in the Cloudflare dashboard or via the API.
- Page scope: private networking and Zero Trust. Public app publishing is documented elsewhere in the Tunnel docs. Cloudflare Mesh is described as the default connector for private access.

## Not covered by this page
- Token vs credentials file, outbound ports/hostnames, supported OSes, env vars, metrics and config file references. (Plan.md's env var list is not confirmed by this page; see the README/Dockerfile summaries and treat as unverified.)
