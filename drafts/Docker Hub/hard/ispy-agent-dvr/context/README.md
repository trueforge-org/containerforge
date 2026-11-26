# Context: ispy-agent-dvr

| Source URL | File |
| --- | --- |
| https://github.com/doitandbedone/ispyagentdvr-docker/blob/7.1.8.0/Dockerfile | doitandbedone-dockerfile-7.1.8.0.md |
| https://github.com/doitandbedone/ispyagentdvr-docker | doitandbedone-readme.md |
| https://github.com/ispysoftware/agentdvr-docker | ispysoftware-agentdvr-docker.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ispy-agent-dvr | truecharts-ispy-agent-dvr-chart.md |
| https://hub.docker.com/r/doitandbedone/ispyagentdvr | hub-docker-doitandbedone-ispyagentdvr.md |
| https://www.ispyconnect.com | ispyconnect-home.md |
| https://www.ispyconnect.com/api/Agent/DownloadLocation4?platform=Linux64&fromVersion=0 | ispyconnect-downloadlocation-api.md |
| https://www.ispyconnect.com/docs/agent | ispyconnect-docs-agent.md |
| https://www.ispyconnect.com/producthistory?productid=27 | ispyconnect-producthistory.md |

Skipped categories: none in urls.txt. The zip URL returned by the DownloadLocation API was recorded, not downloaded.

## Failures
- None.

## plan.md corrections
- No edits made. Plan's 8.3.2.0 pin matches the DownloadLocation API and the product history page.
- Unverified conflict: plan says ffmpeg comes from apt (`ffmpeg` in the apt list and "ffmpeg comes from apt"). The official ispysoftware README says the image bundles an LGPL FFmpeg build and downloads an optional GPL build into the config volume. Decide the apt ffmpeg question with the vendor zip contents.
- Unverified conflict: plan says UDP range 50000-50100. The doitandbedone Docker Hub page shows 50000-50010 and its Config.xml defaults are 50000-50010. The official README and the other docs say 50000-50100.
