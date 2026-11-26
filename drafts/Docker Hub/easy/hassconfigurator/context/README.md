# Context index: hassconfigurator

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hassconfigurator (values.yaml, Chart.yaml via raw.githubusercontent.com) | truecharts-hassconfigurator.md |
| https://github.com/danielperna84/hass-configurator (README, configurator.py, releases) | github-danielperna84-hass-configurator.md |
| https://github.com/danielperna84/hass-configurator/wiki/Configuration (followed sub-page) | github-danielperna84-hass-configurator.md (section "Env vars" and the options table) |
| https://github.com/causticlab/hass-configurator-docker/blob/7ed3f9f60f4733bf16672a599c041621361d8b0a/Dockerfile (raw) | github-causticlab-hass-configurator-docker.md |
| https://raw.githubusercontent.com/causticlab/hass-configurator-docker/7ed3f9f60f4733bf16672a599c041621361d8b0a/run.sh | github-causticlab-hass-configurator-docker.md |
| https://hub.docker.com/r/causticlab/hass-configurator-docker | dockerhub-causticlab-hass-configurator-docker.md |
| https://pypi.org/pypi/hass-configurator/json (draft: "pip:hass-configurator") | pypi-hass-configurator.md |

Shared index (`docs/context/INDEX.md`): no matches for these URLs, so everything was fetched.

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (plan.md section 12) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge `apps/<base>` link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge `apps/<base>` link |
| https://files.pythonhosted.org/packages/source/h/hass-configurator/hass_configurator-0.7.0.tar.gz (plan.md section 4 and 1) | direct archive download. Asset pattern `hass_configurator-<version>.tar.gz` recorded in pypi-hass-configurator.md |
| https://files.pythonhosted.org/packages/5d/fb/71c9a9f61efaf11709242b62fade79c407175ca5904e6fe7a90d80dff257/hass_configurator-0.7.0.tar.gz (from PyPI JSON) | direct archive download. Recorded in pypi-hass-configurator.md |
| https://github.com/danielperna84/hass-configurator/tarball/0.7.0 (PyPI project_urls) | direct archive download. Recorded in github-danielperna84-hass-configurator.md |
| ghcr.io/trueforge-org/python:3.15.2@sha256:... and ghcr.io/trueforge-org/python:3.14.8@sha256:... (plan.md section 3) | ghcr image refs, not web pages |
| docker.io/causticlab/hass-configurator-docker:x86_64 (draft "Container") | image ref. The Docker Hub web page was fetched instead |
| ghcr.io/trueforge-org/ubuntu (draft "Foundation") | ghcr image ref |

## Fetch failures

None. Wiki sub-pages "Installation", "API" and "Daemonizing" were linked from the README but not followed (not needed for container build facts).

## plan.md corrections

No in-place edits were made. Checked against the sources:

- Confirmed (no change): Dockerfile base `python:3.9-alpine` upstream, `pip install hass-configurator==... gitpython pyotp`, `EXPOSE 3218`, `VOLUME /config`, `run.sh` behaviour; version `0.7.0`; MIT license; sha256 `1a73aa09eb1ee1ed7acdc4c55dc9147fedadf7a7a3947fd63e6ed832b082e44c`; port 3218; `HC_*` env overrides settings file; `HC_LOGLEVEL` default `info`; `HC_ENFORCE_BASEPATH` upstream default False; prefs file name and location; `/config` and `/hass-config` mounts.
- unverified: plan.md section 4 curl URL uses `https://files.pythonhosted.org/packages/source/h/hass-configurator/hass_configurator-${VERSION}.tar.gz`. PyPI JSON returns the hashed canonical URL `https://files.pythonhosted.org/packages/5d/fb/71c9a9f61efaf11709242b62fade79c407175ca5904e6fe7a90d80dff257/hass_configurator-0.7.0.tar.gz` (pypi-hass-configurator.md). Whether the legacy path still resolves was not tested.
- unverified: plan.md section 1 says setup.py requires `pyotp`, `gitpython`, `legacy-cgi`. PyPI JSON lists no `requires_dist` for 0.7.0 (pypi-hass-configurator.md). Not confirmed from these sources.
- unverified: plan.md section 1 calls the draft's image "2021-era". No date was visible in the fetched Dockerfile or Docker Hub page (the Hub page says "8 months ago").

## Notes

- The chart pins `docker.io/causticlab/hass-configurator-docker:x86_64@sha256:45a5a0527ca10da5744bbcf3a7909a0b77ae583e97fe0d28d0e5a8d50aa37689` and runs as root (truecharts-hassconfigurator.md). The chart's security expectations in draft.md match.
- The upstream repository's releases page shows only auto-generated source archives (no uploaded binaries) for 0.7.0.
