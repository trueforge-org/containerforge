# kms — implementation plan
> Source: ./draft.md · Target: apps/kms/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.0.1` (GitHub release, published 2026-05-01T09:40:44Z). Tag commit `b0e1615dec06293c927625006a99e6ec54a001aa`, which is the draft's pinned commit. Source: `gh api repos/Py-KMS-Organization/py-kms/releases/latest`; `gh api repos/Py-KMS-Organization/py-kms/git/ref/tags/v1.0.1`. |
| Renovate | `datasource=github-releases depName=Py-KMS-Organization/py-kms versioning=loose` (tags use a `v` prefix). |
| License | Unlicense (GitHub repo license field). Source: https://api.github.com/repos/Py-KMS-Organization/py-kms |
| Source URL | https://github.com/Py-KMS-Organization/py-kms |
| Download | No release assets. Source archive: `https://github.com/Py-KMS-Organization/py-kms/archive/b0e1615dec06293c927625006a99e6ec54a001aa.tar.gz` (pinned by commit SHA). |
| Checksum source | None published upstream. Pin the commit SHA in the URL, and record the archive `sha256sum` in the Dockerfile at build time (`ARG SHA256`) so the download can be verified. |
| Upstream Dockerfile reviewed | https://github.com/Py-KMS-Organization/py-kms/blob/b0e1615dec06293c927625006a99e6ec54a001aa/docker/docker-py3-kms-minimal/Dockerfile: `FROM alpine:3.22` (musl); apk installs python3, pip, shadow, tzdata; `pip3 install --break-system-packages -r requirements.txt`; copies `./py-kms` to `/home/py-kms`; `docker/start.py`, `docker/entrypoint.py`, `docker/healthcheck.py` to `/usr/bin`; read-only permissions on `/home/py-kms`; `EXPOSE ${PORT}/tcp`; `HEALTHCHECK` runs `healthcheck.py`; `ENTRYPOINT ["/usr/bin/python3", "-u", "/usr/bin/entrypoint.py"]`. |
| Requirements (minimal flavour) | `docker/docker-py3-kms-minimal/requirements.txt` at v1.0.1: `dnspython==2.6.1`, `tzlocal==4.2`. Source: `gh api repos/Py-KMS-Organization/py-kms/contents/docker/docker-py3-kms-minimal/requirements.txt?ref=v1.0.1`. The root `requirements.txt` (web UI build, with Flask and gunicorn) is NOT the minimal one; do not use it. |
| pip package | The draft's "pip install py-kms" is not a PyPI install path. The code is installed from the source archive. |
| Real env vars (upstream Dockerfile and start.py) | `IP` (`::`), `PORT` (`1688`), `EPID` (""), `LCID` (`1033`), `CLIENT_COUNT` (`26`), `ACTIVATION_INTERVAL` (`120`), `RENEWAL_INTERVAL` (`10080`), `HWID` (`RANDOM`), `LOGLEVEL` (`INFO`), `LOGFILE` (`STDOUT`), `LOGSIZE` (""), `WEBUI` (`0`). Source: the minimal Dockerfile and https://github.com/Py-KMS-Organization/py-kms/blob/v1.0.1/docker/start.py. |
| Env not read by start.py | `DUALSTACK` is set in the upstream Dockerfile but is not in start.py's mapping at v1.0.1 (UNVERIFIED whether pykms_Server.py reads it). Leave it out of settings.yaml unless the code reads it. |
| Ports | `1688/tcp` (default; `PORT` changes it). |
| Write paths | Upstream DB only when `WEBUI=1`: `/home/py-kms/db/pykms_database.db`. With `WEBUI=0` (default) the server writes no files. |
| copy-from | **no**. The upstream image is `alpine:3.22` (musl), which does not run on glibc Ubuntu. |
| arm64 | Yes: pure Python, no compiled code. UNVERIFIED (no arm64 run performed). |
| Dependencies | None. |

## 2. Target layout

