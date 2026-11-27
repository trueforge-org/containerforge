# PyPI archivebox 0.9.77 metadata

Source URL(s) + date: https://pypi.org/pypi/archivebox/json (fetched 2026-11-27)

## Metadata
- Version 0.9.77, license MIT, requires_python `>=3.13`.
- Summary: Self-hosted internet archiving solution.
- Files: `archivebox-0.9.77-py3-none-any.whl`, `archivebox-0.9.77.tar.gz`. Wheel is pure Python (no arch-specific).

## Key runtime deps (requires_dist, abridged)
- Web/server: django>=6.1.2, daphne>=4.2.1, twisted>=26.10.0rc1, uvicorn[standard]>=0.54.0, django-ninja>=1.5.1, psycopg[binary]>=3.2.
- CLI/config: click>=8.3.1, rich>=14.2.0, rich-click>=1.9.5, toml, supervisor>=4.2.5, psutil, platformdirs, pydantic>=2.8.0, pydantic-settings>=2.5.2.
- Extractors/plugins: abxbus==2.5.79, abxpkg==1.13.73, abx-plugins[opencode]==1.13.578, abx-dl==1.13.277.
- Other: sonic-client>=1.0.0, requests, markdown, dateparser, croniter, w3lib, browser-cookie3, bleach, uuid7 (python<3.14).
- Extras: `ldap` (python-ldap, django-auth-ldap), `debug`, `sonic`, `all`.

## Gotchas
- Python >=3.13 required; Dockerfile uses PYTHON_VERSION=3.13.
- The `...` wheel URL in urls.txt is a template, so it was not fetched.
