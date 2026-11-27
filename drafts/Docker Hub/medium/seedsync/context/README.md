# context: seedsync

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/seedsync/values.yaml | truecharts-seedsync.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/seedsync/Chart.yaml | truecharts-seedsync.md |
| https://hub.docker.com/v2/repositories/ipsingh06/seedsync/ (+ tags?page_size=10) | dockerhub-seedsync.md |
| https://api.github.com/repos/ipsingh06/seedsync/releases/tags/v0.8.6 | github-seedsync-dockerfile.md |
| https://api.github.com/repos/ipsingh06/seedsync/releases/latest (follow-up) | github-seedsync-dockerfile.md |
| https://raw.githubusercontent.com/ipsingh06/seedsync/ff2a103/src/docker/build/docker-image/Dockerfile | github-seedsync-dockerfile.md |
| https://raw.githubusercontent.com/ipsingh06/seedsync/master/src/docker/build/docker-image/setup_default_config.sh | github-seedsync-dockerfile.md |
| https://github.com/ipsingh06/seedsync (repo HTML) | skipped: api and raw variants used |
| https://github.com/ipsingh06/seedsync/blob/ff2a103/... Dockerfile | skipped: raw variant fetched |

Skipped categories: GitHub HTML/blob variants (raw or api used).

Failures: none.

## plan.md corrections
- No edits made.
- Resolved UNVERIFIED in plan line 8: `releases/latest` returns v0.8.6, so v0.8.6 is the newest release at fetch time.
- Confirmed: Dockerfile (python:3.8-slim base, EXPOSE 8800, USER seedsync uid 1000, /config and /downloads, CMD), setup_default_config.sh behaviour, release asset `seedsync_0.8.6_amd64.deb`.
- Still unverified (no URL in list): Apache-2.0 LICENSE (plan line 10), the raw LICENSE path returned 404 per plan and was not re-fetched.
