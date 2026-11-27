# Sources for blocky (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blocky/values.yaml | truecharts-blocky.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blocky/Chart.yaml | truecharts-blocky.md |
| https://api.github.com/repos/0xERR0R/blocky/license | github-blocky.md |
| https://github.com/0xERR0R/blocky/releases/tag/v0.37.0 | github-blocky.md (via api.github.com releases/tags/v0.37.0) |
| https://github.com/0xERR0R/blocky/blob/master/Dockerfile | github-blocky.md |
| https://github.com/0xERR0R/blocky/blob/2d6f7d4be5e39717c9ebb66c365d7ab2ae620edd/Dockerfile | github-blocky.md (raw variant fetched) |
| https://github.com/0xERR0R/blocky/blob/master/docs/config.yml | blocky-docs.md (raw variant) |
| https://github.com/0xERR0R/blocky/blob/master/docs/configuration.md | blocky-docs.md (raw variant) |
| https://0xerr0r.github.io/blocky | blocky-docs.md (redirect stub, no content) |
| https://0xerr0r.github.io/blocky/latest | not fetched: same docs as configuration.md |
| https://github.com/0xERR0R/blocky | not fetched: repo root, covered by license and release API calls |

Skipped (out of plan scope or third-party): https://github.com/k8s-gateway/k8s_gateway (sidecar, plan section 10), https://github.com/k8s-gateway/k8s_gateway/blob/fc34def22c7802832aa10870b1fa8bbe310fe541/Dockerfile, https://github.com/Mozart409/blocky-frontend (third-party frontend). No Docker Hub URL (GHCR image).

Failures: none.

## plan.md corrections
- None. Version 0.37.0, Apache-2.0, asset names, UID 100, BLOCKY_CONFIG_FILE=/app/config.yml, DNS 53 default, HTTP 4000 example and healthcheck command all match fetched sources.
- Note for plan review (no edit): chart values use ports 53 (udp/tcp), 853, 4443 and k8s 5353/udp; plan uses 5353 and 4000 for the seed. Not a factual error about upstream.
