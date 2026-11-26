# xavier-hernandez/docker-external-ip (GitHub)

**Source URL(s) + fetch date**
- https://github.com/xavier-hernandez/docker-external-ip
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/README.md
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/Dockerfile
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/start.sh
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/lib/ipv4.sh
- https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/lib/notify.sh
- https://github.com/xavier-hernandez/docker-external-ip/releases
- Fetched 2026-11-26

**What it is**
Bash loop that looks up the public IPv4 address on a schedule (dig against Cloudflare, Google or OpenDNS, or curl against ipify) and sends a change or recovery notification through Pushover or Apprise. No compiled code, no listening service.

**Install/build steps and build deps (upstream Dockerfile at the pinned commit)**
- `FROM alpine:3.16.0`
- `RUN apk add --no-cache bash curl bind-tools py3-pip`
- `RUN pip install apprise`
- `WORKDIR /opt/ext`
- `ADD /scripts scripts`
- `CMD ["bash", "/opt/ext/scripts/start.sh"]`
- No USER, ENTRYPOINT, ENV, EXPOSE or VOLUME instruction.

**Runtime deps**
- bash, curl, bind-tools (`dig`), apprise (pip) for the Apprise path. Pushover path uses curl only.

**Binaries/entrypoint/CLI flags**
- Entrypoint in upstream: `bash /opt/ext/scripts/start.sh`. Layout: `scripts/start.sh`, `scripts/lib/ipv4.sh`, `scripts/lib/notify.sh`.
- Provider functions in `lib/ipv4.sh`:
  - `cloudflare_ipv4`: `dig +short txt ch whoami.cloudflare @1.0.0.1`, quotes stripped.
  - `google_ipv4`: `dig TXT +short o-o.myaddr.l.google.com @ns1.google.com`, quotes stripped.
  - `opendns_ipv4`: `dig +short myip.opendns.com @resolver1.opendns.com`.
  - `ipify_ipv4`: `curl -s -k https://api.ipify.org` (`-k` disables TLS verification).
  - `valid_ipv4`: four dot-separated groups of 1 to 3 digits, each at most 255.
- `lib/notify.sh`:
  - PUSHOVER: `curl -s -F token=... -F user=... -F message=... -F title=... https://api.pushover.net/1/messages`
  - APPRISE: loops `APPRISE_1`..`APPRISE_10`, runs `apprise -vv -t "$APPRISE_TITLE" -b "$msg" "<url>"` for each non-empty entry.

**Env vars (table)**

| Name | Default (upstream) | Notes |
| --- | --- | --- |
| `DELAY` | `5m` | Sleep between checks; accepts seconds, m, h, d suffixes. Bad value falls back to 5m. |
| `PROVIDER` | `CLOUDFLARE` | `CLOUDFLARE`, `GOOGLE`, `OPENDNS`, `IPIFY`; any other value uses Cloudflare. |
| `NOTIFICATION_TYPE` | unset | `PUSHOVER` or `APPRISE`. |
| `PUSHOVER_TOKEN` | unset | Required for Pushover. |
| `PUSHOVER_USER` | unset | Required for Pushover. |
| `PUSHOVER_TITLE` | `EXTERNAL IP` | Empty value is reset to the default in `notify`. |
| `APPRISE_TITLE` | `EXTERNAL IP` | Same as above. |
| `APPRISE_1` .. `APPRISE_10` | unset | Apprise URLs such as `pover://user@token`. |
| `RECOVERY_ALERT` | `False` | Compared to literal `True` in start.sh. |
| `SAVE_IP` | unset | Loaded when `${SAVE_IP^^}` is `TRUE`; saved only when equal to literal `True`. |
| `TZ` | unset | Not read by the scripts; affects `date` only. |

**Ports**
None. The container only makes outbound requests.

**Volumes/paths and persistent data**
- Upstream saved-IP file: `/stor-external-ip/ip.saved`, used only when `SAVE_IP` is set. README shows `/path/to/data:/stor-external-ip` as the mount.
- Upstream start.sh touches the file if missing when `SAVE_IP` is TRUE; it writes `echo ${ip} > ${savedIPFile}` on every successful lookup when `SAVE_IP` is `True`.

**User/UID & permissions**
README gives no user details. Upstream Dockerfile has no USER, so it runs as root. The data directory must be writable if `SAVE_IP` is used.

**Config files and formats**
None. Configuration is env only.

**Healthcheck/readiness endpoints**
None.

**Version/release info and asset naming**
- Releases page: "There aren't any releases here." No release assets exist, so no binary to download. Tags exist but were not listed in the fetch.
- Source is consumed by commit SHA. Archive form `https://github.com/xavier-hernandez/docker-external-ip/archive/<commit>.tar.gz` (GitHub generated, not an uploaded asset).
- License: the fetched start.sh and notify.sh pages show no license text. The repo LICENSE was not fetched in this run (the plan records MIT, unverified here).

**Arch support**
Not stated in the repository. Published Docker Hub image lists amd64, arm/v7, arm64/v8 (see dockerhub summary). Script is shell plus pip apprise, so no arch-specific code.

**Gotchas**
- `ipify_ipv4` uses `curl -s -k`, so TLS verification is off.
- Saved-IP load is case-insensitive (`^^`) but the save check is case-sensitive (`"True"`), so `SAVE_IP=true` loads but never saves.
- `RECOVERY_ALERT` is compared case-sensitively to `True`.
- `start.sh` is sourced from `$(dirname "$0")`; it has no `set -e`, and `sleep ${sleep}` is not backgrounded, so TERM is only handled by bash default.
- Apprise URLs and the Pushover token are passed as command-line arguments (visible in the process list).
- README compose example uses key `volume:` (typo for `volumes:`).

**Contradictions with plan.md**
- None of the env names, defaults or Dockerfile facts contradict plan.md.
- plan.md says the upstream tag `v0.0.1` exists and is old; this fetch did not list tags, so it is unverified here.
