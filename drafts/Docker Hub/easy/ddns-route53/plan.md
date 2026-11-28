# ddns-route53 — implementation plan
> Source: ./draft.md · Target: apps/ddns-route53/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.16.1` (latest tag, `v2.16.1`; matches the draft). The chart uses the rolling `crazymax/ddns-route53:latest`. |
| Tag format | `v2.16.1` (with `v`). Renovate keeps the format of the current value, so store `2.16.1` in `VERSION` and add the `v` in the URL (as `apps/adguardhome-sync` does). |
| Renovate | `datasource=github-releases depName=crazy-max/ddns-route53` |
| License | `MIT` (repo `LICENSE`: "MIT License, Copyright (c) 2019-2026 CrazyMax") |
| Source (`SOURCE`, `upstream_env_url`) | https://github.com/crazy-max/ddns-route53 |
| amd64 download | https://github.com/crazy-max/ddns-route53/releases/download/v2.16.1/ddns-route53_2.16.1_linux_amd64.tar.gz |
| arm64 download | https://github.com/crazy-max/ddns-route53/releases/download/v2.16.1/ddns-route53_2.16.1_linux_arm64.tar.gz |
| Checksum source | `checksums.txt` in the same release (`sha256sum -b` format, lines such as `a1a6f288...  *ddns-route53_2.16.1_linux_amd64.tar.gz`). Values for 2.16.1: amd64 `a1a6f2882770e78828444b8d5e8913a63eb512fa3e69e23e90a96710aa8a76c3` (re-computed locally from a download, it matches), arm64 `c8fdb7b17a6f146533bd1b725c4c9bd18398a1a5e080f7b3a33f9422043f963a`. |
| Tarball content (inspected) | `./ddns-route53` (binary), `./CHANGELOG.md`, `./LICENSE`, `./README.md`, all at the archive root. `TARGETARCH` values `amd64`/`arm64` match the file names. |
| Upstream Dockerfile | Reviewed (https://github.com/crazy-max/ddns-route53/blob/master/Dockerfile): static Go build, `FROM alpine`, binary at `/usr/local/bin/ddns-route53`, user uid 1000, `ENTRYPOINT ["ddns-route53"]`, `CMD ["--config","/ddns-route53.yml"]`. No ports, no volumes. The musl/alpine stage does not matter: the release tarball is the same statically linked Go binary (UNVERIFIED with `ldd`; the binary is not executed in this plan, the build step checks it). |
| CLI flags and env (https://crazymax.dev/ddns-route53/usage/cli/) | `--config` / `CONFIG`; `--schedule` / `SCHEDULE` (CRON expression; "If schedule is not set, the app will run once and then exit"); `--ifname` / `IFNAME`; `--max-retries` / `MAX_RETRIES` (3); `--max-backoff-delay` / `MAX_BACKOFF_DELAY` (5s); `--log-level` / `LOG_LEVEL` (info); `--log-json` / `LOG_JSON` (false); `--log-caller` / `LOG_CALLER` (false); `--log-nocolor` / `LOG_NOCOLOR` (false). No timezone flag exists. |
| Config (https://crazymax.dev/ddns-route53/config/) | YAML `ddns-route53.yml` searched in `/etc/ddns-route53/`, `$XDG_CONFIG_HOME/`, `$HOME/.config/`, `.`. Every option can also be given as `DDNSR53_<UPPERCASE_NESTED_PATH>`: `DDNSR53_CREDENTIALS_ACCESSKEYID`, `DDNSR53_CREDENTIALS_SECRETACCESSKEY`, `DDNSR53_ROUTE53_HOSTEDZONEID`, `DDNSR53_ROUTE53_RECORDSSET_0_NAME` / `_0_TYPE` / `_0_TTL` (index per record), `DDNSR53_WANIP_PROVIDERS_IPV4` / `_IPV6` (comma separated URLs). File is read first, then env, so env values override file values (confirmed in `internal/config/config.go`). The search paths there are `$XDG_CONFIG_HOME/ddns-route53.{yaml,yml}` and `$HOME/.config/ddns-route53.{yaml,yml}`, among others. |
| Ports | None (outbound only: WAN IP lookup and AWS Route53 API) |
| Persistent data | None. |

## 2. Target layout

```
apps/ddns-route53/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`: configuration comes from env vars; an optional user-supplied `/config/ddns-route53.yml` is passed through if present, so no template is seeded (it is not needed, and env values override file values anyway).
- No `etc/`, `scripts/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`.
- Closest siblings: `apps/adguardhome-sync` (tarball download, env/config), `apps/cloudflareddns` and `apps/duckdns` (DDNS clients with a `runners` test and an idle path when credentials are missing).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

Single static Go binary, so ubuntu alone is enough (matches the draft). `curl`, `tar`, `ca-certificates` (needed for TLS to AWS) and `tzdata` are already in the base. We do not compile Go; we use the release binary, so the build-stage rule for Go does not apply.

## 4. Dockerfile

1. `FROM` as in section 3, `ARG VERSION`, `ARG TARGETARCH`.
2. `USER root` for the install step only.
3. `ENV HOME=/config` (the app searches `$HOME/.config/` for a config file; nothing else is written).
4. One `RUN set -eux`:
   - `mkdir -p /tmp/ddns && cd /tmp/ddns`
   - `curl -fsSLO "https://github.com/crazy-max/ddns-route53/releases/download/v${VERSION}/ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz"`
   - `curl -fsSLO "https://github.com/crazy-max/ddns-route53/releases/download/v${VERSION}/checksums.txt"`
   - `grep " \*\?ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz\$" checksums.txt | sed 's/ \*/  /' | sha256sum -c -` (checksums use the `sha256sum -b` marker `*`; fail the build if the line is missing)
   - `tar -xzf ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz`
   - `install -m 0755 ddns-route53 /app/ddns-route53`
   - `mkdir -p /usr/share/licenses/ddns-route53 && cp LICENSE /usr/share/licenses/ddns-route53/LICENSE` (only the binary is installed, so ship the licence separately)
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/ddns`
5. `COPY --chmod=0755 . /`
6. No `EXPOSE` (no ports). `VOLUME /config`.
7. Final `USER apps`.

