# TrueCharts chart: cloudflared

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloudflared (directory; content read from raw `charts/stable/cloudflared/values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: repository `docker.io/cloudflare/cloudflared`, tag `2026.11.2@sha256:55c7e3e8d89d5e8d20b75a82f3602cbf98e06db406e73e282073cfdc5a9a3af6`, pullPolicy `IfNotPresent`.
- Container args: `tunnel`, `--no-autoupdate`, `run`.
- Env: `TUNNEL_TOKEN` from secret `env-secrets` key `TUNNEL_TOKEN` (secret enabled, value empty string).
- Service: main service and its main port disabled.
- Probes (liveness, readiness, startup): all disabled.
- securityContext / podSecurityContext / persistence: not set in values (chart/library defaults apply; see draft.md).

## Gotchas / contradictions with plan.md
- Chart currently pins `2026.11.2`, the draft says `2026.11.1`. Plan.md already uses `2026.11.2`.
- Chart runs `tunnel --no-autoupdate run`, which is consistent with plan.md's start.sh command line.
