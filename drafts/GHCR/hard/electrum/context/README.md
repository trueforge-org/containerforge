# electrum context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/electrum/values.yaml | truecharts-electrum-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/electrum/Chart.yaml | truecharts-electrum-chart.md |
| https://raw.githubusercontent.com/ich777/docker-electrum/master/Dockerfile | ich777-docker-electrum-dockerfile.md |
| https://github.com/spesmilo/electrum/releases/tag/4.8.4 | electrum-release-4.8.4.md |

Skipped: github.com blob Dockerfile (same as raw), electrum.org home page (no build data), electrum.readthedocs.io (Sphinx user docs, FAQ/GUI only; no install or container facts), spesmilo/electrum repo page (HTML, covered by release and plan), debian.org/Docker Hub (not in urls.txt for this app).

Failures: none.

## plan.md corrections
- plan.md line 8: "No GitHub Release object for 4.8.4 (release API returns 404, release list empty)" is wrong. https://github.com/spesmilo/electrum/releases/tag/4.8.4 exists (published 2026-11-06 UTC). Edited the line to say a release exists; asset names still UNVERIFIED.
- Unverified (not edited): plan.md line 22 says electrum.readthedocs.io and electrum.org were not fetched. They were fetched this run, but neither gave build-relevant content.
- Upstream env, ports, user, and apt packages in plan.md lines 16-19 match ich777 Dockerfile.
