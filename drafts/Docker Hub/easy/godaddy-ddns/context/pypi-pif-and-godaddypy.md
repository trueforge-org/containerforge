# PyPI: pif and godaddypy

**Source URL(s) + fetch date**
- https://pypi.org/pypi/pif/json
- https://pypi.org/pypi/godaddypy/json
- Fetched 2026-11-26

**pif**
- Summary: "Public IP address checker."
- `info.version`: 0.8.2
- `info.license`: "GPL 2.0/LGPL 2.1" (no `License ::` classifier)
- `requires_python` and `requires_dist`: null (no declared dependencies)

**godaddypy**
- Summary: "A very simple python client used to update the IP address in A records for GoDaddy managed domains."
- `info.version`: 2.5.1 (latest)
- `info.license`: empty
- `requires_python`: empty
- `requires_dist`: `requests >=2.4`
- Release 2.2.6 exists in the releases list (wheel `py2.py3-none-any` and sdist, uploaded April 2018).

**Contradictions with plan.md**
- plan.md section 1 says `pif` is GPL 2.0/LGPL 2.1 per PyPI. Confirmed.
- plan.md section 1 says `pif` 0.8.2 has no declared dependencies. Confirmed.
- plan.md section 1 says godaddypy 2.2.6 is the pinned version and PyPI latest is 2.5.1 with `requests>=2.4`. Confirmed.
- plan.md section 1 says godaddypy has a BSD classifier. The JSON `info.license` is empty; the classifier list was not read. Unverified.
- plan.md section 1 says 2.5.1 is from 2023-11-12. Date not read. Unverified.
