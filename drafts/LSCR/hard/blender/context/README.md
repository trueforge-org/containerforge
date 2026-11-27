# context index: blender (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blender/values.yaml | truecharts-blender.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blender/Chart.yaml | truecharts-blender.md |
| https://raw.githubusercontent.com/linuxserver/docker-blender/16e1a2aec1d331f2a4462eb52538b99d6d1c2932/Dockerfile (+ root/defaults/autostart) | linuxserver-docker-blender.md |

Skipped (category): https://download.blender.org/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz (binary download); https://packages.ubuntu.com/resolute/arm64/blender/download (package index, not fetched); https://fleet.linuxserver.io/image?name=linuxserver/blender (image-ref / fleet page, not fetched); https://github.com/orgs/linuxserver/packages/container/package/blender (package page, not fetched); https://github.com/linuxserver/docker-blender (repo page; duplicate of raw); https://github.com/linuxserver/docker-blender/blob/...Dockerfile (duplicate); https://github.com/blender/blender (upstream repo, not fetched); https://docs.blender.org/manual/en/latest and https://www.blender.org (docs/marketing, not fetched).

Failures:
- https://raw.githubusercontent.com/linuxserver/docker-blender/16e1a2aec1d331f2a4462eb52538b99d6d1c2932/root/etc/s6-overlay/s6-rc.d/svc-blender/run : 404 (guessed path, not retried).

## plan.md corrections
- None edited. Unverified conflict (not edited): plan says port 3000 is UNVERIFIED (draft). The chart maps 3000 -> 3000 while the upstream Dockerfile EXPOSEs 3001. Which port the Selkies base serves was not verified (baseimage-selkies Dockerfile not fetched).
