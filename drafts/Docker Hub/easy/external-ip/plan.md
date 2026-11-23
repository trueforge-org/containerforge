# external-ip — implementation plan
> Source: ./draft.md · Target: apps/external-ip/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Upstream has no GitHub releases. Only tag `v0.0.1` (commit `b249ecf`, old, predates IPIFY support). The draft's chart image is `xavierh/external-ip:latest`, built from the `main` HEAD commit `3be417fe91ba6ab1be2eeb1c2ee218d01470a185` (2026-09-05, "Add Support to Use IPIFY"). Plan pins that commit. |
| Renovate | `datasource=git-refs depName=https://github.com/xavier-hernandez/docker-external-ip versioning=loose` (same style as `apps/imaginary`, which also pins a git ref). Whether to use the short or full SHA as `VERSION` is an open question (section 10). |
| License | MIT (`LICENSE`, "Copyright (c) 2022 Xavier"; GitHub SPDX `MIT`) |
| Source | https://github.com/xavier-hernandez/docker-external-ip |
| Artifact | Shell scripts only: `scripts/start.sh`, `scripts/lib/ipv4.sh`, `scripts/lib/notify.sh`. Archive URL `https://github.com/xavier-hernandez/docker-external-ip/archive/<commit>.tar.gz` (arch independent). Apprise from PyPI (2.3.0 now, BSD-2-Clause, requires python>=3.9). |
| Checksum | Upstream publishes none. The full commit SHA in the URL is the integrity anchor. UNVERIFIED that a GitHub archive for a commit is byte-stable, so no tarball hash is pinned. |
| Upstream Dockerfile | Reviewed (at the commit the draft links): `alpine:3.16.0`, `apk add bash curl bind-tools py3-pip`, `pip install apprise`, `WORKDIR /opt/ext`, `ADD /scripts scripts`, `CMD ["bash","/opt/ext/scripts/start.sh"]`. No EXPOSE, no VOLUME. |
| Env vars (from `start.sh`, `notify.sh`) | `DELAY` (default `5m`; must match `^[0-9]+[dsmh]?$`), `PROVIDER` (`CLOUDFLARE` default, `GOOGLE`, `OPENDNS`, `IPIFY`), `NOTIFICATION_TYPE` (`PUSHOVER` or `APPRISE`), `PUSHOVER_TOKEN`, `PUSHOVER_USER`, `PUSHOVER_TITLE` (default "EXTERNAL IP"), `APPRISE_TITLE` (default "EXTERNAL IP"), `APPRISE_1` to `APPRISE_10` (URLs, read as `${NOTIFICATION_TYPE}_${i}`), `RECOVERY_ALERT` (`True`), `SAVE_IP` (`True`). `TZ` is not read by the script but affects `date`. The chart sets `DELAY=5m` and empty others. |
| Tools used | `bash`, `dig` (cloudflare/google/opendns), `curl` (ipify, pushover), `apprise` CLI |
| Writes | Saved IP file `/stor-external-ip/ip.saved` (only if `SAVE_IP=True`). Nothing else. |
| Ports | None. |
| Known upstream defects (read in the code) | `SAVE_IP` is tested case-insensitively when loading (`${SAVE_IP^^}`) but case-sensitively (`"True"`) when saving; `ipify_ipv4` uses `curl -k` (no TLS verification); `$old_ip` is compared as `0` initially. |
| Ubuntu 26.04 (resolute) package | `bind9-dnsutils` (provides `dig`) exists on packages.ubuntu.com. |

## 2. Target layout

