# Context: xware

| Source URL | File |
| --- | --- |
| https://github.com/caiguai/docker-xware | caiguai-docker-xware.md |
| https://github.com/caiguai/docker-xware/blob/master/Dockerfile | caiguai-docker-xware.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xware | truecharts-xware-chart.md |
| https://hub.docker.com/r/caiguai/docker-xware | dockerhub-and-xunlei-sites.md |
| https://help.xunlei.com | dockerhub-and-xunlei-sites.md |
| https://www.xunlei.com | dockerhub-and-xunlei-sites.md |

Skipped categories:
- Binary download (not fetched): `https://github.com/caiguai/docker-xware/raw/2ea1f2f62c173d44beaef2a44005cc2696d2710c/xware.tar.bz`, `https://github.com/caiguai/docker-xware/raw/master/xware.tar.bz` (both still in urls.txt despite the filter; not downloaded per rule).

Failures: none.

Notes:
- `start.sh`, bundled `.deb` files, and the README were not all fetched; start.sh behaviour comes from plan.md only.

## plan.md corrections
- None. Dockerfile matches plan.md section 15 (debian:wheezy-slim, dpkg of bundled debs, ADD xware.tar.bz to /xware/bin/, VOLUME /xware/TDDOWNLOAD, EXPOSE 9000, CMD ./start.sh).
