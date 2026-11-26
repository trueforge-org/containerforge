# xavier-hernandez/docker-external-ip

Source URL(s) + fetch date:
- https://github.com/xavier-hernandez/docker-external-ip (repo root)
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/master/README.md
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/Dockerfile (pinned commit from the draft)
- https://github.com/xavier-hernandez/docker-external-ip/releases
- Fetched 2026-11-26

## What it is
Shell-script loop that polls the public IP address and sends a notification (Pushover or Apprise) when it changes. Image is built from this repo.

## Install/build steps and build deps
Dockerfile at commit 3be417fe91ba6ab1be2eeb1c2ee218d01470a185 (summary, the fetch did not return the verbatim text):
1. Base `alpine:3.16.0`.
2. `apk add` of `bash`, `curl`, `bind-tools` (provides `dig`), `py3-pip`, with no apk cache left behind.
3. `pip install apprise` (not version-pinned; no `--no-cache-dir` in that step per the fetch summary).
4. `WORKDIR /opt/ext`.
5. `ADD /scripts scripts` (plain local copy).
6. `CMD ["bash","/opt/ext/scripts/start.sh"]` (exec form). No ENTRYPOINT.
- No EXPOSE, no VOLUME, no USER (runs as root upstream).

## Runtime deps
- `bash`, `dig` (cloudflare, google, opendns providers), `curl` (ipify and pushover), `sleep`.
- Apprise CLI for `NOTIFICATION_TYPE=APPRISE`.
- Outbound internet access.

## Binaries/entrypoint/CLI flags
- No CLI flags. All config is through environment variables.
- Entry: `bash /opt/ext/scripts/start.sh` (upstream). Loop: fetch IP, log it, tag `[CHANGE]` or `[RECOVERY]`, log `[Error or Invalid IP address]` on failure, sleep `DELAY`.

## Env vars
| Variable | Default | Meaning |
| --- | --- | --- |
| `TZ` | unset | timezone for log timestamps |
| `DELAY` | 5m | sleep interval; seconds, or suffix m/h/d |
| `PROVIDER` | CLOUDFLARE | CLOUDFLARE, GOOGLE, OPENDNS, IPIFY |
| `NOTIFICATION_TYPE` | none | PUSHOVER or APPRISE |
| `PUSHOVER_TOKEN` | - | required when NOTIFICATION_TYPE=PUSHOVER |
| `PUSHOVER_USER` | - | required when NOTIFICATION_TYPE=PUSHOVER |
| `PUSHOVER_TITLE` | "EXTERNAL IP" | message title |
| `APPRISE_TITLE` | "EXTERNAL IP" | message title |
| `APPRISE_1`..`APPRISE_10` | - | Apprise URLs; `APPRISE_1` required with Apprise |
| `RECOVERY_ALERT` | False | send an alert once the IP is retrieved again after a failure (True/False) |
| `SAVE_IP` | unset | persist the IP to the volume (e.g. True) |

## Ports
None documented or exposed.

## Volumes/paths and persistent data
- `/stor-external-ip` is the container path for the saved IP (`SAVE_IP`). Optional, required only if `SAVE_IP` is used.

## User/UID and permissions
Not specified upstream; upstream Dockerfile has no USER (root).

## Config files
None. Environment variables only.

## Healthcheck/readiness
None documented.

## Version/release info and asset naming
- The releases page reports "There aren't any releases here." No releases, no tags listed on the page, no assets.
- Docker Hub image `xavierh/external-ip` is tagged `latest` ("stable") only, per the Docker Hub page.

## Arch support
linux/amd64, linux/arm/v7, linux/arm64/v8 (per Docker Hub page for the prebuilt image).

## Gotchas
- Upstream IPIFY path uses `curl -s -k` (no TLS verification). Matches plan.md section 1 defect list.
- Compose example in the upstream README uses the key `volume:`; the correct compose key is `volumes:`.
- Upstream README example `RECOVERY_ALERT=True/False` is a placeholder; pick one value.
- Pushover and Apprise are alternatives; `NOTIFICATION_TYPE` takes a single value.
- Upstream README sample log shows `dig: couldn't get address ... not found` during DNS failure, which triggers error and recovery flow.
- The Dockerfile fetched as alpine 3.16.0 with root; plan.md section 3 and 4 replace this with the ContainerForge python base, a venv install of apprise and a separate fetch of scripts. This is an intentional divergence, not a contradiction of the upstream source, but note the upstream Dockerfile does not match the plan on base or user.
- Plan.md section 1 says the upstream has tag `v0.0.1` only; the releases page fetched here shows no tags. The README/release tab did not confirm the tag list, so this is unverified from this fetch.
