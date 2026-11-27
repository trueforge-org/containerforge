# Context: homepage

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homepage/values.yaml | truecharts-homepage.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homepage/Chart.yaml | truecharts-homepage.md |
| https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/Dockerfile (also blob URL) | github-gethomepage-homepage.md |
| https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/docker-entrypoint.sh | github-gethomepage-homepage.md |
| https://github.com/gethomepage/homepage (main page) | github-gethomepage-homepage.md (raw README, main) |
| https://github.com/benphelps/homepage | not fetched (old name, per plan; repo redirect) |
| https://api.github.com/repos/gethomepage/homepage/releases/tags/v2.8.0 | failed (403); alternative HTML release page used, in github-gethomepage-homepage.md |
| https://github.com/gethomepage/homepage/releases/tag/v2.8.0 | github-gethomepage-homepage.md (HTML title) |

Skipped categories: `benphelps/homepage` (old name); deploy/docs site links (gethomepage.dev) not fetched (budget); compose examples in README (not build inputs).

Failures:
- https://api.github.com/repos/gethomepage/homepage/releases/tags/v2.8.0: 403. One alternative (HTML release page): 200, no asset links.

## plan.md corrections
- `plan.md` line 24 (Host check): "The env name that allows extra hosts is UNVERIFIED (expected `HOMEPAGE_ALLOWED_HOSTS`; confirm ...)" -> "The env name is `HOMEPAGE_ALLOWED_HOSTS`" with source the upstream README (`main` branch, fetched 2026-11-27: "required, may need port"). Applied.
- Upstream facts in plan lines 19-23 match the fetched Dockerfile and docker-entrypoint.sh (NODE_ENV, HOSTNAME `::`, PORT 3000, EXPOSE, healthcheck path, entrypoint PUID/PGID logic, /app/config symlink). No other edits.
- Unverified (not edited): the README is from `main`, not the v2.8.0 tag; the plan's `HOSTNAME=0.0.0.0` in the proposed runtime env differs from upstream default `::`. Design choice, left to the plan.
