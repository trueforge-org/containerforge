# Kozea/Radicale (GitHub) and radicale.org homepage

Source URL(s) + fetch date (2026-11-26):
- https://github.com/Kozea/Radicale (repo; README via https://raw.githubusercontent.com/Kozea/Radicale/master/README.md, fetch returned the radicale.org homepage text, not the README body)
- https://radicale.org (website)
- Not fetched: https://raw.githubusercontent.com/Kozea/Radicale/v${VERSION}/COPYING.md (contains ${, skipped; plan.md records GPL-3.0-or-later)

## What it is
"A small but powerful CalDAV (calendars, to-do lists) and CardDAV (contacts) server." GPLv3 free software, extensible with plugins. Shares calendars and contacts over CalDAV, CardDAV and HTTP; handles events, todos, journal entries and business cards; optional authentication and TLS; keeps all data in a simple folder structure on disk.

## Install/build steps
- Not on the fetched pages. Per plan.md: `pip install radicale` (pure Python wheel, version 3.9.2, requires-python >= 3.9.0). Not verified from the fetched text.

## Runtime deps
- Not on fetched pages. Per plan.md: defusedxml, libpass >= 1.9.3, vobject >= 0.9.6; extra `bcrypt`.

## Binaries/entrypoint/CLI flags
- Not on the fetched homepage. See docs-radicale-org-v3.md for flags.

## Docker
- Website and README summary do not mention Docker. Docker image details are in github-tomsquest-docker-radicale.md.

## Ports, volumes, env, user, healthcheck
- Not on the fetched homepage. See docs-radicale-org-v3.md (port default localhost:5232) and github-tomsquest-docker-radicale.md.

## Version/release info
- Per plan.md: GitHub v3.9.2 (released 2026-11-17). Not verified here.

## License
- GPL-3.0-or-later per plan.md. The homepage states GPLv3 free software.

## Gotchas
- The README fetch returned the website text, so the README itself was not read. Use radicale.org/v3.html for config reference.
