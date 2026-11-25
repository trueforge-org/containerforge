# nntp2nntp — implementation plan
> Source: ./draft.md · Target: apps/nntp2nntp/ · Difficulty: easy (on paper) — BLOCKED: Python 2 only · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.3`, the only tag. Tag commit `e21c7352f9d615924f707973991a2cd42a9e9d4a`, release published 2019-04-28. No release assets. Source: https://github.com/linuxserver/nntp2nntp/releases/tag/0.3 and https://api.github.com/repos/linuxserver/nntp2nntp/tags (read with `gh api`). |
| Renovate | `datasource=github-tags depName=linuxserver/nntp2nntp versioning=loose` (tag `0.3` is not three-part semver). |
| License | WTFPL (GitHub SPDX `WTFPL`): https://github.com/linuxserver/nntp2nntp/blob/master/LICENSE |
| Source URL | https://github.com/linuxserver/nntp2nntp |
| Binary source | No binary. Source archive `https://github.com/linuxserver/nntp2nntp/archive/0.3.tar.gz` (pip-installable). Checksum: none published; the tag commit is the pin. |
| Python version | **Python 2 only.** `setup.py` classifiers list Python 2.6 and 2.7 only: https://github.com/linuxserver/nntp2nntp/blob/master/setup.py . `nntp2nntp.py` line 52 is `print sha256(pwd).hexdigest()`, a Python 2 print statement, so Python 3 cannot import it: https://github.com/linuxserver/nntp2nntp/blob/master/nntp2nntp.py |
| Dependencies | `Twisted`, `pyOpenSSL` (`install_requires`), plus `service_identity` in the upstream image. Python 3 compatibility of these: UNVERIFIED. |
| Entry point | UNVERIFIED: the `setup.py` entry point or script name was not read in full. Confirm with `pip show` or `setup.py` during the build. |
| Usage | `nntp2nntp <config_file>`; `nntp2nntp pass` prints a password hash (`nntp2nntp.py` lines 13-19 and 52). |
| Config defaults | https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/master/root/defaults/nntp2nntp.conf : `[proxy] port = 1563`, `use ssl = false`, `cert file`/`cert key` under `/config/keys`, `logfile` and `pidfile` under `/config/logs`; `[server]` host/port/login/password (placeholders `nntp.example.com`, `myuser`); `[users]`, `[connections]`. |
| Ports | **1563/tcp**, not the draft's `1119/tcp`. Source: upstream Dockerfile `EXPOSE 1563` and default `port = 1563`. The `1119` value in the draft is inferred and has no source. |
| Env vars | None read by the program. Configuration is the file only. |
| Write paths | `/config` only: config file, `/config/keys` (certs when SSL is on), `/config/logs` (log and pid). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/master/Dockerfile: `baseimage-alpine:3.15`, `python2` plus `get-pip.py`, `pip install .../archive/${NNTP2NNTP_RELEASE}.tar.gz service_identity`, `EXPOSE 1563`, `VOLUME /config`. Alpine and python2, so not reused (`copy-from: no`). |
| arm64 | Pure Python, so no arch-specific artifact is needed. Blocked by the Python 2 issue, not by arch. |

## 2. Target layout

Planned (not to be built until section 10 is resolved):

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `defaults/nntp2nntp.conf`: needed. The start script seeds `/config/nntp2nntp.conf` from it when missing. Reason: the app needs a config file path argument.
- `etc/`, `scripts/`, `health/`: not needed.
- `root/`: never use. Put the default under `defaults/`.
- `DOWNSTREAM_CHANGES.md`: not needed. No ContainerForge app uses this as a `FROM` base.

## 3. Base image

- `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (from the current base table).
- Why: pure-Python app that needs one pip install. The python base provides `/app/venv`.
- Closest sibling: `apps/bazarr` (python base, venv at `/app/venv`, `start.sh` pattern). Python rules: `/app/venv` is read-only at runtime, so the app runs from `/app/venv` directly with no seeding of venv (strategy row "read-only runtime").
- Note: the python base is Python 3.15, so this app's Python 2 source cannot run on it.

## 4. Dockerfile

Only after section 10 is resolved (a Python 3 port or a maintained fork). The intended steps:

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `VERSION` must equal the bake `VERSION` (`0.3`).
2. `RUN` installs the package into the venv at build time (writes to `/app/venv` during build only, which is allowed):
   ```dockerfile
   RUN set -eux; \
       /app/venv/bin/python -m pip install --no-cache-dir \
         "https://github.com/linuxserver/nntp2nntp/archive/${VERSION}.tar.gz" \
         twisted pyopenssl; \
       chown -R apps:apps /app; chmod -R 755 /app
   ```
   Pin `twisted` and `pyopenssl` to versions that work on Python 3.15 (UNVERIFIED: choose and check during the build). Do not use `apt`: Ubuntu does not package this app.
3. Ship the license: `mkdir -p /usr/share/licenses/nntp2nntp && cp` the `LICENSE` from the source archive (or write it from the upstream file). Source: https://github.com/linuxserver/nntp2nntp/blob/master/LICENSE
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `EXPOSE 1563`, `VOLUME /config`.
6. `PIP_NO_CACHE_DIR` is already set by the python base, so no cache goes into `/config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nntp2nntp"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=linuxserver/nntp2nntp versioning=loose
  default = "0.3"
}

