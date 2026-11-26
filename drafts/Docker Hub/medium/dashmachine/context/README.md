# context README: dashmachine

| Source URL | File |
| --- | --- |
| https://github.com/rmountjoy92/DashMachine | upstream-github.md (repo root, covered) |
| https://github.com/rmountjoy92/DashMachine/blob/be50c2e763ae4e18f95855c18ba31c42199a4b3e/Dockerfile | upstream-github.md (same as raw) |
| https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/Dockerfile | upstream-github.md |
| https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/README.md | upstream-github.md |
| https://api.github.com/repos/rmountjoy92/DashMachine/releases/latest | upstream-github.md (release section) |
| https://hub.docker.com/r/rmountjoy/dashmachine | not fetched (JS-rendered); tag API used |
| https://hub.docker.com/v2/repositories/rmountjoy/dashmachine/tags/latest | upstream-github.md (Docker Hub section) |

Requirements.txt (follow-up, install doc) recorded in upstream-github.md.
Skipped: TrueCharts tree page (chart reference, not build source). Licence file not fetched (LICENSE 404 at pinned commit per plan; not a follow-up page type).
Failures: none.

## plan.md corrections
None edited. Checked against fetched sources:
- Dockerfile at be50c2e7: python:3.8-slim, inetutils-ping, EXPOSE 5000, VOLUME user_data, CMD gunicorn wsgi:app, ENV PRODUCTION=true: consistent.
- Release v0.5-4.2 (2020-05-30, no assets) and Docker Hub latest (2020-09-22): consistent.
- Plan line 65 open question: requirements.txt lists `gunicorn` (unpinned). The second `pip install gunicorn` line in the plan is redundant but harmless. Left for the author.
