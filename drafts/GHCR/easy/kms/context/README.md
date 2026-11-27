# kms context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kms/values.yaml + Chart.yaml | truecharts-kms.md |
| Docker Hub | none (image is GHCR: ghcr.io/py-kms-organization/py-kms) |
| https://github.com/Py-KMS-Organization/py-kms/blob/b0e1615.../docker/docker-py3-kms-minimal/Dockerfile (raw variant fetched) | py-kms-upstream-dockerfile-startpy.md |
| https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/v1.0.1/docker/start.py (blob URL listed) | py-kms-upstream-dockerfile-startpy.md |
| https://github.com/Py-KMS-Organization/py-kms/blob/HEAD/requirements.txt (raw HEAD fetched: the root file only contains the path docker/docker-py3-kms/requirements.txt; minimal requirements fetched from raw HEAD) | py-kms-upstream-dockerfile-startpy.md |
| https://api.github.com/repos/Py-KMS-Organization/py-kms/releases/tags/v1.0.1 (listed as releases/tag HTML) | py-kms-upstream-dockerfile-startpy.md |
| https://api.github.com/repos/Py-KMS-Organization/py-kms/license | py-kms-upstream-dockerfile-startpy.md |

Skipped categories: api.github.com/repos/Py-KMS-Organization/py-kms (repo metadata), github.com repo/blob HTML duplicates, py-kms.readthedocs.io (docs; budget, not fetched), github.com archive tarball (binary download, not fetched).

Failures: none.

## plan.md corrections

- Edited 1 line (plan.md, section 1 "Real env vars" table, row "Env not read by start.py"): the row said DUALSTACK is not read by start.py. It is read directly by start.py at v1.0.1 (`os.environ.get('DUALSTACK')`), only used when IP lists more than one address. Old: "`DUALSTACK` is set in the upstream Dockerfile but is not in start.py's mapping at v1.0.1 (UNVERIFIED whether pykms_Server.py reads it). Leave it out of settings.yaml unless the code reads it." New: "Read conditionally by start.py (direct os.environ read, not the argument mapping); only used with multiple IP addresses; default `IP=::` makes it a no-op; pykms_Server.py read UNVERIFIED." Source: https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/v1.0.1/docker/start.py.
- Verified, no edit: requirements at v1.0.1 (dnspython==2.6.1, tzlocal==4.2), FROM alpine:3.22, EXPOSE/port 1688, license Unlicense, release v1.0.1 published 2026-05-01.
