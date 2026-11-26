# radicale context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/Kozea/Radicale | github-kozea-radicale.md | repo; README fetch returned website text |
| https://radicale.org | github-kozea-radicale.md | fetched (homepage) |
| https://radicale.org/v3.html | docs-radicale-org-v3.md | fetched; first 100000 of 116223 chars |
| https://github.com/tomsquest/docker-radicale | github-tomsquest-docker-radicale.md | repo; README not fetched |
| https://github.com/tomsquest/docker-radicale/blob/master/Dockerfile | github-tomsquest-docker-radicale.md | fetched via raw master |
| https://github.com/tomsquest/docker-radicale/blob/3.9.2.0/Dockerfile | github-tomsquest-docker-radicale.md | fetched (tag 3.9.2.0) |
| https://hub.docker.com/r/tomsquest/docker-radicale | dockerhub-tomsquest-docker-radicale.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/radicale | truecharts-radicale.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/radicale/values.yaml | truecharts-radicale.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps base link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| http://127.0.0.1:5232/alice/ | localhost address |
| https://raw.githubusercontent.com/Kozea/Radicale/v${VERSION}/COPYING.md | contains ${ |

## Fetch failures

- None. The Kozea README fetch returned homepage text instead of README contents (recorded in github-kozea-radicale.md, not a fetch failure).

## plan.md corrections

No edits made.

Conflicts and unverified items (not edited):
- plan.md section 1 (Defaults row) says `storage.filesystem_folder` has no default and the user must set it. radicale.org/v3.html (docs-radicale-org-v3.md) states the default is `/var/lib/radicale/collections`. Sources disagree; the plan's statement comes from `radicale/config.py`, which was not fetched. Unverified.
- plan.md section 1 gives `server.hosts = localhost:5232` and `auth.type = denyall` (since 3.5.0), `auth.htpasswd_encryption = autodetect`, `rights.type = owner_only`. Docs confirm hosts default localhost:5232, denyall for >= 3.5.0, autodetect for >= 3.3.0. Consistent.
- plan.md section 1 says Radicale 3.9.2 was released 2026-11-17 and requires-python >= 3.9.0. Not verified in these sources.
- plan.md says the tomsquest Dockerfile is at `master` and tag `3.9.2.0` not fetched. Tag 3.9.2.0 is now fetched; its content matches plan.md's description (alpine:3, /venv, radicale==$VERSION, /config/config, /data, UID/GID 2999, EXPOSE 5232).
- plan.md line 138: passlib import name comes from libpass, and bcrypt hashes are accepted by autodetect. Not verified.
