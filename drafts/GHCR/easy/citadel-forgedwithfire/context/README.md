# Sources for citadel-forgedwithfire (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/citadel-forgedwithfire/values.yaml | truecharts-citadel-forgedwithfire.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/citadel-forgedwithfire/Chart.yaml | truecharts-citadel-forgedwithfire.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server/branches | github-ich777-citadelfwf-branch.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=citadelfwf | github-ich777-citadelfwf-branch.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=citadelfwf | github-ich777-citadelfwf-branch.md |
| https://store.steampowered.com/api/appdetails?appids=489650 | steam-appdetails-489650.md (success:false) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cached copy) |
| https://github.com/ich777/docker-steamcmd-server | ich777-docker-steamcmd-server.md (cached copy, master) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy, master) |

Skipped: https://store.steampowered.com/app/489650 and /search/?term=Citadel+Forged+with+Fire (store HTML and search; appdetails already returned success:false); https://www.steampowered.com (generic homepage). No Docker Hub URL (GHCR image).

Failures:
- Steam appdetails for 489650 returned `success:false`. Not retried.

## plan.md corrections
- None made. Chart tag, ports 7777/27015 udp, GAME_ID trailing-space note and branch layout match the fetched sources.
- Unverified note for review (no edit): plan line 15 says the citadelfwf Dockerfile is "the same layout" as chivalrymw. The file content differs (apt installs only lib32gcc-s1 here, no i386 libstdc++ install), so this is a wording gap, not a clear factual error; left unchanged.
