# kitana: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/pannal/Kitana (+ raw README, kitana.py, requirements.txt, LICENSE, Dockerfile at master and at 287a8b7, releases/tag/0.4.3-2) | github-pannal-kitana.md |
| https://github.com/pannal/Kitana/blob/287a8b7.../Dockerfile | github-pannal-kitana.md (raw Dockerfile, identical to master) |
| https://github.com/pannal/Kitana/blob/master/Dockerfile | github-pannal-kitana.md (raw Dockerfile) |
| https://github.com/pannal/Kitana/blob/HEAD/requirements.txt | github-pannal-kitana.md (same file) |
| https://hub.docker.com/r/pannal/kitana | dockerhub-pannal-kitana.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kitana (Chart.yaml and values.yaml via raw) | truecharts-kitana.md |
| https://pypi.org/project/libsass/ (named pin `libsass==0.21.0`, plan section 1) | pypi-libsass.md |
| https://pypi.org/project/CherryPy/ (named pin `cherrypy==18.8.0`, plan section 1) | pypi-cherrypy.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge base link, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema, skipped by rule |
| https://github.com/pannal/Kitana/releases/download/${VERSION}/Kitana.zip | templated release download |
| https://github.com/pannal/Kitana/releases/download/0.4.3-2/Kitana.zip (x2) | direct release download. Name and source-zip layout recorded in github-pannal-kitana.md |
| http://<ip | placeholder address, not a source |
| http://0.0.0.0:31337 | bind address, not a source (matches the 0.0.0.0 skip rule) |

Named but not fetched: Sub-Zero Plex plugin (`com.plexapp.agents.subzero`, default plugin id, runtime dependency not build input), Plex.TV and Plex Media Server, `requirements_win32.txt` (README mention), `ndg-httpsclient`, `jinja2`, `PyGithub`, `furl`, `cryptography` (other pins; not fetched to keep scope). The `distutils` removal is general Python knowledge, not sourced here.

## Fetch failures

- https://github.com/pannal/Kitana/releases/tag/0.4.3-2: page loaded (date, commit, Latest label), but the asset list did not load ("3 assets", names not shown). Asset names and the `Kitana.zip` checksum could not be confirmed here. No retry (not 403/404).

## plan.md corrections

No edits made. No fact in plan.md is clearly wrong against the fetched sources. The items below are confirmed, unverified, or open.

Confirmed (no change needed): port 31337 and default bind `0.0.0.0:31337`; `/app/data/sessions` session path; `distutils` import in `kitana.py`; requirements.txt pins; Dockerfile `python:3.8-alpine`, `EXPOSE 31337`, `VOLUME /app/data`, no USER; `-A` accepts an env var name; MIT license; release `0.4.3-2` is Latest.

Unverified (not edited):
- plan.md section 1 (Download row): asset name `Kitana.zip` and older `Kitana-0.4.3-1.zip`, and the zip layout with top-level `Kitana/`. Release asset list did not load; not checked.
- plan.md section 1 (Checksum row): local sha256 `9cfb3968...` of `Kitana.zip`. Cannot be checked from fetched sources.
- plan.md section 1 (Python requirements row): claim that only `cherrypy`, `requests`, `xmltodict`, `sass`, `jinja2`, `furl`, `github` are imported. `kitana.py` was fetched and shows `distutils` and sessions; other modules not fetched.
- plan.md section 1 (Runtime writes row): `plugins/SassCompilerPlugin.py` walking `os.getcwd()`. Plugin file not fetched.
- plan.md section 1 (Data path row): "creates `<baseDir>/data/sessions` and nothing else". Sessions confirmed; "nothing else" not fully checked.
- plan.md section 1 (Python 3.15 findings): `pip download libsass==0.21.0` failure and unpinned installs. Local pip result, cannot be checked here. PyPI shows libsass 0.23.0 has no Linux aarch64 wheel (see pypi-libsass.md), which is relevant to plan's arm64 note.
- plan.md section 10: update_check behaviour (PyGithub, every 6 hours, try/except). Not fetched.
- plan.md section 1 (Renovate row): `versioning=loose` for `0.4.3-2`. Not checked.
- plan.md section 1 (Version row): repo last pushed 2023-07-25. Not checked on the repo page.

Note (not a plan error, for the maintainer): the upstream Kitana `-pt`/`--plextv-timeout` argparse default is 25 while its help text and the `Kitana` class default say 15. Plan does not use this flag.