Files in `apps/kms/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required; runs start.py's logic with the venv Python and the `/app` paths)
- `include/.dockerignore` allows `start.sh`; the py-kms source is downloaded during the build, so nothing else is copied from the context.

Not needed: `defaults/`, `etc/`, `health/`, `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`
- Why: Python-based app; the base provides `/app/venv` (read-only at runtime, per the python-runtime rule).
- Closest sibling: `apps/bazarr` (python app with requirements install).

## 4. Dockerfile

Steps:

1. `ARG VERSION=1.0.1`, `ARG COMMIT=b0e1615dec06293c927625006a99e6ec54a001aa`, `ARG SHA256=<archive sha256, recorded at build time>`.
2. `USER root` for the download, unpack and install only.
3. Download the source archive by commit SHA with `curl -fsSL`, check the sha256, extract to `/app/py-kms` (strip the top-level folder).
4. Install the minimal requirements into `/app/venv` at build time only, with the pip cache in `/tmp`:
   ```dockerfile
   RUN PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir -r /app/py-kms/docker/docker-py3-kms-minimal/requirements.txt
   ```
   Runtime never writes `/app/venv`.
5. Copy the upstream helper scripts (`docker/start.py`, `docker/entrypoint.py`, `docker/healthcheck.py`) into `/app/py-kms/docker/` or a dedicated path under `/app`. Do not use `/usr/bin` for scripts; the venv is the interpreter.
6. `COPY --chmod=0755 start.sh /start.sh`.
7. `EXPOSE 1688`, `USER apps`, and the final `COPY --chmod=0755 . /`.
8. Licence: copy the Unlicense text into `/usr/share/licenses/kms/` (the repo's `LICENSE` file; UNVERIFIED path inside the archive, check at build).

Key snippet:

```dockerfile
ARG VERSION=1.0.1
ARG COMMIT=b0e1615dec06293c927625006a99e6ec54a001aa
ARG SHA256
USER root
RUN curl -fsSL -o /tmp/py-kms.tar.gz "https://github.com/Py-KMS-Organization/py-kms/archive/${COMMIT}.tar.gz" \
 && echo "${SHA256}  /tmp/py-kms.tar.gz" | sha256sum -c - \
 && mkdir -p /app/py-kms \
 && tar -xzf /tmp/py-kms.tar.gz --strip-components=1 -C /app/py-kms \
 && rm /tmp/py-kms.tar.gz
RUN PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir \
      -r /app/py-kms/docker/docker-py3-kms-minimal/requirements.txt
COPY --chmod=0755 start.sh /start.sh
EXPOSE 1688
USER apps
COPY --chmod=0755 . /
```

`VERSION` in the bake file must equal `1.0.1` (the tag); the commit is pinned separately.

## 5. docker-bake.hcl

- `variable "APP" { default = "kms" }`
- `variable "VERSION"` with renovate comment:
  ```hcl
  variable "VERSION" {
    // renovate: datasource=github-releases depName=Py-KMS-Organization/py-kms versioning=loose
    default = "1.0.1"
  }
  ```
- `variable "LICENSE" { default = "Unlicense" }`
- `variable "SOURCE" { default = "https://github.com/Py-KMS-Organization/py-kms" }`
- The `COMMIT` and `SHA256` build args are set in the `image` target: `args = { VERSION = "${VERSION}", COMMIT = "...", SHA256 = "..." }`. Renovate cannot bump the commit with the tag alone, so note this in the PR.
- The 4 standard targets and `group "default" { targets = ["image-local"] }`, as in `apps/steamcmd/docker-bake.hcl`.
- `docker buildx bake --print` from `apps/kms/` must succeed.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/Py-KMS-Organization/py-kms"`
- `ports`:
  - `port: 1688`, `protocol: tcp`, `required: true`
- `env` (only vars start.py or the app reads; defaults match start.py):
  - `IP` default `"::"`, `required: false`
  - `PORT` default `"1688"`, `required: false`
  - `EPID` default `""`, `required: false`
  - `LCID` default `"1033"`, `required: false`
  - `CLIENT_COUNT` default `"26"`, `required: false`
  - `ACTIVATION_INTERVAL` default `"120"`, `required: false`
  - `RENEWAL_INTERVAL` default `"10080"`, `required: false`
  - `HWID` default `"RANDOM"`, `required: false`
  - `LOGLEVEL` default `"INFO"`, `required: false`
  - `LOGFILE` default `"STDOUT"`, `required: false`
  - `LOGSIZE` default `""`, `required: false`
  - `TZ` default `"Etc/UTC"`, `required: false` (matches siblings)
  - `WEBUI` default `"0"` is NOT added: it selects a DB path and a web UI that is out of scope for this container (the minimal flavour).
- `volumes`: none needed for `WEBUI=0`. If `WEBUI=1` is ever supported, add `/config` (out of scope for v1 of this plan).
- `dependencies`: none.

## 7. start.sh

Requirements:

