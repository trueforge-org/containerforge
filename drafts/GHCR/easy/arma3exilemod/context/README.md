# Context: arma3exilemod

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3exilemod/values.yaml + Chart.yaml | truecharts-arma3exilemod.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (copied from docs/context cache) |
| https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide | valve-dedicated-server-guide.md (copied from cache; 403 record) |
| https://community.bistudio.com/wiki/Arma_3_Dedicated_Server | bistudio-wiki-arma3-dedicated-server.md (copied from the arma3 app; 403 record) |
| ich777 docker-steamcmd-server Dockerfile (blob + raw) | ich777-docker-steamcmd-server.md (copied from cache) |

Skipped categories: none beyond the filtering already applied to urls.txt. Docker Hub not applicable (GHCR image).

Failures:
- https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide: 403 (shared cache, not retried)
- https://community.bistudio.com/wiki/Arma_3_Dedicated_Server: 403 (Cloudflare; arma3 app record, not retried)

## plan.md corrections
- Line 12 (Download): "the chart shows no install URL: UNVERIFIED" -> chart values.yaml sets `EXILEMOD_SERVER_URL` = http://www.exilemod.com/ExileServer-1.0.4a.zip (source: truecharts-arma3exilemod.md). Edited in plan.md.
