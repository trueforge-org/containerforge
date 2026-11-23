# mosdns — implementation plan
> Source: ./draft.md · Target: apps/mosdns/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `5.3.4` (git tag `v5.3.4`, marked Latest on GitHub; draft tag `v5.3.4`, same). Release notes: Go 1.25 build, forward plugin UDP retry after 1s. |
| Renovate | `datasource=github-releases depName=IrineSistiana/mosdns versioning=semver` (tags carry a `v` prefix; if renovate strips it wrongly add `extractVersion=^v(?<version>.+)$`) |
| License | GPL-3.0 (LICENSE at tag v5.3.4 is "GNU General Public License, Version 3"), SPDX `GPL-3.0-only` (UNVERIFIED: whether files say "or later") |
| Source URL | https://github.com/IrineSistiana/mosdns |
| Docs | https://irine-sistiana.gitbook.io/mosdns-wiki/ |
| amd64 asset | https://github.com/IrineSistiana/mosdns/releases/download/v5.3.4/mosdns-linux-amd64.zip |
| arm64 asset | https://github.com/IrineSistiana/mosdns/releases/download/v5.3.4/mosdns-linux-arm64.zip |
| Release assets (verified list) | darwin/freebsd/linux (amd64, arm-5/6/7, arm64, mips64le, mipsle, ppc64le)/windows zips only |
| Checksum source | None published (no `.sha256`/`checksums.txt` in the asset list). Cannot verify; document in Dockerfile comment. |
| Upstream Dockerfile reviewed | Draft points at `Sagit-chu/mosdns-container/Dockerfile` (third-party, clones and compiles). Not used; we use the release zip. UNVERIFIED: its content was not fetched. |
| Command line | `mosdns start -c <config> -d <workdir>` (from the wiki page and the draft; UNVERIFIED flag spelling, confirm with `mosdns start --help` at build time) |
| Config format | YAML with top-level `log`, `api`, `include`, `plugins` (verified from wiki). Plugins init in file order; `sequence` entries use `matches`/`exec`. |
| API | `api.http` defaults to `127.0.0.1:8080` and is marked experimental in the wiki. The draft's "8080/http (API, inferred)" is therefore NOT a default listener. |
| Config/data paths | No fixed path; config is whatever `-c` points to, `-d` is the working dir. Rule/list files are referenced by path from the config. |
| Verified example plugins | `sequence` with `cache 1024`, `has_resp` -> `accept`, `forward https://8.8.8.8/dns-query`; `udp_server`/`tcp_server` with `entry` + `listen`. |

## 2. Target layout

```
apps/mosdns/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.yaml     # template rendered into /config/config.yaml on first start (allow-listed by include/.dockerignore)
```

No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing in apps/ uses mosdns as a `FROM` base; re-check with `grep -r "trueforge-org/mosdns" apps/*/Dockerfile`).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: static-ish Go binary from a release zip, no runtime language needed. `unzip`, `curl`, `ca-certificates`, `gettext-base` (envsubst) are already in the ubuntu base (checked in apps/ubuntu/Dockerfile), so no `apt-get install`. Closest sibling: `apps/adguardhome-sync` (prebuilt release binary on ubuntu, seeds a default config).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`; `ENV HOME=/config`.
2. One `RUN set -eux`:
   - Arch map: `case "${TARGETARCH}" in amd64|arm64) ARCH="${TARGETARCH}";; *) echo "unsupported arch" >&2; exit 1;; esac` (asset names are exactly `mosdns-linux-amd64.zip` / `mosdns-linux-arm64.zip`).
   - `curl -fsSL -o /tmp/mosdns.zip "https://github.com/IrineSistiana/mosdns/releases/download/v${VERSION}/mosdns-linux-${ARCH}.zip"`.
   - No upstream checksum exists; leave a comment saying so (do not invent one).
   - `unzip -q /tmp/mosdns.zip -d /tmp/mosdns`, `install -m 0755 /tmp/mosdns/mosdns /app/mosdns`.
   - License: `mkdir -p /usr/share/licenses/mosdns`; copy `LICENSE*` from the zip if present, otherwise `curl -fsSL -o /usr/share/licenses/mosdns/LICENSE https://raw.githubusercontent.com/IrineSistiana/mosdns/v${VERSION}/LICENSE`. UNVERIFIED: whether the zip ships LICENSE.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/mosdns /tmp/mosdns.zip`.
3. `USER apps`
4. `COPY --chmod=0755 . /`
5. `EXPOSE 5353/tcp 5353/udp`
6. `VOLUME /config`

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "mosdns" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=IrineSistiana/mosdns versioning=semver
  default = "5.3.4"
}

variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/IrineSistiana/mosdns" }
```

Then the four standard targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl` (`image` passes `args.VERSION` and the `source`/`licenses` OCI labels; `image-local` outputs `type=docker` tagged `${APP}:${VERSION}`; `image-all` builds linux/amd64 + linux/arm64). Validate: `cd apps/mosdns && docker buildx bake --print`. Note: the Dockerfile has no default for `ARG VERSION`, bake supplies it, so they cannot drift.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/IrineSistiana/mosdns"
ports:
  - port: 5353
    protocol: tcp
    required: false
  - port: 5353
    protocol: udp
    required: false
