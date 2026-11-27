# context index: kdenlive (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kdenlive/values.yaml | truecharts-kdenlive.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kdenlive/Chart.yaml | truecharts-kdenlive.md |
| https://raw.githubusercontent.com/linuxserver/docker-kdenlive/f39884e7d1d55d31dd0babb973c1cb0ea066d84f/Dockerfile (+ root/defaults/autostart) | linuxserver-docker-kdenlive.md |

Skipped (category): https://packages.ubuntu.com/resolute/kdenlive (Ubuntu package index, not fetched this run; plan cites 4:25.12.3-0ubuntu1.1 from earlier work); https://fleet.linuxserver.io/image?name=linuxserver/kdenlive (image-ref / fleet page); https://github.com/orgs/linuxserver/packages/container/package/kdenlive (package page); https://github.com/linuxserver/docker-kdenlive/blob/...Dockerfile (duplicate of raw); https://github.com/KDE/kdenlive (upstream repo, not fetched); https://docs.kdenlive.org and https://kdenlive.org (docs/site, not fetched).

Failures: none.

## plan.md corrections
- None edited. Unverified conflict (not edited): plan line 16 says port 3000 is "UNVERIFIED" on the upstream image. The chart maps 3000 -> 3000; the upstream Dockerfile EXPOSEs 3001 only. Port served by the Selkies base was not verified here (baseimage-selkies not fetched).
