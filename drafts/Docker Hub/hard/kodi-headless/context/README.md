# Context: kodi-headless

| Source URL | File |
| --- | --- |
| https://github.com/linuxserver/docker-kodi-headless/blob/8962e35/Dockerfile | linuxserver-dockerfile.md |
| https://github.com/linuxserver/docker-kodi-headless/tree/8962e35 (repo tree) | linuxserver-dockerfile.md |
| https://github.com/linuxserver/docker-kodi-headless | kodi-headless-readme.md |
| https://github.com/xbmc/xbmc | xbmc-repo.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kodi-headless | truecharts-kodi-headless-chart.md |
| https://hub.docker.com/r/linuxserver/kodi-headless | hub-docker-linuxserver-kodi-headless.md |
| (follow-up) https://github.com/linuxserver/docker-kodi-headless/blob/8962e35/root/etc/s6-overlay/s6-rc.d/svc-kodi/run | FAILED (404, guessed path) |

Skipped categories: none in urls.txt.

## Failures
- Follow-up `root/etc/s6-overlay/s6-rc.d/svc-kodi/run` at 8962e35: 404 (path was a guess; the tree listing did not show root/ contents). Not retried. The s6 run/PUID handling is therefore not documented here.

## plan.md corrections
- No edits made.
- Unverified conflict: plan says LICENSE `GPL-2.0-or-later`. The xbmc/xbmc README fetched says "GPLv2" (no "or later" wording). Confirm against xbmc LICENSE.md before pinning.
- Not verifiable from these sources: plan's Kodi 21.3 target, apt package versions, and the "archived 2022-02-24" date. The upstream linuxserver image is pinned to Kodi 18.5 (Leia), which is the version the draft ships.
