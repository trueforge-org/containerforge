# awscli (PyPI)

Source URL(s) + fetch date:
- https://pypi.org/project/awscli/ (fetched 2026-11-26; page is long, first 100000 chars read)

## What it is
AWS CLI v1 published on PyPI as `awscli`. Pure Python.

## Install/build steps
- `pip install awscli==<version>` (no build deps needed for the wheel).
- Files: `awscli-1.46.3.tar.gz` (sdist, 16.8 MB) and `awscli-1.46.3-py3-none-any.whl` (20.2 MB, universal wheel, no ABI tag).

## Runtime deps
From setup.py install_requires (see github-aws-aws-cli.md): docutils>=0.18.1,<=0.19; PyYAML>=3.10,<6.1; colorama>=0.2.5,<0.4.7; rsa>=3.1.2,<4.8; jmespath>=0.7.1,<2.0.0; python-dateutil>=2.1,<3.0.0; urllib3>=1.25.4,!=2.2.0,<3. (botocore/s3transfer are pulled in by the package, not listed on this page as read.)

## Binaries/entrypoint/CLI flags
Console script `aws` (plus `aws_completer`, `aws_bash_completer`, `aws_zsh_completer.sh`).

## Version/release info and asset naming
- Latest: 1.46.3, released Nov 5, 2026 (matches plan.md).
- AWS CLI v1 is in maintenance mode (critical bug and security fixes only); end of support July 15, 2027; AWS recommends migrating to v2.
- Neither file has provenance attestations.

## Arch support
Universal wheel (any platform, Python 3).

## Gotchas
- `requires_python`: `>=3.10`. Classifiers list Python 3.10 to 3.14 (no 3.15 classifier).
- AWS CLI v2 is not published on PyPI (per plan.md; not verified on this page).

## Contradictions with plan.md
- None on version, Python range or license. plan.md's "classifiers list Python up to 3.14" matches.