No apt packages, so nothing to pin; the binary equals `VERSION`.

## 5. docker-bake.hcl

- `APP` = `ddns-route53`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=crazy-max/ddns-route53
  default = "2.16.1"
  ```
- `LICENSE` = `MIT`
- `SOURCE` = `https://github.com/crazy-max/ddns-route53`
- Four standard targets plus `group "default"` exactly as in `apps/adguardhome-sync/docker-bake.hcl`; `image-all` = `linux/amd64`, `linux/arm64`.
- Validate: `cd apps/ddns-route53 && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/crazy-max/ddns-route53"
ports:
  []
env:
  - name: SCHEDULE
    default: "*/30 * * * *"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: DDNSR53_CREDENTIALS_ACCESSKEYID
    default: ""
    required: false
  - name: DDNSR53_CREDENTIALS_SECRETACCESSKEY
    default: ""
    required: false
  - name: DDNSR53_ROUTE53_HOSTEDZONEID
    default: ""
    required: false
  - name: DDNSR53_ROUTE53_RECORDSSET_0_NAME
    default: ""
    required: false
  - name: DDNSR53_ROUTE53_RECORDSSET_0_TYPE
    default: "A"
    required: false
  - name: DDNSR53_ROUTE53_RECORDSSET_0_TTL
    default: "300"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

- Only names the app reads (verified from the config and CLI docs) plus `TZ` (as in the siblings). Defaults for `SCHEDULE`, record `TYPE` and `TTL` are OUR choices (upstream has no schedule default and runs once; `A`/`300` are example values), implemented in `start.sh`; the three required values (zone, record name, credentials) are empty and handled by `start.sh` (idles instead of failing).
- `DDNSR53_WANIP_PROVIDERS_*`, further records (`_1_`, `_2_`, ...), `IFNAME`, `MAX_RETRIES`, `LOG_JSON` are valid but not listed to keep the file short; they pass through the environment unchanged. Add them if the maintainers want them documented.
- `volumes` `/config` is optional (only for an optional `ddns-route53.yml`).
- Dependencies: none (external AWS account, hosted zone and IAM permissions).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export SCHEDULE="${SCHEDULE:-*/30 * * * *}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

args=()
if [ -f /config/ddns-route53.yml ]; then
    args+=(--config /config/ddns-route53.yml)
elif [ -z "${DDNSR53_ROUTE53_HOSTEDZONEID:-}" ] || [ -z "${DDNSR53_ROUTE53_RECORDSSET_0_NAME:-}" ]; then
    echo "Please set DDNSR53_ROUTE53_HOSTEDZONEID and DDNSR53_ROUTE53_RECORDSSET_0_NAME (plus AWS credentials) or mount /config/ddns-route53.yml. Idling."
    exec sleep infinity     # idle like apps/duckdns, keeps the image startable without env vars
else
    # only in env-only mode: env overrides the file, so these defaults must not apply to a user's yml
    export DDNSR53_ROUTE53_RECORDSSET_0_TYPE="${DDNSR53_ROUTE53_RECORDSSET_0_TYPE:-A}"
    export DDNSR53_ROUTE53_RECORDSSET_0_TTL="${DDNSR53_ROUTE53_RECORDSSET_0_TTL:-300}"
fi

exec /app/ddns-route53 "${args[@]}"
```

