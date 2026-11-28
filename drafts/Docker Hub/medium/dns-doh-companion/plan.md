# dns-doh-companion — implementation plan
> Source: ./draft.md · Target: apps/dns-doh-companion/ · Difficulty: medium (effectively blocked, see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

**Version differs from the draft.** The draft links cloudflared `2026.11.1`. This plan targets **`2026.1.2`**, the last release that still contains `cloudflared proxy-dns`. Cloudflare removed the command in `2026.2.0` (changelog post 2025-11-11, "proxy-dns command will be removed starting February 2, 2026"). In `2026.11.2`, `cmd/cloudflared/proxydns/cmd.go` is a stub that only logs "DNS Proxy is no longer supported since version 2026.2.0". Anything newer than 2026.1.2 cannot provide this container's function.

| Item | Value |
| --- | --- |
| Version (plan) | `2026.1.2` (draft: `2026.11.1`; latest upstream: `2026.11.2`, which has no working proxy-dns) |
| Renovate | `datasource=github-releases depName=cloudflare/cloudflared versioning=loose`. Renovate would propose the broken 2026.2.0+ releases, so the bump must be blocked (see section 10). |
| License | Apache-2.0 (`LICENSE` in the cloudflared repo, verified at tag 2026.1.2) |
| Source | https://github.com/cloudflare/cloudflared |
| amd64 download | https://github.com/cloudflare/cloudflared/releases/download/2026.1.2/cloudflared-linux-amd64 (HTTP 200, a bare static binary, no archive) |
| arm64 download | https://github.com/cloudflare/cloudflared/releases/download/2026.1.2/cloudflared-linux-arm64 (HTTP 200) |
| Checksums | Listed in the release notes of tag 2026.1.2. amd64 `e157c54e929cc289cbd53860453168c2fe3439eb55e2e965a56579252585d9c1`, arm64 `1362498b9975e018f290cc4412af61391cca65cccbc06f2d8b128324ae9a18ef` |
| Upstream Dockerfile reviewed | https://github.com/testdasi/simple-dns-doh/blob/354be66/Dockerfile (debian-slim base, installs the cloudflared `.deb` from `releases/latest`, exposes 53/tcp and 53/udp, `CMD cloudflared --config /etc/cloudflared/config.yml`). Its `install.sh` and `config.yml` were also read. |

Real settings (read from `cmd/cloudflared/proxydns/cmd.go` at 2026.1.2), each flag with its env var:

| Flag | Env var | Default |
| --- | --- | --- |
| `--address` | `TUNNEL_DNS_ADDRESS` | `localhost` |
| `--port` | `TUNNEL_DNS_PORT` | `53` |
| `--upstream` | `TUNNEL_DNS_UPSTREAM` | `https://1.1.1.1/dns-query`, `https://1.0.0.1/dns-query` |
| `--bootstrap` | `TUNNEL_DNS_BOOTSTRAP` | Cloudflare IP DoH endpoints |
| `--max-upstream-conns` | `TUNNEL_DNS_MAX_UPSTREAM_CONNS` | upstream default |
| `--metrics` | `TUNNEL_METRICS` | `localhost:` (random port) |

`tunneldns/tunnel.go` starts both a UDP and a TCP listener on the DNS port.

UNVERIFIED: comma-separated values in `TUNNEL_DNS_UPSTREAM` (standard urfave/cli slice-flag behaviour, not tested). `start.sh` therefore passes `--upstream` flags explicitly instead.

## 2. Target layout

```
apps/dns-doh-companion/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `scripts/` or `health/`: no config file is needed because everything is passed as flags. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

A static Go binary needs nothing beyond ubuntu (curl is already present in the base, as `apps/adguardhome-sync/Dockerfile` relies on it). Closest sibling: `apps/adguardhome-sync` (prebuilt binary, `TARGETARCH` mapping, `start.sh` that execs the binary).

## 4. Dockerfile

1. `FROM` line from section 3, then `ARG VERSION`, `ARG TARGETARCH`, `ARG SHA256_AMD64`, `ARG SHA256_ARM64`. Their defaults must be mirrored in `docker-bake.hcl` (`VERSION` passes through `args`; the two checksums are pinned in the Dockerfile and updated together with `VERSION`).
2. `USER root`, then one `RUN` layer that:
   - maps the arch: `TARGETARCH` is already `amd64` or `arm64`, which matches the upstream asset names;
   - downloads `cloudflared-linux-${TARGETARCH}` to `/tmp/cloudflared` with `curl -fsSL`;
   - verifies it. Pick the expected sum with `case "$TARGETARCH" in amd64) SUM="$SHA256_AMD64";; arm64) SUM="$SHA256_ARM64";; esac`, then run `echo "$SUM  /tmp/cloudflared" | sha256sum -c -`;
   - installs it with `install -m 0755 /tmp/cloudflared /app/cloudflared`;
   - fetches the license: `mkdir -p /usr/share/licenses/dns-doh-companion && curl -fsSL -o /usr/share/licenses/dns-doh-companion/LICENSE https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE`;
   - runs `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/*`.
3. `ENV HOME=/tmp` (cloudflared looks for `~/.cloudflared`; keep it on tmpfs, never `/config`).
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 5053/tcp 5053/udp`
7. `VOLUME /config`. Nothing is written there, but it is kept for consistency with the siblings and to satisfy the repo convention. The repo requires `VOLUME /config`, so keep it together with the `volumes` entry in section 6.

Verify with `cloudflared --version` at build time (`RUN /app/cloudflared --version | grep -q "${VERSION}"`) so the image provably contains the tagged version.

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl` exactly (`docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`).

```hcl
variable "APP" {
  default = "dns-doh-companion"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=cloudflare/cloudflared versioning=loose
  default = "2026.1.2"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/cloudflare/cloudflared"
}
```

`image-local` is tagged `${APP}:${VERSION}`; `image-all` has platforms `linux/amd64` and `linux/arm64`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cloudflare/cloudflared"
ports:
  - port: 5053
    protocol: tcp
    required: true
  - port: 5053
    protocol: udp
    required: true
env:
  - name: TUNNEL_DNS_PORT
    default: "5053"
    required: false
  - name: TUNNEL_DNS_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: DOH_UPSTREAMS
    default: "https://1.1.1.1/dns-query https://1.0.0.1/dns-query"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

`DOH_UPSTREAMS` is a wrapper variable defined and read by `start.sh` (space-separated list). It is not an upstream cloudflared variable. The other two are real upstream variables, read by cloudflared.

Dependencies: none, so no `dependencies` or `opt_dependencies` block. `/config` is listed (`required: false`) because the Dockerfile keeps `VOLUME /config`; nothing is written there.

The port is 5053 rather than the draft's 53 (unprivileged, since the image runs as `apps`). Map host port 53 to container 5053 at deploy time.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

port="${TUNNEL_DNS_PORT:-5053}"
address="${TUNNEL_DNS_ADDRESS:-0.0.0.0}"
upstreams="${DOH_UPSTREAMS:-https://1.1.1.1/dns-query https://1.0.0.1/dns-query}"

args=()
for u in ${upstreams}; do
  args+=(--upstream "$u")
done

exec /app/cloudflared proxy-dns \
  --address "$address" \
  --port "$port" \
  "${args[@]}"
```

- Idempotent and stateless: nothing is seeded or written. `/config` can be empty.
- Never writes to `/app`. `HOME=/tmp` is set in the Dockerfile.
- Binds `0.0.0.0` so other containers can use it as their resolver.
- `exec` hands PID 1 (tini via the base entrypoint) to cloudflared so signals propagate.
- No secrets and no database.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5053'

healthCommands:
- command: grep -qi ':13BD ' /proc/net/udp /proc/net/udp6
- command: /app/cloudflared --version
  expectedContent: "2026.1.2"   # UNVERIFIED: no app in apps/ uses expectedContent/matchContent; check the forgetool schema, else drop these two keys (the Dockerfile build-time grep already proves the version)
  matchContent: true

filePaths:
- /app/cloudflared
- /usr/share/licenses/dns-doh-companion/LICENSE
```

- The `tcp` probe covers 5053/tcp. The schema has no UDP probe, so 5053/udp is covered by checking `/proc/net/udp` for hex port `13BD` (5053).
- Add `timeoutSeconds: 60` if the sibling default proves too short (`apps/adguardhome-sync` sets none).
- The test runs with no env vars, which works because every variable has a default.
- No DB dependency, so no narrowing applies.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Adaptation |
| --- | --- |
| testdasi image runs as root (TrueCharts sets `runAsUser 0`) so it can bind port 53 | Runs as `apps`. DNS listens on 5053 (`TUNNEL_DNS_PORT`). Map host/service port 53 to 5053. |
| `readOnlyRootFilesystem: false` in the chart | Rootfs is read-only. The binary lives in `/app` (read-only). cloudflared writes nothing to disk for `proxy-dns`; `HOME=/tmp` as a safety net. |
| `/etc/cloudflared/config.yml` read at start | Not used. All options are passed as flags. |
| Metrics server on `localhost:<random>` | Left on localhost (default). Not exposed and not listed in settings. |
| No extra persistence in the chart | None added. No `/config` data. |

## 10. Risks, caveats and open questions

- **Blocker-grade: the feature is removed upstream.** `proxy-dns` is gone from `cloudflared` 2026.2.0 and later (stub confirmed in 2026.11.2). This plan pins the last version that has it, 2026.1.2. Cloudflare's support policy is one year from a release's date, so this pin is unsupported after roughly early 2027. Decision needed from the maintainers: ship the pinned legacy build, or replace the engine with another DoH client (for example dnscrypt-proxy; UNVERIFIED, not researched here, and out of scope for this draft).
- **Renovate must not bump this.** A `github-releases` annotation on cloudflared will open PRs for 2026.2.0 and later that break the container. Either add a renovate `packageRules` entry that disables or caps cloudflared (outside `apps/`, so a maintainer must do it) or accept that those PRs get closed. The checksum ARGs also need hand updates on any bump.
- UNVERIFIED: that 2026.1.2 `proxy-dns` actually starts in this image. The source file exists at the tag and the flags were read from it, but nothing was run. Step 3 of section 11 is the real test.
- Draft security expectation reconciled: the chart runs as root on port 53. Not copied (see section 9).
- Outbound access to Cloudflare DoH endpoints (and the bootstrap IPs) is required. In the sandboxed test the container may log upstream errors but should still listen.
- No `HEALTHCHECK` change needed: the base `healthcheck.sh` reads `container-test.yaml`.
- On hosts where systemd-resolved holds port 53 this is irrelevant because the container listens on 5053.

## 11. Build and test steps

```sh
cd apps/dns-doh-companion
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name dns-doh-companion-probe --read-only --tmpfs /tmp \
  -v dns-doh-companion-probe-config:/config dns-doh-companion:2026.1.2
docker logs -f dns-doh-companion-probe

forgetool containers test \
  --image dns-doh-companion:2026.1.2 \
  --config ./apps/dns-doh-companion/container-test.yaml

docker rm -f dns-doh-companion-probe; docker volume rm dns-doh-companion-probe-config
```

Readiness signal: a cloudflared log line about starting the DNS over HTTPS proxy / listening on `0.0.0.0:5053`, with the container still running and no "no longer supported" message (that message means the wrong version was built). Also resolve a name against the running container with `dig @<container-ip> -p 5053 example.com` from the host or another container.

The forgetool `--config` path assumes the repo root, so `cd` back to the repo root before running it.

## 12. PR checklist

- Branch `feat/add-dns-doh-companion`, commit and PR title `feat(dns-doh-companion): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention in the PR: pinned to 2026.1.2 because proxy-dns was removed in 2026.2.0, and port 5053 instead of 53.
- Pre-completion checklist: `docker buildx bake --print` exits 0; `Dockerfile` `ARG VERSION` equals the bake `VERSION`; final `USER apps`; `COPY --chmod=0755 . /` present; runs on `--read-only --tmpfs /tmp` with an empty `/config`.
- Untested until someone runs them: the docker build on both arches, the runtime start of `proxy-dns` at 2026.1.2, UDP resolution, arm64, and the `forgetool` run. If these were not run, say so in the PR and leave "Built container locally" unchecked.
