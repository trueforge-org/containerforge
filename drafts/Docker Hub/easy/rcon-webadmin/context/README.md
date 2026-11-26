# rcon-webadmin context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/itzg/docker-rcon-web-admin/blob/484fba3/Dockerfile | github-itzg-docker-rcon-web-admin.md | fetched via raw at commit 484fba3 |
| https://github.com/rcon-web-admin/rcon-web-admin | github-rcon-web-admin-rcon-web-admin.md | repo; README via raw master |
| https://raw.githubusercontent.com/rcon-web-admin/rcon-web-admin/master/README.md | github-rcon-web-admin-rcon-web-admin.md | fetched |
| https://github.com/rcon-web-admin/rcon-web-admin/releases/tag/0.14.1 | github-rcon-web-admin-rcon-web-admin.md | fetched; asset names did not render |
| https://hub.docker.com/r/itzg/rcon | dockerhub-itzg-rcon.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rcon-webadmin | truecharts-rcon-webadmin.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rcon-webadmin/values.yaml | truecharts-rcon-webadmin.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| http://127.0.0.1:4326/ | localhost address |
| https://github.com/rcon-web-admin/rcon-web-admin/archive/${VERSION}.tar.gz | contains ${; direct archive download, pattern recorded |
| https://github.com/rcon-web-admin/rcon-web-admin/archive/0.14.1.tar.gz | direct archive download, pattern recorded |

## Fetch failures

- None. Release asset list did not render (page loaded).

## plan.md corrections

No edits made. Context agrees with plan.md on: version 0.14.1 (release 09 Jun, year not shown), MIT-era fork under rcon-web-admin/rcon-web-admin, node:12 upstream base, `EXPOSE 4326 4327`, `VOLUME /opt/rcon-web-admin/db`, `RWA_ENV=TRUE`, env var names and defaults, `RWA_PASSWORD` required.

Unverified items (not edited):
- plan.md section 1 says the package.json in the tarball still says 0.13.3. Not checked.
- plan.md section 1 says RWA_PASSWORD missing makes the app exit with code 1 (src/env.js). Source not fetched; the itzg README only says the variable is required.
- plan.md section 1 says the widgets are installed from master zips and names rwa-autobot, rwa-console, rwa-rustboard, rwa-timedcommands. Not verified here.
- plan.md section 1 says `config.template.js` gives 4327 as port + 1 and host null. Not verified here.
- plan.md section 1 gives the sha256 of the 0.14.1 tarball. Not checked.
- plan.md section 1 gives the 0.14.1 release date as 2020-06-09. The release page shows "09 Jun" with no year; the year is unverified here.
