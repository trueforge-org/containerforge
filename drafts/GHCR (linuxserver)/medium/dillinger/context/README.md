# Context: dillinger

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dillinger/values.yaml + Chart.yaml | truecharts-dillinger.md |
| https://hub.docker.com/v2/repositories/linuxserver/dillinger/ (not in urls.txt; added per REQUIRED Docker Hub rule) | dockerhub-dillinger.md |
| https://raw.githubusercontent.com/linuxserver/docker-dillinger/1d1b7d5f198a81964e0e2b1428ba7d6bd4b1526e/Dockerfile | linuxserver-dockerfile.md |
| https://raw.githubusercontent.com/joemccann/dillinger/master/README.md; https://dillinger.io | upstream-readme.md |

Skipped: github.com blob duplicate of Dockerfile; joemccann/dillinger repo root (covered by README); www.dillinger.io (duplicate of dillinger.io). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in list.

Failures: none.

## plan.md corrections
- None applied.
- Unverified conflict: plan (line 23, 187) says upstream `engines.node` is 14.x and the entrypoint is an Express `app.js`. The master README (fetched) describes a Next.js app requiring Node 18+ with `npm run dev`/`npm start`. Not clear whether the README reflects tag v3.39.1; plan's claim not checked against the tag. Resolve against the v3.39.1 package.json before building.
- Upstream README says the app is Next.js; plan's `node app` launch path is from the linuxserver root/ scripts (not fetched here).
- Docker Hub: image deprecated (no updates since 20.03.24 per changelog); not mentioned in plan.