variable "LICENSE" {
  default = "WTFPL"
}

variable "SOURCE" {
  default = "https://github.com/linuxserver/nntp2nntp"
}
```

Then the standard group and the `image`, `image-local`, `image-all` targets from `apps/luanti/docker-bake.hcl`. Validate with `docker buildx bake --print`. Note that `VERSION` `0.3` points at a 2019 source tag, so it will not change unless a Python 3 fork is used (then the bake `SOURCE` and `depName` must change too).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/linuxserver/nntp2nntp"
ports:
  - port: 1563
    protocol: tcp
    required: true
env: []
volumes:
  - path: /config
    required: true
dependencies: []
```

- `env: []`: the app reads no env vars (section 1). Do not invent any.
- `volumes`: `/config` holds the config, certs and logs.
- `dependencies`: none. The upstream NNTP server is external and configured by the user.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG="/config/nntp2nntp.conf"
mkdir -p /config/logs /config/keys
if [[ ! -s "${CONFIG}" ]]; then
    cp /defaults/nntp2nntp.conf "${CONFIG}"
fi

exec /app/venv/bin/nntp2nntp "${CONFIG}"
```

- Seeds the config only when missing or empty (never overwrites user state).
- `exec`s the proxy so signals reach it.
- Default config points the upstream at `nntp.example.com`. The proxy should still bind `1563`; whether it starts with placeholder upstream settings is UNVERIFIED and is a readiness check in section 11.
- The proxy binds on all interfaces by default in its config (no `bind` directive is shown in the default file). UNVERIFIED: check with `ss -ltn` in the build.
- Entry point name `nntp2nntp` is UNVERIFIED (section 1).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '1563'
filePaths:
  - /config/nntp2nntp.conf
  - /defaults/nntp2nntp.conf
```

- `tcp` probe on 1563 covers the only port in `settings.yaml`.
- `filePaths`: the seeded config and the default must exist. Note the test runs without env vars, so the start path with a missing config is the path that runs.
- The required-env path does not apply (no env vars). Upstream `pass` mode is not a runtime path; do not test it here.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`. The draft's chart expectation of `runAsUser 0` is for the linuxserver s6 image and does not apply.
- Writes only to `/config` (config, logs, pid, keys). `--read-only --tmpfs /tmp` works because the app does not write under `/app`.
- Port 1563 is above 1024: no root needed.
- Not privileged. No extra persistence beyond `/config`.
- The draft's `1119` port is removed (section 1).

## 10. Risks, caveats and open questions

- **Blocker: Python 2 only.** `nntp2nntp.py` line 52 is a Python 2 `print` statement and `setup.py` lists only Python 2.6/2.7. On the Python 3.15 base, `pip install` will either fail or leave an unimportable module. Options, none of which are in this repo yet:
  1. Use a Python 3 port by a maintainer (none found in the fetched sources).
  2. Patch in the app folder (a fork). This needs a licence check (WTFPL allows it) and an owner decision.
  3. Keep the app on hold.
  Recommendation: hold the draft until one option is chosen. Do not ship a Python 2 runtime, since the base is Python 3.15 and the policy is a current base.
- Caveat (from draft): the proxy needs an upstream NNTP account and its settings in `/config` before it is useful.
- Ports corrected from `1119` to `1563` (section 1).
- Twisted and pyOpenSSL versions on Python 3.15: UNVERIFIED.
- Single 2019 tag: no upstream release in 7 years. Renovate will find nothing new. Expect manual review.

## 11. Build and test steps

Do not start until section 10 is resolved. Then from `apps/nntp2nntp`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. Expected failure today: pip install of the Python 2 source.
3. Probe: `docker run --rm -d --name nntp2nntp-probe --read-only --tmpfs /tmp -v nntp2nntp-probe-config:/config nntp2nntp:0.3`, then `docker logs -f nntp2nntp-probe`. Readiness: container still running, `ss -ltn` shows 1563, no traceback. Clean up with `docker rm -f nntp2nntp-probe; docker volume rm nntp2nntp-probe-config`.
4. `forgetool containers test --image nntp2nntp:0.3 --config ./container-test.yaml`.
5. Repeat step 3 with an empty `/config` volume (the protocol requires it).

## 12. PR checklist

- Do not open a PR while section 10 is open: the app cannot build.
- When unblocked: branch `feat/add-nntp2nntp`, commit `feat(nntp2nntp): add new container`, PR template, Notes section `🤖 This PR is AI generated.`, CLA notice at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- In the PR, state which blocker option was chosen and what was not tested (arm64 build, real NNTP upstream).
