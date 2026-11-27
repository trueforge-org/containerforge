# Upstream py-kms minimal Dockerfile, start.py, requirements, release (v1.0.1)

## Source URL(s) + date

- https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/b0e1615dec06293c927625006a99e6ec54a001aa/docker/docker-py3-kms-minimal/Dockerfile (raw of pinned blob)
- https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/v1.0.1/docker/start.py
- https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/HEAD/docker/docker-py3-kms-minimal/requirements.txt (HEAD copy; v1.0.1 copy identical)
- https://raw.githubusercontent.com/Py-KMS-Organization/py-kms/v1.0.1/docker/docker-py3-kms-minimal/requirements.txt
- https://api.github.com/repos/Py-KMS-Organization/py-kms/releases/tags/v1.0.1 (published 2026-05-01T09:40:44Z; name v1.0.1)
- https://api.github.com/repos/Py-KMS-Organization/py-kms/license (spdx Unlicense)
- Fetched 2026-11-27

## What it is

- Python KMS (Windows activation) server, minimal image variant without SQLite.
- Upstream Dockerfile comment: "minimized version from docker/docker-py3-kms/Dockerfile without SQLite support".

## Build (Dockerfile, minimal)

- `FROM alpine:3.22`.
- `apk add --no-cache --update bash python3 py3-pip ca-certificates shadow tzdata`.
- `pip3 install --break-system-packages --no-cache-dir -r /home/py-kms/requirements.txt`.
- `adduser -S py-kms -G users -s /bin/bash`; `chown py-kms:users /home/py-kms`; symlink `/etc/localtime` -> UTC.
- `COPY ./py-kms /home/py-kms`; COPY `docker/entrypoint.py` -> `/usr/bin/entrypoint.py`, `docker/healthcheck.py` -> `/usr/bin/healthcheck.py`, `docker/start.py` -> `/usr/bin/start.py`; chmod 555 on those three.
- Hardening: all files 444, dirs 555, owned by root, `/home/py-kms` owned by py-kms.
- `WORKDIR /home/py-kms`; `EXPOSE ${PORT}/tcp`.
- `HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD /usr/bin/python3 /usr/bin/healthcheck.py`.
- `ENTRYPOINT ["/usr/bin/python3", "-u", "/usr/bin/entrypoint.py"]`.
- Requirements at v1.0.1: `dnspython==2.6.1`, `tzlocal==4.2`.

## Env vars (image ENV)

| Var | Default |
| --- | --- |
| IP | `::` |
| DUALSTACK | `1` |
| PORT | `1688` |
| EPID | `""` |
| LCID | `1033` |
| CLIENT_COUNT | `26` |
| ACTIVATION_INTERVAL | `120` |
| RENEWAL_INTERVAL | `10080` |
| HWID | `RANDOM` |
| LOGLEVEL | `INFO` |
| LOGFILE | `STDOUT` |
| LOGSIZE | `""` |
| WEBUI | `0` |

## start.py (v1.0.1) behaviour

- Argument mapping (env -> flag, passed only if non-empty): LCID `-l`, CLIENT_COUNT `-c`, ACTIVATION_INTERVAL `-a`, RENEWAL_INTERVAL `-r`, HWID `-w`, LOGLEVEL `-V`, LOGFILE `-F`, LOGSIZE `-S`, EPID `-e`.
- Runs `/usr/bin/python3 -u pykms_Server.py <IP[0]> <PORT>` plus mapped flags.
- `WEBUI=1`: adds `-s /home/py-kms/db/pykms_database.db`, creates db dir, starts `gunicorn pykms_WebUI:app` on port 8080 with env PYKMS_SQLITE_DB_PATH, PYKMS_LICENSE_PATH=/LICENSE, PYKMS_VERSION_PATH=/VERSION.
- If `IP` has more than one address: appends `connect -n <addr>,<PORT>` per extra address and `-d <DUALSTACK>` if DUALSTACK is set (read directly via os.environ).
- LOGLEVEL `MININFO` is mapped to INFO for the bootstrap logger.

## Ports

- 1688/tcp (`PORT`). Web UI port 8080 only with WEBUI=1.

## Volumes / paths

- DB only with WEBUI=1: `/home/py-kms/db/pykms_database.db`. Otherwise no writes.
- Code: `/home/py-kms`. Scripts: `/usr/bin/*.py`.

## User / UID

- User `py-kms` (uid assigned by `adduser -S`, not pinned), group `users`.

## Healthcheck

- `/usr/bin/python3 /usr/bin/healthcheck.py` every 5 min (see Dockerfile).

## Version / asset naming

- Tag `v1.0.1` (leading `v`). Release asset list not checked; plan.md uses the source archive by commit.
- Release `v1.0.1` published 2026-05-01T09:40:44Z.

## Gotchas

- `pip install --break-system-packages` used in upstream build.
- Upstream start.py reads DUALSTACK directly only when IP lists more than one address.
