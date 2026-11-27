# Context: quake3

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quake3/values.yaml + Chart.yaml | truecharts-quake3.md |
| https://raw.githubusercontent.com/ich777/docker-quake3/master/Dockerfile | ich777-docker-quake3.md |
| https://github.com/ioquake/ioq3 (fallback page, HTML only; used for license check, no file written) | none |

Skipped (not fetched): Docker Hub (image is on GHCR); github.com Dockerfile blob URL (raw used); ioquake3.org home and players-guide (not build source); idsoftware.com; game data archive `linuxq3apoint-1.32b-3.x86.run` (binary download, not fetched); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://api.github.com/repos/ioquake/ioq3: 403. Alternative https://github.com/ioquake/ioq3 (HTML) fetched: confirmed license GPL-2.0. Last-push date not present in HTML and not verified.
- https://raw.githubusercontent.com/ich777/docker-quake3/master/start.sh: 404 (guessed path, not in urls.txt). start.sh contents unavailable.

## plan.md corrections
- None applied.
- Unverified: plan line 10 cites GitHub API last push 2026-11-04 for ioq3; not verifiable from fetched sources.
- Note: TrueCharts chart declares the service port 27960 as `udp` (values.yaml). Plan says UDP is unconfirmed; the chart is a fetched source that states it. Not edited.
