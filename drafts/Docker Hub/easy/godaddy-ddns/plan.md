# godaddy-ddns — implementation plan
> Source: ./draft.md · Target: apps/godaddy-ddns/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No release is usable as is. The repo has tags `releases/1.0.0` to `releases/1.0.4`, but the tag `releases/1.0.4` script lacks `int()` around `GET_IP_WAIT_SEC` and `UPDATE_INTERVAL_SEC` (diff against `master` verified), so a value set through env or the config file stays a string and `time.sleep()` fails. `master` HEAD is commit `ab3b048d7a369d816990ad624f58baf8a4c5b480` (2021-12-04), the commit the draft links, and fixes this. The plan pins that commit as `VERSION=ab3b048`. |
| Renovate | `datasource=git-refs depName=https://github.com/jwater7/docker-godaddy-publicip-updater versioning=loose` (same style as the `external-ip` plan). The upstream has been idle since 2021-12, so bumps are unlikely. |
| License | UNVERIFIED and probably none. `LICENSE` returns 404 and the repo page lists no license. The image also carries `pif` 0.8.2 (PyPI says "GPL 2.0/LGPL 2.1") and `godaddypy` (BSD classifier). See section 10, this is a blocker for a maintainer decision. |
| Source | https://github.com/jwater7/docker-godaddy-publicip-updater |
| Artifact | One file, `godaddy-publicip-updater.py`. URL: `https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/godaddy-publicip-updater.py`, sha256 `225cd4d453817b631242d356efe36dfa3930cb6af98f5c8e1db551a3d1e5402f` (computed on 2026-11-23 from that URL). The script is architecture independent. |
| pip packages | `godaddypy` 2.2.6 (the version upstream pins, wheel `py2.py3-none-any`; PyPI latest is 2.5.1 from 2023-11-12, requires `requests>=2.4`), `pif` 0.8.2 (2016-12-22, `py2.py3-none-any`, no declared dependencies), `requests` (imported by godaddypy; upstream installs it separately). All pure Python, so amd64 and arm64 are the same. |
| Checksum source | None published by upstream. The commit SHA in the URL plus the sha256 above (computed by us) are the integrity anchors. PyPI publishes sha256 per file, but the plan installs from the index normally (pure wheels). |
| Upstream Dockerfile | Reviewed (commit `ab3b048`): `FROM python`, `pip install requests`, `pip install pif`, `pip install -I godaddypy==2.2.6`, `COPY godaddy-publicip-updater.py /`, `CMD ["python","-u","/godaddy-publicip-updater.py"]`. No EXPOSE, no VOLUME, runs as root. |
| Env vars (read in the script) | `GODADDY_API_KEY`, `GODADDY_API_SECRET`, `GODADDY_DOMAINS` (comma separated) are required. Optional: `GODADDY_A_NAMES` (default `@`, comma separated), `UPDATE_INTERVAL_SEC` (default 900), `GET_IP_WAIT_SEC` (default 10), `UPDATER_CONFIG_FILE` (path to a flat JSON object keyed by the same names; env overrides the file; no default). |
| Behaviour | `get_config_value()` raises `KeyError` when a required value is in neither env nor the config file, so the script crashes on startup without credentials. It only makes outbound HTTPS calls (public IP lookup through `pif`, GoDaddy API). No listener. |
| Writes | None. Only logs to stdout. |
| Ports | None. |
| Docker Hub image | `jwater7/godaddy-publicip-updater`, amd64 only, last pushed 2020-04-28 (older than the master fix). |

## 2. Target layout

