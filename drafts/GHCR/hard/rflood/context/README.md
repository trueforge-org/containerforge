# Context: rflood

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rflood/values.yaml + Chart.yaml | truecharts-rflood.md |
| https://raw.githubusercontent.com/hotio/rflood/194a3cbe1452/linux-amd64.Dockerfile (blob URL at same commit is a duplicate) | hotio-rflood-linux-amd64-dockerfile.md |
| https://hotio.dev/containers/rflood | hotio-rflood-page.md |
| https://github.com/jesec/flood (fetched as raw README on master) | jesec-flood-readme.md |
| https://api.github.com/repos/rakshasa/rtorrent (403), recovered via https://github.com/rakshasa/rtorrent/releases/latest | rtorrent-release-latest.md |

Skipped: github.com/rakshasa/rtorrent repo HTML (covered by the release page); duplicate blob Dockerfile; no separate fetch of the flood Linux binary (download, not fetched).
No Docker Hub URL in list (image is GHCR).

Failures: none unrecovered. The rtorrent release API returned 403 (rate limit); the HTML release page was used.

## plan.md corrections
1. Line 8 (Chart image): digest `sha256:cc8e4ae3...572a36` -> `sha256:92e3c258...c806acb` (source: TrueCharts values.yaml `latest@sha256:92e3c258699714bae99c7471ccf256ef03afb085b1e05fe7cfbc0a3b0c806acb`).
2. Line 9 (Latest stable version): "hotio publishes no semver tag" replaced. hotio.dev lists `release-0.16.29`-style tags (2026-11-26); latest rtorrent release is v0.16.29 (source: hotio-rflood-page.md, rtorrent-release-latest.md). The hotio VERSION build arg is still not in the fetched Dockerfile.

Unverified conflicts (not edited):
- Plan line 19 says the BitTorrent 6881 port is not in the chart or upstream Dockerfile. Confirmed for the chart and Dockerfile. The hotio page lists 3000 and 5000 (nginx RPC) only. Consistent, no edit.
- Plan line 11 gives rtorrent license GPL-2.0 from the API (not re-checked, API 403).
