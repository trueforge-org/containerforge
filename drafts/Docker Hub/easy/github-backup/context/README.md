# Context index: github-backup

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/lnxd/github-backup | github-lnxd-github-backup.md (repo; Dockerfile and README fetched from master) |
| https://raw.githubusercontent.com/lnxd/github-backup/master/Dockerfile | github-lnxd-github-backup.md |
| https://raw.githubusercontent.com/lnxd/github-backup/master/README.md | github-lnxd-github-backup.md |
| https://hub.docker.com/r/lnxd/github-backup | dockerhub-lnxd-github-backup.md |
| https://pypi.org/project/github-backup/ | pypi-github-backup.md (page was a client-challenge; JSON API used) |
| https://pypi.org/pypi/github-backup/json | pypi-github-backup.md |
| https://github.com/josegonzalez/python-github-backup (via raw README) | github-josegonzalez-python-github-backup.md |
| https://raw.githubusercontent.com/josegonzalez/python-github-backup/master/README.rst | github-josegonzalez-python-github-backup.md |
| https://raw.githubusercontent.com/josegonzalez/python-github-backup/master/LICENSE.txt | github-josegonzalez-python-github-backup.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/github-backup | truecharts-github-backup.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/github-backup/values.yaml | truecharts-github-backup.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| https://raw.githubusercontent.com/josegonzalez/python-github-backup/${VERSION}/LICENSE.txt | template URL in plan.md; the master LICENSE.txt was fetched instead |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| `pip:github-backup` | package reference; covered by the PyPI JSON fetch |

## Fetch failures

- https://raw.githubusercontent.com/josegonzalez/python-github-backup/main/README.rst: HTTP 404. Retried on `master`, succeeded.
- https://pypi.org/project/github-backup/: returned a client-challenge page with no data. Used `https://pypi.org/pypi/github-backup/json` instead, which returned data but was truncated (upload time of 0.68.0 not visible).
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/github-backup: one DNS lookup error (transient). Retried, succeeded.
- https://github.com/lnxd/github-backup: repo page not fetched directly; Dockerfile and README fetched from raw master.

## plan.md corrections

One edit made, in the "Draft expectations" paragraph of section 9:
- old: "Chart's two PVCs (`backups`, `config`) collapse to `/config`"
- new: "Chart's two persistence entries (`backuplocation` at `/home/docker/backups`, `config` at `/home/docker/github-backup/config/`) collapse to `/config`"
- source: `context/truecharts-github-backup.md` (chart persistence keys and mount paths from values.yaml).

Unverified (not edited):
- plan.md section 1: lnxd `backup.sh` reads env `TOKEN` and `SCHEDULE` (seconds) and uses `config.json`. backup.sh not fetched; the chart's `SCHEDULE: 3600` and `TOKEN` env are consistent.
- plan.md section 1: lnxd repo archived 2022-09-06 and MIT. Not verified.
- plan.md section 1 and 4: 0.68.0 released 2026-11-09 and tag `0.68.0` has `LICENSE.txt`. Upload time not visible; tag not checked.
- plan.md section 3: Python 3.15 not in the package classifiers. Classifiers not fetched.
