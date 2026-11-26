# PyPI: hass-configurator

**Source URL(s) + fetch date**
- https://pypi.org/pypi/hass-configurator/json
- Fetched 2026-11-26

**Version info**
- `info.version`: 0.7.0 (sdist `hass_configurator-0.7.0.tar.gz`, 213020 bytes, uploaded 2026-10-18 21:46:13)
- `info.license`: MIT
- `info.requires_python`: `>=3`
- `info.requires_dist`: null (no dependencies listed in this metadata)
- `info.summary`: "HASS Configurator"
- Earlier releases: 0.6.0 (2026-04-07), 0.5.2 (2022-11-08), 0.5.1 (2022-09-08), 0.5.0 (2022-08-19), and 0.4.x and 0.3.x series.
- Vulnerabilities list: empty.

**Install**
`pip install hass-configurator==0.7.0`.

**Contradictions with plan.md**
- plan.md section 1 says version 0.7.0 was uploaded 2026-10-18 (previous 0.6.0). Confirmed; the 0.6.0 date (2026-04-07) is consistent with "previous".
- plan.md section 1 says the license is MIT and `requires_python` is not stated. Confirmed `>=3` (plan.md did not state a specific value).
- plan.md section 1 says the dependencies are `pyotp`, `gitpython`, `legacy-cgi`, read from setup.py. The PyPI metadata here shows `requires_dist: null`. This conflicts with plan.md and is not resolved here (setup.py not fetched). Unverified; not edited.
- plan.md section 1 says the sdist digest is `1a73aa09...`. Not checked in this run (the JSON digest field was not requested). Unverified.
