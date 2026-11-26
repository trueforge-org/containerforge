# Context index: glances

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/nicolargo/glances | github-nicolargo-glances.md |
| https://raw.githubusercontent.com/nicolargo/glances/e907519c4a446da33b6968dba8f1c3b84a3379df/docker-files/ubuntu.Dockerfile | github-nicolargo-glances.md |
| https://raw.githubusercontent.com/nicolargo/glances/v4.5.9/COPYING | github-nicolargo-glances.md |
| https://hub.docker.com/r/nicolargo/glances | dockerhub-nicolargo-glances.md |
| https://pypi.org/pypi/glances/json (plan.md's PyPI source) | pypi-glances.md |
| https://glances.readthedocs.io/en/develop/ | docs-glances-readthedocs-io.md (index page only) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/glances | truecharts-glances.md (directory listing failed to load; see below) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/glances/values.yaml | truecharts-glances.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| https://github.com/nicolargo/glances/archive/... | none used; plan uses PyPI |
| https://github.com/nicolargo/glances/blob/e907519c.../docker-files/ubuntu.Dockerfile (blob form) | same file as the raw Dockerfile URL, fetched once |
| https://github.com/nicolargo/glances/blob/... (sub-pages) | not followed |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| `pip:glances` | package reference; covered by the PyPI JSON fetch |
| https://hub.docker.com/r/nicolargo/glances (tags page variants) | covered by the Hub page |

## Fetch failures

- https://raw.githubusercontent.com/nicolargo/glances/v4.5.9/README.md: HTTP 404. Retried on `develop` (`.../develop/README.md`): also 404. Upstream README not summarised.
- https://glances.readthedocs.io/en/develop/: index only. Sub-pages (install, quickstart, config, docker, cmds) were not fetched.
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/glances: directory listing not loaded in this run (values.yaml fetched separately).
- https://pypi.org/pypi/glances/json: response truncated at 100000 characters; only the info block was read.

## plan.md corrections

Edits made to `/workspaces/containers/drafts/Docker Hub/easy/glances/plan.md`:

1. Section 1, "Upstream Dockerfile reviewed" row:
   - old: `full` adds `libzmq5 libvirt-clients`; base apt packages `python3 curl lm-sensors smartmontools net-tools tzdata`; runs as root, `# USER glances` commented out with the note that the Docker plugin would not work non-root
   - new: `full` adds `libzmq5`; base apt packages `python3 curl lm-sensors wireless-tools smartmontools net-tools tzdata`; no USER instruction, so it runs as root; no commented-out USER line and no Docker plugin comment in the fetched file
   - source: `context/github-nicolargo-glances.md` (fetched `docker-files/ubuntu.Dockerfile` at the pinned commit)

2. Section 10, Docker plugin bullet:
   - old: The upstream Dockerfile comments say the same ("If used, the Glances Docker plugin do not work").
   - new: The fetched upstream Dockerfile contains no such comment (see context/README.md corrections).
   - source: same Dockerfile

Unverified (not edited):
- plan.md section 1: health route `/api/4/status`, `glances_restful_api.py` at v4.5.9. Upstream README and source not fetched.
- plan.md section 1: `psutil` 7.2.2 wheels for Python 3.15. Not checked.
- plan.md section 1: `-w` default and `GLANCES_OPT` usage in docs. Confirmed by the Docker Hub page only; docs sub-pages not fetched.
- plan.md section 1: `COPYING` and LGPL-3.0-only. Confirmed (COPYING is LGPL v3; PyPI license_expression LGPL-3.0-only).
- plan.md section 7: `/config/glances.conf` and `XDG_CACHE_HOME` log path. Not verified.
