# aws/aws-cli (upstream CLI)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/aws/aws-cli/1.46.3/setup.py (fetched 2026-11-26)

## What it is
Official AWS command line interface. Tag `1.46.3` is the v1 line (plan says the default branch is `v2`).

## Install/build steps
Python package built with setuptools; installed with pip. Console entries are provided as `scripts` (`bin/aws`, `bin/aws_completer`, etc.), not console_scripts.

## Runtime deps
See the PyPI summary (`pypi-awscli.md`) for the install_requires list.

## Version/release info
Tag 1.46.3 `__version__` is read from `awscli/__init__.py` at build time. Plan's claim that the tag `1.46.3` carries `__version__` 1.46.3 is consistent with the setup.py reading the version from there (the value itself was not read).

## Python requirement
>=3.10.

## License
Apache License 2.0.

## Gotchas
- Not a container source; the wrapper uses the PyPI package.
