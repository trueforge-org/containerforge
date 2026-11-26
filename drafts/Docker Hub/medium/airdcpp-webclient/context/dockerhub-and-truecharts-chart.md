# Docker Hub gangefors/airdcpp-webclient and TrueCharts airdcpp-webclient chart

## Source URL(s) + date
- https://hub.docker.com/r/gangefors/airdcpp-webclient (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/airdcpp-webclient/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/airdcpp-webclient/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/airdcpp-webclient not parsed.

## Docker Hub
- Title: "gangefors/airdcpp-webclient - Docker Image"
- Meta description: "AirDC++ Web Client Docker image"
- JS-rendered; tags not extractable.

## Chart (reference only)
- `airdcpp-webclient` chart version 16.0.0, appVersion 2.14.0. Depends on `common` 32.8.5.
- Image `docker.io/gangefors/airdcpp-webclient`, tag `2.14.0@sha256:3bb61bc49b586426c3225e338e5d8104d65a6b6903bb35812d05e9d39d64e4eb`.
- Service main: tcp, port 10155 -> targetPort 5600.
- Services enabled: unencrypted-tcp 21248 (tcp), encrypted-tcp 21249 (tcp), search-udp 21248 (udp).
- Persistence: `config` -> `/.airdcpp`.
- Probes: tcp on `/` (liveness, readiness, startup).
- No securityContext override in values (chart defaults apply).

## Gotchas
- Chart persistence path `/.airdcpp` matches upstream gangefors image. plan.md uses `/config` (ContainerForge layout).
- Chart does not expose 5601 (HTTPS); plan.md lists it.
