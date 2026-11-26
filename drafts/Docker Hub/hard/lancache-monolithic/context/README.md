# Context: lancache-monolithic

| Source URL | File |
| --- | --- |
| http://lancache.net/docs/containers/monolithic | lancache-docs-monolithic.md |
| (follow-up) https://lancache.net/docs/containers/monolithic/variables/ | lancache-docs-monolithic-variables.md |
| https://github.com/lancachenet/monolithic/blob/3f43cc7/Dockerfile | dockerfile-3f43cc7.md |
| https://github.com/lancachenet/monolithic/blob/master/Dockerfile | dockerfile-master.md |
| https://github.com/lancachenet/monolithic | lancache-monolithic-readme.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lancache-monolithic | truecharts-lancache-monolithic-chart.md |
| https://github.com/uklans/cache-domains | uklans-cache-domains.md |
| https://hub.docker.com/r/lancachenet/monolithic | hub-docker-lancachenet-monolithic.md |
| https://lancache.net | lancache-net-home.md (copied from sibling lancache-dns context, same URL) |

Skipped categories: none in urls.txt.

## Failures
- None.

## plan.md corrections
- Edit 1 (line 9, upstream facts): `nginx:1.28.3` -> `lancachenet/ubuntu-nginx:latest`. Source: dockerfile-3f43cc7.md (FROM).
- Edit 2 (line 14): `CACHE_MEM_SIZE` (docs) vs `CACHE_INDEX_SIZE` claim corrected. Source: lancache-docs-monolithic-variables.md and dockerfile-3f43cc7.md list CACHE_INDEX_SIZE; only the overview docs page says CACHE_MEM_SIZE.
- Edit 3 (line 81, open question): reworded to match Edit 2. Source: same.
- Unverified: plan's line 24 base choice (trueforge nginx) is the plan's own decision, not checked. Overlay file contents not fetched.