```
apps/external-ip/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: the upstream scripts are fetched in the Dockerfile and installed under `/app/scripts`, and our own `start.sh` replaces upstream's `scripts/start.sh` to fix paths. Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

The draft prefers the python base for `apprise`; the alternative is plain ubuntu with a venv. Apprise 2.3.0 is pure Python on top of requests, PyYAML, click, markdown and certifi; PyYAML has no cp315 wheel (UNVERIFIED) but falls back to a pure-Python build. If the pip install fails on 3.15, use `python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` as eight other apps do. Closest sibling: `apps/apprise-api` (apprise into `/app/venv`); shell style from `apps/adguardhome-sync`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends bind9-dnsutils && rm -rf /var/lib/apt/lists/*` (`bash` and `curl` are in the ubuntu base). The package is not the app, so no version pin.
3. Pip into the base venv, cache kept out: `/app/venv/bin/pip install --no-cache-dir "apprise==${APPRISE_VERSION}"` with a build arg added next to `VERSION`:
   - `# renovate: datasource=pypi depName=apprise` above `ARG APPRISE_VERSION=2.3.0` (same pattern as `apps/changedetection`'s `PLAYWRIGHT_VERSION`).
   - Add `/app/venv/bin` to `PATH` so `apprise` resolves: `ENV PATH=/app/venv/bin:$PATH` (the base sets `PATH=/usr/local/bin:$PATH`; check it does not already include the venv).
4. Fetch upstream scripts at the pinned commit:
   - `mkdir -p /app/scripts /usr/share/licenses/external-ip`
   - `curl -fsSL "https://github.com/xavier-hernandez/docker-external-ip/archive/${VERSION}.tar.gz" | tar xz -C /tmp`
   - `cp -r /tmp/docker-external-ip-*/scripts/lib /app/scripts/lib` and `cp /tmp/docker-external-ip-*/LICENSE /usr/share/licenses/external-ip/LICENSE`. Do not copy upstream's `scripts/start.sh` (our own `start.sh` is the entrypoint).
   - Optionally remove `-k` from `ipify_ipv4` with `sed -i 's/curl -s -k /curl -s /' /app/scripts/lib/ipv4.sh` (open question 10).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
5. `USER apps`; `COPY --chmod=0755 . /`; `VOLUME /config`. No `EXPOSE` (no port).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "external-ip" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/xavier-hernandez/docker-external-ip versioning=loose
  default = "3be417fe91ba6ab1be2eeb1c2ee218d01470a185"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/xavier-hernandez/docker-external-ip" }
```

Because the image tag would be a 40 character SHA, consider `3be417f` (the archive URL accepts short SHAs too) so the tag is readable; keep the Dockerfile `ARG VERSION` identical. Standard `docker-metadata-action`, `group "default"`, `image` (args `VERSION`), `image-local`, `image-all` blocks copied from `apps/imaginary/docker-bake.hcl` or `apps/adguardhome-sync/docker-bake.hcl`. APPRISE_VERSION lives in the Dockerfile as an ARG default (like the PLAYWRIGHT precedent), so only `VERSION` is passed from bake. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/xavier-hernandez/docker-external-ip"
ports: []
env:
  - { name: DELAY, default: "5m", required: false }
  - { name: PROVIDER, default: "CLOUDFLARE", required: false }
  - { name: NOTIFICATION_TYPE, default: "", required: false }
  - { name: RECOVERY_ALERT, default: "False", required: false }
  - { name: SAVE_IP, default: "False", required: false }
  - { name: PUSHOVER_TOKEN, default: "", required: false }
  - { name: PUSHOVER_USER, default: "", required: false }
  - { name: PUSHOVER_TITLE, default: "EXTERNAL IP", required: false }
  - { name: APPRISE_TITLE, default: "EXTERNAL IP", required: false }
  - { name: APPRISE_1, default: "", required: false }   # up to APPRISE_10, list each in block style as siblings do
  - { name: TZ, default: "Etc/UTC", required: false }
volumes:
  - path: /config
    required: true     # only used when SAVE_IP=True; keep required: false if the schema/siblings prefer
dependencies: []
```

Write the entries in the multi-line block style of `apps/bazarr/settings.yaml` and expand `APPRISE_2` to `APPRISE_10`. All names are verified against `start.sh`/`notify.sh`. Defaults match `start.sh`. Mark `/config` `required: false` (state is only needed with `SAVE_IP`), which differs from sibling convention; decide when writing. No ports.

## 7. start.sh

Own script, same behavior as upstream's loop with the saved-IP path moved and the case bug fixed. It sources the fetched libs.

```bash
#!/usr/bin/env bash
set -uo pipefail

source /app/scripts/lib/ipv4.sh
source /app/scripts/lib/notify.sh

old_ip=0; recovery=0
sleep_for="5m"
recoveryAlert="[RECOVERY]"; changeAlert="[CHANGE]"
savedIPFile="/config/ip.saved"
regex='^([0-9]+[dsmh]?)$'

if [[ "${DELAY:-}" =~ ${regex} ]]; then sleep_for="${DELAY}"; else echo "Bad parameter for DELAY, using default ${sleep_for}..."; fi

save_ip=false; [[ "${SAVE_IP:-}" =~ ^[Tt][Rr][Uu][Ee]$ ]] && save_ip=true
if $save_ip && [ -f "$savedIPFile" ]; then old_ip=$(tr -d ' \t\n\r' < "$savedIPFile"); fi

while :; do
  case "${PROVIDER:-CLOUDFLARE}" in
    GOOGLE) ip=$(google_ipv4) ;;  OPENDNS) ip=$(opendns_ipv4) ;;  IPIFY) ip=$(ipify_ipv4) ;;  *) ip=$(cloudflare_ipv4) ;;
  esac
  if valid_ipv4 "${ip}"; then
    if [[ "${old_ip}" != "${ip}" || ${recovery} == 1 ]]; then
      old_ip="${ip}"
      if [[ ${recovery} == 1 ]]; then
        echo -e "IP: ${ip} ${recoveryAlert}"
        [[ "${RECOVERY_ALERT:-}" =~ ^[Tt][Rr][Uu][Ee]$ ]] && notify "IP: ${ip} ${recoveryAlert}"
      else
        echo -e "IP: ${ip} ${changeAlert}"
        notify "IP: ${ip} ${changeAlert}"
      fi
    else
      echo -e "IP: ${ip}"
    fi
    if $save_ip; then printf '%s\n' "${ip}" > "${savedIPFile}"; fi
    recovery=0
  else
    echo -e "\n[Error or Invalid IP address]"; recovery=1
  fi
  sleep "${sleep_for}" & wait $!
done
```

The change/recovery block mirrors upstream's `start.sh` at the pinned commit (diff against it when writing; recovery alert only when `RECOVERY_ALERT` is true, now case-insensitive). Add `trap 'exit 0' TERM INT` before the loop. Rules: idempotent; state only in `/config/ip.saved` and only when `SAVE_IP` is true (empty `/config` is fine, nothing seeded); no writes to `/app`; secrets (`PUSHOVER_TOKEN`, `APPRISE_*` URLs) are used only via `curl -F`/`apprise` arguments as upstream does, and never logged (note `curl -F token=...` shows the token in the process list; acceptable only because upstream does it, flag in the PR or switch to `curl --form-string` read from env, open question); the loop is the main process so `exec` is not applicable. To get signals through (`sleep` blocks TERM), run `sleep "${sleep_for}" & wait $!` and add `trap 'exit 0' TERM INT` (tini from the base handles PID 1). No `exec` possible because it is a loop; state this in a comment. No network listener, so bind-address rule is not applicable.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/scripts/lib/ipv4.sh
- /app/scripts/lib/notify.sh
- /app/venv/bin/apprise
- /usr/share/licenses/external-ip/LICENSE
runners:
- entrypoint: test -x /usr/bin/dig
```

The service has no port, so there is no tcp/http probe and none is required by `settings.yaml`. The container run without env just loops against Cloudflare (needs outbound internet); the test must not depend on that, so assertions are file/binary based. The runner line follows the `entrypoint: test -f ...` form in `apps/python/container-test.yaml`. DB exception: not applicable.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/stor-external-ip/ip.saved` (upstream volume, `SAVE_IP`) | `/config/ip.saved`, path fixed in our `start.sh` |
| `/opt/ext/scripts` (read) | `/app/scripts` (read only) |
| pip cache | `--no-cache-dir`; nothing at runtime |
| `apprise` config/cache (`~/.config/apprise`, `~/.local`) | HOME is `/config`; apprise only writes there if persistent storage is configured (UNVERIFIED, check `apprise -vv` under `--read-only` and set `APPRISE_STORAGE_MODE`/`HOME=/tmp` if it fails) |

Draft expectations: UID 0, writable rootfs, no persistence. Here UID 568, read-only rootfs OK, not privileged. The chart has no persistence, so the optional `/config` is a new but harmless addition.

## 10. Risks, caveats and open questions

- No upstream releases: renovate git-refs will propose new commits; the image version equals a commit SHA. Maintainer should confirm that naming (short vs full SHA).
- `curl -k` in the ipify provider disables TLS verification; consider removing it (diverges from upstream).
- Needs outbound internet and public IP services (draft caveat); `dig` to port 53 may be blocked by cluster egress rules.
- `apprise` needs a target URL (account at the notification service); no secrets are baked in.
- Draft says "pip into /app and a /config state file": implemented as the base venv plus `/config/ip.saved`.
- Upstream's `PUSHOVER_TOKEN` appears in the process list via `curl -F`.
- Pure shell app, so no architecture issue; Apprise wheels and `bind9-dnsutils` exist for arm64 (UNVERIFIED for arm64 builds).

## 11. Build and test steps

```sh
cd apps/external-ip
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name external-ip-probe --read-only --tmpfs /tmp -e DELAY=30s -e SAVE_IP=True -v external-ip-probe-config:/config external-ip:3be417f
docker logs -f external-ip-probe     # expect "Starting..." then "IP: <your public IPv4> [CHANGE]"
docker exec external-ip-probe cat /config/ip.saved
docker exec external-ip-probe apprise --version
forgetool containers test --image external-ip:3be417f --config ./apps/external-ip/container-test.yaml
docker rm -f external-ip-probe; docker volume rm external-ip-probe-config
```

Repeat with `-e PROVIDER=IPIFY`, `GOOGLE`, `OPENDNS`, and with an unreachable network (expect `[Error or Invalid IP address]` repeating, container staying up). Test a notification with `NOTIFICATION_TYPE=APPRISE` and a harmless URL such as `json://localhost` (UNVERIFIED scheme support, pick from the Apprise docs). The success signal is the `IP:` line. The test run itself needs no env.

## 12. PR checklist

- Branch `feat/add-external-ip`; commit `feat(external-ip): add new container`; target `main`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested until run: real Pushover and Apprise delivery, all four providers, arm64, read-only run of `apprise`, behavior behind restricted egress.
- Pre-completion: `bake --print` passes, VERSION aligned in Dockerfile and bake, empty `/config` starts, no `DOWNSTREAM_CHANGES.md`.
