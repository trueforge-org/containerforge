# Context sources: wdosg

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/SoulRaven80/wdosg | github-soulraven80-wdosg.md |
| https://github.com/SoulRaven80/wdosg/blob/db267e9/Dockerfile | github-soulraven80-wdosg.md (raw Dockerfile at v1.3.9; plan says identical at db267e9) |
| https://github.com/SoulRaven80/wdosg/archive/refs/tags/v1.3.9.tar.gz | github-soulraven80-wdosg.md (archive; pattern only) |
| https://github.com/SoulRaven80/wdosg/tags | github-soulraven80-wdosg.md (tags and releases) |
| https://hub.docker.com/r/soulraven1980/wdosg | dockerhub-soulraven1980-wdosg.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wdosg | truecharts-wdosg.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/SoulRaven80/wdosg/archive/refs/tags/v${VERSION#v}.tar.gz | placeholder archive download |
| http://127.0.0.1:3001/ | localhost / 127.0.0.1 |
| ghcr.io/trueforge-org/python-node, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| docker.io/soulraven1980/wdosg:latest | image ref, covered by the Docker Hub page |

## Fetch failures

None. The GitHub tags page was read at the first page only (v1.3.9 to v1.3.0).

## plan.md corrections

Edited (old -> new, source: github-soulraven80-wdosg.md, package.json at v1.3.9):

1. plan.md section 1 Dependencies row: `better-sqlite3@^12.8.0` -> `sqlite3@^5.1.7`; `express@^4` -> `express@^4.21.1`; `pino`, `pino-pretty` -> `pino@^9.5.0`, `pino-pretty@^13.0.0`; `nodemailer@^8` -> `nodemailer@^6.9.16`; `cheerio` (absent) removed; `adm-zip` -> `adm-zip@^0.5.16`; `image-downloader` -> `image-downloader@^4.3.0`. Reason: the v1.3.9 package.json lists `sqlite3` and does not list `better-sqlite3` or `cheerio`.
2. plan.md section 1 Source row: native `better-sqlite3` -> native `sqlite3`.
3. plan.md section 3: `better-sqlite3@12` -> `sqlite3@5` (Node-version note).
4. plan.md section 4: fallback `build-essential` note: `better-sqlite3` -> `sqlite3`.
5. plan.md section 8 filePaths: `/app/wdosg/node_modules/better-sqlite3` -> `/app/wdosg/node_modules/sqlite3`. (Without this the container test would fail on a missing path.)
6. plan.md section 10 (two bullets): `better-sqlite3` -> `sqlite3`.

Notes (not edited):
- unverified: `GPL-3.0-only` (plan.md) versus the file text (GPLv3, no "only"/"or later" notice). The LICENSE is GPLv3; the package.json says ISC. Left as plan states, the conflict is already noted in plan.md.
- confirmed: upstream Dockerfile (`node:23-alpine3.19`, EXPOSE 3001, `CMD ["node","index"]`), port 3001 (draft's port 3000 was wrong), GPLv3 license text, latest tag v1.3.9.
- unverified: plan.md section 1 Renovate note "Docker Hub tags `latest`, v1.3.9, v1.3.8". Docker Hub showed only `latest`.
- not in plan: README gives default admin login `wdosg@wdosg.com` / `wdosg`. This is a gotcha for the PR and the container docs.
- not in plan: chart sets fake IGDB credentials (`fake_client_id`), while plan.md defaults `TWITCH_CLIENT_ID` to `DISABLED`. plan.md default was kept.
- unverified: readiness log text and the `process.exit(1)` behaviour when IGDB credentials are empty (not confirmed by fetched content; README only says "Needed for IGDB metadata").
