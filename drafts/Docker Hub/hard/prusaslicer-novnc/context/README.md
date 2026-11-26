# Context: prusaslicer-novnc

| Source URL | File |
| --- | --- |
| https://github.com/helfrichmichael/prusaslicer-novnc/blob/master/Dockerfile | helfrichmichael-prusaslicer-novnc-dockerfile.md (merged: entrypoint.sh, supervisord.conf, get_latest_prusaslicer_release.sh) |
| https://github.com/prusa3d/PrusaSlicer | prusaslicer-readme.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/prusaslicer-novnc | truecharts-prusaslicer-novnc-values.md |
| https://hub.docker.com/r/mikeah/prusaslicer-novnc | dockerhub-mikeah-prusaslicer-novnc.md |

Skipped categories: none beyond pre-filtering (urls.txt already filtered).
Failures:
- https://www.prusa3d.com/prusaslicer : fetched (200) but the response is JS/tracking only, no usable page text. No file written.

## plan.md corrections
- Line 15, wrapper env: `SUPD_LOGLEVEL` (INFO) -> `SUPD_LOGLEVEL` (TRACE). Source: helfrichmichael entrypoint.sh (`SUPD_LOGLEVEL="${SUPD_LOGLEVEL:-TRACE}"`).
- Unverified (not checked, API not fetched): plan line 12 claim that release 2.9.7 has no Linux AppImage asset. Upstream README states Linux is distributed via Flathub only, which is consistent with it; the wrapper's release-script regex `linux-x64-older-distros-GTK3.*AppImage$` is unverified against current assets.
