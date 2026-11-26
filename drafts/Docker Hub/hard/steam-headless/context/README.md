# context: steam-headless

| Source URL | File |
| --- | --- |
| https://github.com/Steam-Headless/docker-steam-headless/blob/824c88d/Dockerfile.debian (+ overlay/entrypoint.sh, docs/docker-compose.md) | steam-headless-dockerfile-debian.md, steam-headless-entrypoint-and-compose-docs.md |
| https://github.com/Steam-Headless/docker-steam-headless (+ README raw) | steam-headless-readme.md |
| https://hub.docker.com/r/josh5/steam-headless | dockerhub-josh5-steam-headless.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/steam-headless | truecharts-steam-headless.md |
| https://store.steampowered.com/about | steam-store-about.md |

Skipped categories: none present in urls.txt.

## Failures
- none

## plan.md corrections
- none applied (no proven factual error).
- Notes: upstream defaults include baked credentials (USER_PASSWORD=password, NEKO_PASSWORD=neko, NEKO_PASSWORD_ADMIN=admin); TrueCharts runs privileged.
- Sunshine pinned to `v2026.516.143833` in Dockerfile.debian at commit 824c88d.
