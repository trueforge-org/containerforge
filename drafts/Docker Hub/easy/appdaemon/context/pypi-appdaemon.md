# PyPI: appdaemon

**Source URL(s) + fetch date**
- https://pypi.org/project/appdaemon/ (HTML: failed, client challenge "A required part of this site couldn't load")
- https://pypi.org/pypi/appdaemon/json (JSON API, fetched 2026-11-26; used instead)

**Facts (JSON API)**
- `info.version`: 4.5.16. `info.requires_python`: `<3.15,>=3.10`.
- `info.license`: null (license_expression null; `license_files` lists `LICENSE.md`). Use the file, as plan.md says.
- `info.summary`: "Apps for the Home Assistant home automation package."
- Project URLs: changelog `docs/HISTORY.rst`, documentation `appdaemon.readthedocs.io`, repository `github.com/AppDaemon`.
- Release 4.5.16 uploaded 2026-11-13T14:24:51Z. Only file: `appdaemon-4.5.16-py3-none-any.whl`, size 9727507 bytes, sha256 `ca686e13faca3168bd717831f391a1c651752244d2b7f76b40a855b4bd4583e4`. Not yanked. No sdist listed.

**Gotchas**
- The HTML project page failed; the JSON API is the source for these facts.
- Plan.md's python range `>=3.10,<3.15` and the wheel-only note are confirmed.
- The sha256 above is the wheel's digest per the JSON API (plan.md section 1 says PyPI gives no separate checksum for a plain pip install; the digest is in the JSON API).
