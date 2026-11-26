# PyPI: hass-configurator

Source URL(s) + fetch date:
- https://pypi.org/pypi/hass-configurator/json (fetched 2026-11-26)

## What it is
- Python package `hass-configurator`, the upstream editor (see github-danielperna84-hass-configurator.md).

## Install/build steps and build deps
- `pip install hass-configurator==<version>`.
- Only an sdist is listed for 0.7.0 (no wheel), so pip builds from the tarball with setuptools.
- PyPI JSON `requires_dist` is `null` for 0.7.0. The plan.md claim that setup.py requires `pyotp`, `gitpython`, `legacy-cgi` could NOT be confirmed from PyPI metadata (it may come from the sdist's setup.py). Unverified here.

## Runtime deps
- Not listed in PyPI metadata (see above). Optional at runtime: `gitpython` (GIT), `pyotp` (SESAME_TOTP_SECRET).
- `requires_python`: `>=3`.

## Version/release info and asset naming
- Latest version: `0.7.0`, uploaded 2026-10-18T21:46:13Z. License: MIT.
- Only file: sdist. Asset naming: `hass_configurator-<version>.tar.gz`.
- sdist URL (canonical, from PyPI JSON): `https://files.pythonhosted.org/packages/5d/fb/71c9a9f61efaf11709242b62fade79c407175ca5904e6fe7a90d80dff257/hass_configurator-0.7.0.tar.gz`
- sdist sha256: `1a73aa09eb1ee1ed7acdc4c55dc9147fedadf7a7a3947fd63e6ed832b082e44c` (matches plan.md).
- Direct archive download (not fetched, skipped as a binary/archive): the `files.pythonhosted.org` file above. The legacy path that plan.md uses (`packages/source/h/hass-configurator/hass_configurator-<ver>.tar.gz`) is not the canonical URL PyPI returns; it was not tested here.
- Project URLs: Documentation and Homepage `github.com/danielperna84/hass-configurator`; Download `https://github.com/danielperna84/hass-configurator/tarball/0.7.0` (archive, not fetched); Tracker `.../issues`.

## Arch support
- Pure Python sdist; identical on amd64 and arm64.

## Gotchas
- The PyPI release (2026-10-18) contradicts the draft's suggestion that the project is unmaintained: a current release exists.
- plan.md section 4 curl URL (legacy `packages/source/h/...` path) differs from the canonical hashed path above. Listed as unverified in README.md, not edited.
