# awscli (PyPI)

Source URL(s) + fetch date:
- https://pypi.org/project/awscli/ (fetched 2026-11-26)

## What it is
AWS CLI v1 published on PyPI (the `awscli` package).

## Version/release info and asset naming
- Latest: 1.46.3, released Nov 5, 2026 (matches plan).
- PyPI source distribution and wheel names follow the standard `awscli-<version>` pattern (not separately verified here).

## Runtime deps (install_requires, from setup.py at tag 1.46.3)
- docutils >=0.18.1,<=0.19
- PyYAML >=3.10,<6.1
- colorama >=0.2.5,<0.4.7
- rsa >=3.1.2,<4.8
- jmespath >=0.7.1,<2.0.0
- python-dateutil >=2.1,<3.0.0
- urllib3 >=1.25.4,!=2.2.0,<3

Optional extra `crt`: awscrt==0.36.0.

botocore is not in the extracted list above; the summariser may have dropped it. Verify against the wheel's METADATA before relying on it. The plan's risk note about botocore/urllib3 pins on newer Python stays open.

## Python requirement and classifiers
- Requires-Python: >=3.10.
- Classifiers list Python 3.10 through 3.14 (no 3.15 classifier). Plan agrees.

## Binaries/entrypoint
Installs script files (not console_scripts): `bin/aws`, `bin/aws.cmd`, `bin/aws_completer`, `bin/aws_zsh_completer.sh`, `bin/aws_bash_completer`. The `aws` binary path in pip installs is the Python venv `bin/aws`.

## License
Apache License 2.0 (Apache Software License). Matches plan.

## Gotchas
- v1 line only; AWS CLI v2 is not on PyPI (plan agrees).
- Upper bounds on several deps (PyYAML <6.1, docutils <=0.19, colorama <0.4.7) can conflict with newer Python builds; the plan lists Python 3.15 as UNVERIFIED.
