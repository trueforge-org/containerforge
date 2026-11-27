# TrueCharts chart: pocketmine-mp (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pocketmine-mp/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pocketmine-mp/Chart.yaml (2026-11-27)

What it is: "A server software for Minecraft Bedrock Edition in PHP." Chart `version: 9.0.0`, `appVersion: 5.44.3`. Category games.

Image (values.yaml):
- repository `ghcr.io/pmmp/pocketmine-mp`
- tag `5.44.3@sha256:58bc978b4ef951025d6fb03f5d95af118bb327b9fcb0438eb172c0bb2612ebb7`
- pullPolicy IfNotPresent

Ports (service main): protocol udp, port 19132, targetPort 19132. (Upstream also exposes 19132/tcp and 19133/udp.)

Volumes/paths:
| Persistence | mountPath |
| --- | --- |
| data | `/data` |
| plugins | `/plugins` |

User/UID: `runAsUser: 0`, `runAsGroup: 0`, readOnlyRootFilesystem false (root in chart). Upstream image runs as `pocketmine` (UID/GID 1000).

Container: `tty: true`, `stdin: true`.

Probes: liveness, readiness, startup all `enabled: false` (no HTTP/TCP probe for a UDP game server).

Gotchas:
- Chart service is UDP only; upstream image also has a TCP 19132 EXPOSE.
- No env vars set in values; upstream reads POCKETMINE_PLUGINS and POCKETMINE_ARGS in start.sh.