env:
  - name: MOSDNS_PORT
    default: "5353"
    required: false
  - name: MOSDNS_UPSTREAM
    default: "https://8.8.8.8/dns-query"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`MOSDNS_PORT` and `MOSDNS_UPSTREAM` are ContainerForge wrapper variables (mosdns itself reads no env vars); they are only used by `start.sh` to render the first-run config, so say that in a YAML comment is not possible per schema; document it in the PR. `dependencies:` omitted: none. Use only `ports` listed here; if `MOSDNS_PORT` is changed the declared port no longer matches, mention in PR notes.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

MOSDNS_PORT="${MOSDNS_PORT:-5353}"
MOSDNS_UPSTREAM="${MOSDNS_UPSTREAM:-https://8.8.8.8/dns-query}"

if [[ ! -s /config/config.yaml ]]; then
  [[ "${MOSDNS_PORT}" =~ ^[0-9]+$ ]] || { echo "MOSDNS_PORT must be numeric" >&2; exit 1; }
  [[ "${MOSDNS_UPSTREAM}" =~ ^[A-Za-z0-9:/._?=-]+$ ]] || { echo "MOSDNS_UPSTREAM contains unsupported characters" >&2; exit 1; }
  export MOSDNS_PORT MOSDNS_UPSTREAM
  envsubst '${MOSDNS_PORT} ${MOSDNS_UPSTREAM}' < /defaults/config.yaml > /config/config.yaml
fi

cd /config
exec /app/mosdns start -c /config/config.yaml -d /config
```

`defaults/config.yaml` (syntax taken from the verified wiki examples; re-validate by starting the binary):

```yaml
log:
  level: info

plugins:
  - tag: main
    type: sequence
    args:
      - exec: cache 1024
      - matches:
          - has_resp
        exec: accept
      - exec: forward ${MOSDNS_UPSTREAM}

  - type: udp_server
    args:
      entry: main
      listen: 0.0.0.0:${MOSDNS_PORT}
  - type: tcp_server
    args:
      entry: main
      listen: 0.0.0.0:${MOSDNS_PORT}
```

Notes: seeds only when `/config/config.yaml` is missing/empty (idempotent, never overwrites user rules); nothing is written to `/app`; binds all interfaces (wiki examples bind 127.0.0.1, which would break other containers); `exec` hands PID to mosdns. User-supplied config in `/config` wins, so users can add rule/list files next to it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '5353'
filePaths:
- /app/mosdns
- /start.sh
- /defaults/config.yaml
```

`timeoutSeconds` value: use the default unless a sibling needs more; adguardhome-sync sets none. Every port in settings.yaml has a probe: the TCP one (5353/tcp); the UDP listener shares the same config block and is checked by hand in section 11 (`dig @127.0.0.1 -p 5353 example.com`), since the schema's probes are tcp/http. The test runs with no env vars, which is fine: defaults render a working config. No database exception applies.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: only what the config asks for (log file is optional, cache is in memory in the default config). Everything lives in `/config` (config + any rule lists) via `-d /config`. `/app` is never written. `HOME=/config`.
- Draft says chart runs as UID 0, `readOnlyRootFilesystem: false`, port 53 needs NET_BIND_SERVICE. Reconciliation: run as `apps` (568), read-only rootfs works, and the container listens on unprivileged 5353. Do NOT use `setcap` on the binary: with a dropped-ALL bounding set a file-capability binary fails to exec. Map 53 to 5353 at the Service/`-p 53:5353/udp` level.
- Extra persistence from the draft (`/etc/mosdns`) is replaced by `/config`; users must point their rule files into `/config`.

## 10. Risks, caveats and open questions

- Draft caveat: rule/list files must be created by hand and some lists are downloaded at start (needs internet). The default config avoids lists so the empty-start works offline except for upstream DNS-over-HTTPS.
- No upstream checksum for the zip, so integrity rests on HTTPS + pinned version.
- Default upstream `https://8.8.8.8/dns-query` is copied from the wiki example; confirm that this is the desired default (privacy), or switch to a neutral option.
- `-c`/`-d` flags and zip layout (binary at the zip root named `mosdns`) are UNVERIFIED (assets listing worked, contents not). Check with `unzip -l` in round 1.
- The API (8080) is not enabled; add it only if needed, binding `0.0.0.0` explicitly.
- No blockers: linux arm64 + amd64 assets exist, Go binary, no GPU/privilege need.

## 11. Build and test steps

```sh
cd apps/mosdns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mosdns-probe --read-only --tmpfs /tmp \
  -v mosdns-probe-config:/config mosdns:5.3.4
docker logs -f mosdns-probe
docker exec mosdns-probe ls /config          # config.yaml seeded
# from outside: dig @<container-ip> -p 5353 example.com   (udp and +tcp)
forgetool containers test --image mosdns:5.3.4 --config ./apps/mosdns/container-test.yaml
docker rm -f mosdns-probe; docker volume rm mosdns-probe-config
```

Expected readiness signal: a mosdns log line showing the udp/tcp servers started on `0.0.0.0:5353` (exact text UNVERIFIED), container still running, no fatal errors. Restart once with the same volume to prove idempotency. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-mosdns`, commit and PR title `feat(mosdns): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` keeping all sections; check only boxes that apply. Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Confirm: bake VERSION == Dockerfile ARG, `bake --print` ok, `USER apps`, `COPY --chmod=0755 . /`, license files shipped, every settings.yaml port probed.
- Untested at planning time: any docker build, arm64 runtime, the rendered config's validity, zip contents/flags, UDP query path.
