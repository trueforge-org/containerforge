# firefox-syncserver context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox-syncserver/values.yaml | truecharts-firefox-syncserver-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox-syncserver/Chart.yaml | truecharts-firefox-syncserver-chart.md |
| https://raw.githubusercontent.com/crazy-max/docker-firefox-syncserver/45fc9e0a5fa863fb109d5f4ae34b5d5e4656ee11/Dockerfile | crazy-max-docker-firefox-syncserver-dockerfile.md |
| https://moz-services-docs.readthedocs.io/en/latest/howtos/run-sync-1.5.html | mozilla-run-sync-1.5.md |
| https://api.github.com/repos/crazy-max/docker-firefox-syncserver/releases/latest (HTML fallback https://github.com/crazy-max/docker-firefox-syncserver/releases/latest) | crazy-max-firefox-syncserver-release.md |

Skipped: github.com blob Dockerfile (same as raw), github.com/mozilla-services/syncserver (HTML repo page, fetched once as alt, no content extracted; archived per plan.md), https://mozilla-services.github.io/syncstorage-rs (successor project, out of scope per plan.md; not fetched), Docker Hub/GHCR: none in urls.txt.

Failures:
- https://api.github.com/repos/mozilla-services/syncserver: HTTP 403. One alternative (github.com HTML repo page) fetched; no data extracted. Repo facts (archived, MPL-2.0) come from plan.md, not from this run.

## plan.md corrections
- plan.md line 17 (User): said `entrypoint.sh` creates the `syncserver` user via PUID/PGID. The Dockerfile RUN creates the group and user at build time (adduser/addgroup with PUID/PGID, default 1000). Edited the line. entrypoint.sh itself not fetched.
- Verified: plan.md line 11 release 1.8.0-r15 published 2021-03-04 (HTML page confirms date and tag). Python 2.7 base, EXPOSE 5000, VOLUME /data, PUID/PGID 1000 all match the Dockerfile.
