# shortipy context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/maschhoff/shortipy (Dockerfile, app.ini, requirements.txt, README, jdb.py, LICENSE.md at 52afd09; releases page) | github-maschhoff-shortipy.md |
| https://github.com/maschhoff/shortipy/releases | github-maschhoff-shortipy.md |
| https://hub.docker.com/r/knex666/shortipy | dockerhub-knex666-shortipy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shortipy (values.yaml) | truecharts-shortipy.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and .../apps/python: containerforge base app links (skip rule).
- https://github.com/maschhoff/shortipy/ (trailing slash): same repo, covered.
- https://github.com/maschhoff/shortipy/blob/HEAD/requirements.txt: covered by the raw requirements.txt at 52afd09 (HEAD moving ref not fetched).
- https://github.com/maschhoff/shortipy/blob/52afd09/Dockerfile: covered by the raw Dockerfile at 52afd09.
- https://github.com/maschhoff/shortipy/archive/${VERSION}.tar.gz: source archive download (skip rule); pinned SHA noted in the repo summary.
- ghcr.io/trueforge-org/ubuntu and ghcr.io/trueforge-org/python (named in plan.md): image refs, not web pages (skip rule).

## Fetch failures

- None. Releases page loaded: no releases. Tags tab not readable (recorded as unknown).

## plan.md corrections

None made. Checked against the context:
- Port 4321 (plan), uWSGI options (app.ini), `./data/db.json` path and seed, GPL-3.0 license, and the upstream Dockerfile base (python:3.11.0-slim-buster, build-essential, requirements) all match.
- The plan's Flask and uWSGI pins (flask 3.1.3, uWSGI 2.0.31) and the HEAD commit date were not checked against the sources fetched here.

## Unverified (not changed in plan.md)

- Plan section 1 "the knex666 image is built from this repo": Dockerfile comment supports it; Docker Hub README entrypoint `/start.sh` and mount `/shortipy/data` do not match the Dockerfile at 52afd09. Left as is.
- Plan section 1 "Writes server.log only in __main__ mode" and "Env vars: app reads none": shorti.py not fetched.
- Plan section 10 "randint(1111,9999)" short codes: shorti.py not fetched.
- Plan section 1 "Latest commit on master 52afd09 (2025-05-25)" and "49 commits": not checked here.
- Plan section 1 "`redirect()` accepts any stored URL": shorti.py not fetched.
