# aws/aws-cli (upstream CLI)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/aws/aws-cli/1.46.3/setup.py (fetched 2026-11-26)

## What it is
Official AWS command line interface. The tag 1.46.3 is the v1 line (plan.md says default branch is v2; not checked here).

## Install/build steps
Python package built with setuptools (`setup.py`), installed with pip. No compiled parts.

## Runtime deps (install_requires, verbatim)
- docutils>=0.18.1,<=0.19
- PyYAML>=3.10,<6.1
- colorama>=0.2.5,<0.4.7
- rsa>=3.1.2,<4.8
- jmespath>=0.7.1,<2.0.0
- python-dateutil>=2.1,<3.0.0
- urllib3>=1.25.4,!=2.2.0,<3

`python_requires=">= 3.10"`.

## Binaries/entrypoint/CLI flags
Scripts: `bin/aws`, `bin/aws.cmd`, `bin/aws_completer`, `bin/aws_zsh_completer.sh`, `bin/aws_bash_completer`. No entry_points.

## Version/release info and asset naming
Version is read from `awscli/__init__.py` (`__version__`) via regex; the number is not on the setup.py page.

## Arch support
Pure Python; platform-independent.

## Gotchas
- Pin ranges above constrain the dependency set; plan.md's concern about botocore/urllib3 pins applies.

## Contradictions with plan.md
- None found in setup.py (python_requires and Python 3.10+ match plan.md).