- Secrets stay in the environment (never on the command line or in a file written by the script, so they stay out of the process list).
- Nothing is written to `/app`; no cache is created; `/config` may be empty; fully idempotent; no listener, so there is no bind address question.
- Static credentials are not mandatory: `pkg/route53/route53.go` loads the AWS SDK default config (env `AWS_*`, instance role) and only overrides it when both `DDNSR53_CREDENTIALS_*` values are set, so `start.sh` does not require them.
- Use the `${args[@]}` form carefully with `set -u` on bash >= 4.4 (Ubuntu 26.04 is fine); otherwise expand with `${args[@]+"${args[@]}"}`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# No tcp/http probe: the container opens no port (settings.yaml lists none).
# A real run needs AWS credentials and a hosted zone, which the test cannot supply.
runners:
- entrypoint: /app/ddns-route53 --version
filePaths:
- /app/ddns-route53
- /start.sh
- /usr/share/licenses/ddns-route53/LICENSE
```

- Add `expectedOutput` (probably `2.16.1`) after seeing the real `--version` output in the first run; it is UNVERIFIED in this plan, so do not guess an assertion into the file.
- The credential-dependent update path is checked manually (section 11). Default `timeoutSeconds` is enough.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Handling |
|---|---|
| none for the binary itself (no state, no cache) | nothing to remap |
| optional config file | read-only use of `/config/ddns-route53.yml` or `$HOME/.config/` (`HOME=/config`) |
| logs | stdout/stderr |

Draft expectations: the chart runs as UID 0 with a writable rootfs, no persistence. We run as UID 568 with `readOnlyRootFilesystem: true`, not privileged, no extra persistence (`/config` optional). The upstream image uses uid 1000; this does not matter because the binary writes nothing. Needs outbound internet (WAN IP lookup, AWS API); no inbound ports.

## 10. Risks, caveats and open questions

- Needs AWS credentials (or an IAM role) with Route53 permissions and an existing hosted zone (draft caveat, confirmed by the config docs).
- UNVERIFIED (not run): exact `--version` output; whether `ldd` shows a fully static binary.
- The `SCHEDULE` default `*/30 * * * *` is our choice. Without any schedule upstream runs once and exits, which would restart-loop under an orchestrator.
- With no env vars the container idles with a log line instead of failing, so the forgetool run and CI work.
- Records beyond index 0 must be passed as `DDNSR53_ROUTE53_RECORDSSET_1_*` etc. by the user (documented upstream, not enumerated here).
- No blockers: static Go, both architectures available.

## 11. Build and test steps

```sh
cd apps/ddns-route53
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create ddns-route53-probe-config
docker run --rm -d --name ddns-route53-probe --read-only --tmpfs /tmp \
  -v ddns-route53-probe-config:/config ddns-route53:2.16.1
docker logs -f ddns-route53-probe     # no env: expect the "Idling" message and a running container
docker rm -f ddns-route53-probe; docker volume rm ddns-route53-probe-config
forgetool containers test --image ddns-route53:2.16.1 --config ./apps/ddns-route53/container-test.yaml
```

With real AWS test data (only if the user supplies a sandbox hosted zone): add `-e DDNSR53_*` variables and expect the app's startup line and a "Successfully updated"-style log for the record (exact text UNVERIFIED), and the container staying up between schedule ticks.

## 12. PR checklist

- Branch `feat/add-ddns-route53`, commit and PR title `feat(ddns-route53): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, only check boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested to state: an actual Route53 update (needs credentials), arm64 run, the credential-chain behaviour (read in source only), and the chart migration from `latest` and from env to the new defaults.
- `docker buildx bake --print` before commit; changes only under `apps/ddns-route53/`.