- Idempotent and stateless: nothing to seed in `/config` for `WEBUI=0`.
- Never write to `/app`.
- Read env vars listed in section 6; argument mapping follows `start.py` (`-l LCID`, `-c CLIENT_COUNT`, `-a ACTIVATION_INTERVAL`, `-r RENEWAL_INTERVAL`, `-w HWID`, `-V LOGLEVEL`, `-F LOGFILE`, `-S LOGSIZE`, `-e EPID`).
- Call the venv Python, not `/usr/bin/python3`.
- Listen on all interfaces (`IP` default `::` covers both IPv4 and IPv6 on Linux; UNVERIFIED whether `pykms_Server.py` binds dual-stack with `::`; confirm with `ss -ltn` in the run step).
- `exec` the server so signals reach PID 1.

Outline:

```sh
#!/usr/bin/env bash
set -euo pipefail
args=(-u /app/py-kms/pykms_Server.py "${IP:-::}" "${PORT:-1688}")
map() { [ -n "${!2:-}" ] && args+=("$1" "${!2}"); return 0; }
map -l LCID; map -c CLIENT_COUNT; map -a ACTIVATION_INTERVAL; map -r RENEWAL_INTERVAL
map -w HWID; map -V LOGLEVEL; map -F LOGFILE; map -S LOGSIZE; map -e EPID
exec /app/venv/bin/python "${args[@]}"
```

Check before implementing: start.py and entrypoint.py hard-code `/usr/bin/python3` and `/home/py-kms` (UNVERIFIED for entrypoint.py). If so, the path mapping must change to `/app/venv/bin/python` and `/app/py-kms`. Read both files at v1.0.1 before writing start.sh.

## 8. container-test.yaml

- Schema header copied from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/app/py-kms/pykms_Server.py`.
- A `tcp` probe on `1688` (required for every port in settings.yaml).
- `timeoutSeconds` taken from a Python sibling (`apps/bazarr`).
- The test runs with no env vars, so the default path is covered. KMS activation requests are not part of the test (no client available); do not add a fake client assertion.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | ContainerForge |
| --- | --- |
| `/home/py-kms` (root-owned, read-only) | `/app/py-kms` (read-only at runtime, owned by root) |
| `/usr/bin/entrypoint.py`, `start.py`, `healthcheck.py` (run by `/usr/bin/python3`) | `/app/py-kms/docker/*.py` run by `/app/venv/bin/python` |
| `USER py-kms` (created by `adduser`) | `USER apps` |
| `pip3 install --break-system-packages` (system Python) | venv install at build time under `/app/venv` (python-runtime rule) |
| `WEBUI` DB under `/home/py-kms/db` | not used (`WEBUI=0`); no `/config` needed |

- `readOnlyRootFilesystem`: compatible. Nothing writes at runtime with `WEBUI=0`, plus `/tmp` (tmpfs) for scratch.
- `privileged`: no. Port 1688 is unprivileged.
- Caches: pip cache lives in `/tmp` at build time only.
- Draft's security expectations confirmed: non-root possible (upstream already runs as py-kms user), read-only possible.

## 10. Risks, caveats and open questions

- **Licensed-use caveat:** py-kms emulates KMS activation. Use only for licensed products and follow local licensing (draft caveat, agreed).
- **Port 1688:** KMS clients look for 1688 (SRV records). Mapping to another host port needs explicit client config.
- **Upstream entrypoint paths:** start.py and entrypoint.py hard-code `/usr/bin/python3` and `/home/py-kms` (verify, section 7).
- **Requirements file:** use the minimal one (`dnspython==2.6.1`, `tzlocal==4.2`). The root file pulls Flask and gunicorn for the web UI, which this container does not use.
- **Renovate and commit pin:** the tag bumps VERSION, but the COMMIT and SHA256 build args need a manual update. Document it in the PR.
- **Checksum:** no upstream checksum; the sha256 is recorded from the first build and verified on each build.
- **arm64:** not run; pure Python, so UNVERIFIED but expected to work.

## 11. Build and test steps

From `apps/kms/`, following the build-test protocol:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run and log check, no env vars, read-only, empty tmpfs:
   ```sh
   docker run --rm -d --name kms-probe --read-only --tmpfs /tmp -p 1688:1688 kms:1.0.1
   docker logs -f kms-probe
   docker rm -f kms-probe
   ```
   Expected readiness: the py-kms server log line that reports it is listening on the port (exact text UNVERIFIED, read the log).
4. `forgetool containers test --image kms:1.0.1 --config ./apps/kms/container-test.yaml`
5. Optional manual check: `ss -ltn` inside the container shows 1688.
6. arm64 only if amd64 fails in an arm64-specific way.

## 12. PR checklist

- Branch: `feat/add-kms`
- Commit and PR title: `feat(kms): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign it.
- Say what was not tested (arm64, client activation, the WEBUI=1 path).
- `DOWNSTREAM_CHANGES.md`: not needed.