```
apps/godaddy-ddns/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: there is no config file to seed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

A pure Python script with pip dependencies, so the python base (with `/app/venv`) fits, as the draft says. Closest sibling: `apps/apprise-api` (pip into `/app/venv`, no compile needed here) and `apps/bazarr` (python base). Fallback if `pif`/`godaddypy` misbehave on 3.15 (UNVERIFIED, both are 2016 to 2023 pure Python; neither uses `cgi`/`imp`, but not tested on 3.15): `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232`, which other apps already use.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `ARG GODADDYPY_VERSION=2.2.6`, `ARG PIF_VERSION=0.8.2`, each pip ARG preceded by `# renovate: datasource=pypi depName=<name>` (pattern from `apps/changedetection`'s `PLAYWRIGHT_VERSION`).
2. `USER root`. No apt packages: the python base already has `curl`, `ca-certificates` and the venv. Do not add `apt-get install`.
3. One `RUN`:
   - `mkdir -p /app/bin /usr/share/licenses/godaddy-ddns`
   - `curl -fsSL -o /app/bin/godaddy-publicip-updater.py "https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/${VERSION}/godaddy-publicip-updater.py"` (the short SHA `ab3b048` also resolves, verified)
   - `echo "225cd4d453817b631242d356efe36dfa3930cb6af98f5c8e1db551a3d1e5402f  /app/bin/godaddy-publicip-updater.py" | sha256sum -c -` (use an `ARG SCRIPT_SHA256` so a bump of `VERSION` forces a hash update; the build fails on mismatch)
   - `/app/venv/bin/pip install --no-cache-dir requests "godaddypy==${GODADDYPY_VERSION}" "pif==${PIF_VERSION}"`
   - The upstream repo has no license file, so write a `NOTICE`-style text file to `/usr/share/licenses/godaddy-ddns/README` naming the source URL, commit and the licenses of `pif` and `godaddypy` (copy `LICENSE`/`METADATA` from `/app/venv/lib/python3.*/site-packages/*.dist-info/` into that directory instead of hand-written text where present).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /root/.cache /tmp/*`.
4. `ENV HOME=/tmp PYTHONUNBUFFERED=1` (the base already sets `PYTHONDONTWRITEBYTECODE=1`, `PIP_NO_CACHE_DIR=1`). Nothing may write to `/app` at runtime.
5. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `VOLUME /config`. No `EXPOSE` (no listener).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "godaddy-ddns" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/jwater7/docker-godaddy-publicip-updater versioning=loose
  default = "ab3b048"
}
variable "LICENSE" { default = "NOASSERTION" }   // see section 10: upstream has no license
variable "SOURCE"  { default = "https://github.com/jwater7/docker-godaddy-publicip-updater" }
```

Then the standard blocks copied from `apps/adguardhome-sync/docker-bake.hcl`: `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `target "image"` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). The pip ARG defaults live in the Dockerfile (changedetection precedent). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jwater7/docker-godaddy-publicip-updater"
ports: []
env:
  - name: GODADDY_API_KEY        # default "", required: true (start.sh idles with a clear error if missing)
  - name: GODADDY_API_SECRET     # default "", required: true
  - name: GODADDY_DOMAINS        # default "", required: true, comma separated
  - name: GODADDY_A_NAMES        # default "@", required: false
  - name: UPDATE_INTERVAL_SEC    # default "900", required: false
  - name: GET_IP_WAIT_SEC        # default "10", required: false
  - name: UPDATER_CONFIG_FILE    # default "/config/config.json" (only used when the file exists), required: false
  - name: TZ                     # default "Etc/UTC", required: false
volumes:
  - path: /config
    required: false
dependencies: []
```

Write it in the multi-line `name/default/required` block style of `apps/bazarr/settings.yaml`. The three required credentials have an empty `default`, which the settings rule allows only when `start.sh` handles the missing value (it does, section 7). `/config` is optional because it only holds the optional JSON file. No dependencies (no sibling containers needed).

## 7. start.sh

```bash
#!/usr/bin/env bash

# Optional JSON defaults file, env overrides it (upstream behaviour)
if [ -z "${UPDATER_CONFIG_FILE:-}" ] && [ -f /config/config.json ]; then
  export UPDATER_CONFIG_FILE=/config/config.json
fi

# The script raises KeyError when a required value is in neither env nor the file.
# Check both so the container idles with a clear message instead of a crash loop.
missing=""
for key in GODADDY_API_KEY GODADDY_API_SECRET GODADDY_DOMAINS; do
  if [ -z "${!key:-}" ]; then
    if [ -n "${UPDATER_CONFIG_FILE:-}" ] && [ -f "${UPDATER_CONFIG_FILE}" ] \
       && jq -e --arg k "$key" '.[$k] // empty | select(. != "")' "${UPDATER_CONFIG_FILE}" >/dev/null 2>&1; then
      continue
    fi
    missing="${missing} ${key}"
  fi
done

if [ -n "${missing}" ]; then
  echo "godaddy-ddns: missing required setting(s):${missing}. Set them as environment variables or in ${UPDATER_CONFIG_FILE:-/config/config.json}. Idling, no DNS record is changed." >&2
  exec sleep infinity
fi

exec /app/venv/bin/python -u /app/bin/godaddy-publicip-updater.py
```

Notes:
- `jq` is in the ubuntu base (verified in `apps/ubuntu/Dockerfile`). Secrets stay in the environment or the JSON file, never on the command line or in the process list.
- Idle instead of exit so the container stays up when it is started without settings (the CI test runs with no env vars) and so a restart policy does not loop. This is a deliberate deviation from upstream, flag it in the PR.
- No writes to `/app`; `/config` is only read. `exec` hands PID handling to the base `tini`/entrypoint. No listener, so the bind-address rule does not apply.
- Defaults for `GODADDY_A_NAMES`, `UPDATE_INTERVAL_SEC` and `GET_IP_WAIT_SEC` are applied by the script itself (`@`, 900, 10) and match `settings.yaml`; do not re-export them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/bin/godaddy-publicip-updater.py
- /app/venv/bin/python
```

No `tcp`/`http` probe because `settings.yaml` lists no ports. The test runs without env vars, so only the idle path executes; the credential path (script start, GoDaddy calls) can only be checked by hand in section 11. The paths-only style follows `apps/autoscan/container-test.yaml`. `timeoutSeconds` is a guess modelled on siblings (`apps/changedetection` uses 180); a no-port idle container needs less. This is not the DB-dependency exception and needs no narrowing comment.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap |
| --- | --- |
| Runs as root (draft: chart `runAsUser 0`) | Runs as `apps`; the script does no privileged operation, only outbound HTTPS. |
| `readOnlyRootFilesystem: false` in the chart | Not needed. Script, venv and licenses live in `/app` (read only). Python bytecode is off (`PYTHONDONTWRITEBYTECODE=1` in the base), `HOME=/tmp`, pip cache off. |
| Upstream script at `/` | Moved to `/app/bin/`. |
| Config | Optional `/config/config.json`, read only by the script. |
| Privileged / extra persistence | None (`persistence {}` in the chart). Nothing else to mount. |

## 10. Risks, caveats and open questions

- BLOCKER for the maintainer: the upstream repo has no license. Redistributing its script in a published image needs a decision (ask upstream to add a license, or reimplement the 100-line loop, or accept `NOASSERTION`). `LICENSE` in `docker-bake.hcl` must be the license of the software in the image, so it cannot honestly say MIT/BSD.
- `pif` is GPL 2.0/LGPL 2.1 per PyPI metadata (UNVERIFIED which of the two applies, the package is unmaintained since 2016). It also calls third party "what is my IP" services (`pif` default sources, UNVERIFIED which) and the script sets `urllib3.disable_warnings` for unverified HTTPS, which suggests some lookups skip TLS verification. Needs review before shipping.
- The GoDaddy production DNS API has reportedly been restricted to accounts with enough domains or a qualifying plan (UNVERIFIED, not checked against GoDaddy documentation). Users may get 403 even with correct keys. Mention in the PR.
- Draft caveats: needs a GoDaddy API key and secret (handled: idle with message). The chart's `:latest` tag is a Docker Hub image last pushed 2020-04-28, older than the master fix; this plan pins the commit instead.
- `godaddypy` pinned to 2.2.6 to match upstream's tested set; 2.5.1 exists (API compatibility UNVERIFIED). Renovate would propose it; test before merging.
- Python 3.15 compatibility of `pif`/`godaddypy` is UNVERIFIED (fallback in section 3).
- The short SHA as `VERSION` gives a non-semver tag; the script has no real version number.
- arm64: no blocker, everything is pure Python (the upstream Docker Hub image is amd64 only, which does not matter here).
- Draft says non-root is "possible"; confirmed, nothing needs root.

## 11. Build and test steps

```sh
cd apps/godaddy-ddns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name godaddy-ddns-probe --read-only --tmpfs /tmp \
  -v godaddy-ddns-probe-config:/config godaddy-ddns:ab3b048
docker logs godaddy-ddns-probe     # expect the "missing required setting(s)" line and the container still running
docker rm -f godaddy-ddns-probe; docker volume rm godaddy-ddns-probe-config
# credential path, by hand, with fake values (expect GoDaddy 401/403 in the logs, no Python traceback about KeyError/ValueError):
docker run --rm --read-only --tmpfs /tmp -e GODADDY_API_KEY=x -e GODADDY_API_SECRET=y -e GODADDY_DOMAINS=example.invalid godaddy-ddns:ab3b048
forgetool containers test --image godaddy-ddns:ab3b048 --config ./apps/godaddy-ddns/container-test.yaml
```

Readiness signal: with no env, the container stays running and logs the "missing required setting(s)" message. With env, the log shows `logging` lines such as `Got exception getting public IP` or `Updated <name> for <domain> to <ip>` (INFO format `%(asctime)s : %(levelname)s : %(name)s - %(message)s`). Also run once with a `/config/config.json` mount to prove the file path works.

## 12. PR checklist

- [ ] Branch `feat/add-godaddy-ddns` from `main`; commit and PR title `feat(godaddy-ddns): add new container`.
- [ ] Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- [ ] Put `🤖 This PR is AI generated.` in the Notes section.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows the status).
- [ ] `docker buildx bake --print` exits 0.
- [ ] Honest untested list in the PR: the real GoDaddy API call was not tested (no credentials), arm64 not built, Python 3.15 vs `pif`/`godaddypy` unproven until the build runs, license question open, `forgetool` run only if available locally.
- [ ] Do not check "Built container locally" unless the build in section 11 really ran.
