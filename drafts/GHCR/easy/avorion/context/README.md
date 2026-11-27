# Sources for avorion (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avorion/values.yaml | truecharts-avorion.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avorion/Chart.yaml | truecharts-avorion.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cached copy) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide | valve-dedicated-server-guide.md (cached 403 record) |

Skipped: https://www.steampowered.com (generic store homepage, no build or config data).
Skipped: no Docker Hub URL (image is GHCR, ghcr.io/ich777/steamcmd, pinned by digest in chart).

Failures: Valve Dedicated Server Guide 403 (cached record, not retried).

## plan.md corrections
- None. Chart ports (27000 tcp/udp, 27003, 27020, 27021 udp) match plan line 17; plan still marks them UNVERIFIED, left unchanged.
