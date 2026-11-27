# Context: arma3

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3/values.yaml + Chart.yaml | truecharts-arma3.md |
| https://arma3.com | arma3-com.md |
| https://community.bistudio.com/wiki/Arma_3_Dedicated_Server | bistudio-wiki-arma3-dedicated-server.md (403, failure record) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (copied from shared cache docs/context) |
| https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide | valve-dedicated-server-guide.md (copied from cache; 403 record) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile, https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile, https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh | ich777-docker-steamcmd-server.md (copied from cache) |

Skipped categories: none beyond the filtering already applied to urls.txt. Docker Hub not applicable (GHCR image, ghcr.io/ich777/steamcmd base tag).

Cache: 3 summaries copied from docs/context/ (ubuntu-archive, valve-dedicated-server-guide, ich777-docker-steamcmd-server).

Failures:
- https://community.bistudio.com/wiki/Arma_3_Dedicated_Server: HTTP 403 (Cloudflare challenge); ?action=raw alternative attempted, not usable
- https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide: 403 (from shared cache, not retried)

## plan.md corrections
None edited. Unverified conflict: chart declares main port 2302 as tcp (plan EXPOSE lists 2302/udp only). Chart mainudp is 2302/udp, so the plan may need 2302/tcp too (not changed).
