# cloudflared — implementation plan
> Source: ./draft.md · Target: apps/cloudflared/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2026.11.2` is the latest tag and release (2026-11-23 check). The draft says `2026.11.1`, which also exists. Use `2026.11.2`. |
| Tag format | `YYYY.M.P`, no `v` prefix (verified with `git ls-remote --tags`) |
| Renovate | `datasource=github-releases depName=cloudflare/cloudflared` (default semver works; if renovate rejects `2026.11.2` as non-semver, add `versioning=loose`) |
| License | `Apache-2.0` (repo `LICENSE` is the Apache License 2.0) |
| Source (`SOURCE`, `upstream_env_url`) | https://github.com/cloudflare/cloudflared |
| amd64 download | https://github.com/cloudflare/cloudflared/releases/download/2026.11.2/cloudflared-linux-amd64 (raw binary, HTTP 200, `file` says statically linked Go ELF x86-64) |
| arm64 download | https://github.com/cloudflare/cloudflared/releases/download/2026.11.2/cloudflared-linux-arm64 (HTTP 200) |
| Draft's `.pkg` links | Those are macOS installers (`cloudflared-amd64.pkg`); do NOT use. Linux assets are `cloudflared-linux-<arch>` (raw), `.deb` and `.rpm`. |
| Checksum source | The release notes contain a `Checksums:` block with lines like `cloudflared-linux-amd64: 56f13335...`. Seen for 2026.11.2: amd64 `56f13335143ec0e22772963290683a84a04114a35ec64cbc794a4d39ff9bb8cf` (re-computed locally from a download, it matches), arm64 `04a7b7f08bce85d56b26ffe1fdbfbb21a074495a363d16f0783c40e25b5c5281`. GitHub also shows `sha256:` digests on each asset. No separate `.sha256` asset (404). |
| Upstream Dockerfile | Reviewed (master): builds with Go 1.27.4, `CGO_ENABLED=0`, copies the binary to `/usr/local/bin/` in `gcr.io/distroless/base-debian13:nonroot`, `USER 65532:65532`, `ENV NO_AUTOUPDATE=true`, `ENTRYPOINT ["cloudflared"]`, `CMD ["version"]`. Build-time `CONTAINER_BUILD=1` changes how the metrics server binds (container builds bind `0.0.0.0`). |
| Env vars (Cloudflare run-parameters docs) | `TUNNEL_TOKEN`, `TUNNEL_TOKEN_FILE` (needs >= 2025.4.0), `TUNNEL_METRICS` (`IP:PORT`), `NO_AUTOUPDATE`, `TUNNEL_LOGLEVEL` (default `info`), `TUNNEL_TRANSPORT_PROTOCOL` (`auto`/`http2`/`quic`), `TUNNEL_EDGE_IP_VERSION` (`4`/`auto`/`6`) |
| Metrics port | Docs: non-container default is `127.0.0.1` on the first free port of 20241-20245; container default is `0.0.0.0:<PORT>/metrics`. Only `/metrics` is documented. `/ready` and `/healthcheck` endpoints are UNVERIFIED in this pass. |

## 2. Target layout

```
apps/cloudflared/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`: the connector is configured only by environment variables (token) and needs no seeded files.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (no app uses cloudflared as a `FROM` base).
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary download) and `apps/tailscale` (network sidecar, `runners` test).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

The binary is a static Go executable, so plain ubuntu is enough. `curl`, `ca-certificates` and `tzdata` are already in the base. The binary is downloaded in the final stage, so the Go build-stage rule does not apply (we do not compile Go).

## 4. Dockerfile

1. `FROM` as above, then `ARG VERSION`, `ARG TARGETARCH` (values `amd64` / `arm64` match the asset suffix, no mapping needed).
2. `USER root` for the install step only.
3. `ENV HOME=/tmp NO_AUTOUPDATE=true` (cloudflared writes its cert/cache under `$HOME/.cloudflared`; with a token only `/tmp` is needed. `NO_AUTOUPDATE=true` is what upstream sets in its image).
4. One `RUN` (`set -eux`):
   - `curl -fsSLo /app/cloudflared "https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}"`
   - checksum: read the `Checksums:` block from the release page and compare, e.g.
     `expected="$(curl -fsSL "https://github.com/cloudflare/cloudflared/releases/tag/${VERSION}" | grep -o -E "cloudflared-linux-${TARGETARCH}: [0-9a-f]{64}" | head -n1 | cut -d' ' -f2)"`, fail if empty, then `echo "${expected}  /app/cloudflared" | sha256sum -c -`. This scraping is the only way to verify from upstream data without pinning hashes in the Dockerfile; if GitHub changes the page markup the build fails loudly (acceptable).
   - `chmod 0755 /app/cloudflared && chown -R apps:apps /app`
   - licence: `mkdir -p /usr/share/licenses/cloudflared && curl -fsSLo /usr/share/licenses/cloudflared/LICENSE "https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE"` (a raw binary is shipped, so the licence must be added separately; also add `https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE.thirdparty` if it exists, UNVERIFIED).
5. `COPY --chmod=0755 . /`
6. `EXPOSE 20241`
7. `VOLUME /config` (kept for consistency with siblings; the token mode stores nothing, so the volume is only for an optional `config.yml`).
8. Final `USER apps`.

No apt packages are added, so no version pinning is needed. The binary version equals `VERSION`.

## 5. docker-bake.hcl

- `APP` = `cloudflared`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=cloudflare/cloudflared
  default = "2026.11.2"
  ```
- `LICENSE` = `Apache-2.0`
- `SOURCE` = `https://github.com/cloudflare/cloudflared`
- Four standard targets and the default group exactly as in `apps/adguardhome-sync/docker-bake.hcl` (`image-all` with `linux/amd64` and `linux/arm64`).
- Validate: `cd apps/cloudflared && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cloudflare/cloudflared"
ports:
  - port: 20241
    protocol: tcp
    required: false
env:
  - name: TUNNEL_TOKEN
    default: ""
    required: false      # without it the container idles with a log message (see start.sh)
  - name: TUNNEL_TOKEN_FILE
    default: ""
    required: false
  - name: TUNNEL_METRICS
    default: "0.0.0.0:20241"
    required: false
  - name: TUNNEL_LOGLEVEL
    default: "info"
    required: false
  - name: TUNNEL_TRANSPORT_PROTOCOL
    default: "auto"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

Dependencies: none (no `dependencies:` entry; needs only outbound internet and a Cloudflare account). `TUNNEL_TOKEN` is `required: false` with an empty default because the image must start without env vars (the forgetool test gives none) and `start.sh` handles the empty case.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export TUNNEL_METRICS="${TUNNEL_METRICS:-0.0.0.0:20241}"
export NO_AUTOUPDATE=true

if [ -z "${TUNNEL_TOKEN:-}" ] && [ -z "${TUNNEL_TOKEN_FILE:-}" ]; then
    echo "Please set TUNNEL_TOKEN (or mount a secret and set TUNNEL_TOKEN_FILE). Idling until the container is restarted with a token."
    exec sleep infinity       # same pattern as apps/duckdns when credentials are missing
fi

exec /app/cloudflared tunnel --no-autoupdate run
```

- `cloudflared tunnel run` reads `TUNNEL_TOKEN` or `TUNNEL_TOKEN_FILE` from the environment itself, so the secret never appears on the command line or in the process list.
- Metrics bind to `0.0.0.0:20241` explicitly because the release binary (not built with `CONTAINER_BUILD`) defaults to `127.0.0.1` (UNVERIFIED for the release build, explicit flag makes it irrelevant).
- Nothing is written to `/app`; `HOME=/tmp` covers any cache. Idempotent, nothing seeded in `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# The metrics port (20241) only opens once a tunnel runs, which needs a real TUNNEL_TOKEN.
# The test runs without env vars, so the port is checked manually (see plan section 11), not here.
runners:
- entrypoint: /app/cloudflared --version
  expectedOutput: cloudflared version
filePaths:
- /app/cloudflared
- /start.sh
- /usr/share/licenses/cloudflared/LICENSE
```

- The only port in `settings.yaml` (20241) has no `tcp` probe, with the reason in a comment. This is the "code path needs a secret" case from the container-test rules; the tunnel path must be run by hand with a real token.
- Unverified: the exact `--version` output text (`cloudflared version 2026.11.2 (built ...)` expected). Check on first run; assert on the real text.
- `timeoutSeconds`: default is fine, `apps/tailscale` uses none.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `$HOME/.cloudflared/` (cert.pem, tunnel creds, default config) | `HOME=/tmp`; token mode needs no files. For locally managed tunnels users mount `/config` and pass `--config` (not wired by default) |
| auto-update replacing the binary | disabled with `NO_AUTOUPDATE=true` / `--no-autoupdate` (`/app` is read-only) |
| logs | stdout/stderr only |

Draft security expectation (non-root UID 568, read-only rootfs, not privileged) is met: chart default 568 equals the `apps` user, no extra persistence is needed. UDP buffer sizing warnings (QUIC) cannot be fixed from inside a rootless container; they are only log warnings.

## 10. Risks, caveats and open questions

- Needs a Cloudflare account and a tunnel token (secret), plus outbound internet; no inbound port.
- The draft's `.pkg` URLs are macOS; plan uses the raw Linux binaries instead.
- Draft pins `2026.11.1`; latest is `2026.11.2`.
- Checksum comes from scraping the release page; fragile but fails closed.
- The container idles without a token (consistent with `apps/duckdns`); document that in the PR.
- UNVERIFIED: metrics `/ready` and `/healthcheck` endpoints (no http probe added because of this and because the port needs a token).
- Flag position: the global `--no-autoupdate` is placed after `tunnel` here; if cloudflared rejects it, use `NO_AUTOUPDATE` only.
- No blockers: static binary, arm64 asset exists.

## 11. Build and test steps

```sh
cd apps/cloudflared
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create cloudflared-probe-config
docker run --rm -d --name cloudflared-probe --read-only --tmpfs /tmp \
  -v cloudflared-probe-config:/config cloudflared:2026.11.2
docker logs -f cloudflared-probe       # no token: expect the idle message and a running container
docker rm -f cloudflared-probe; docker volume rm cloudflared-probe-config
forgetool containers test --image cloudflared:2026.11.2 --config ./apps/cloudflared/container-test.yaml
```

Manual path with a real token (only if the user has one): add `-e TUNNEL_TOKEN=...`, expect `Registered tunnel connection` lines and `curl http://<ip>:20241/metrics` to answer. State in the PR if this was not run.

## 12. PR checklist

- Branch `feat/add-cloudflared`, commit and PR title `feat(cloudflared): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, only check the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows the status).
- Untested to state honestly: a real tunnel connection (needs a token), the metrics port probe, arm64, the `--version` output text, the release-page checksum scrape on future versions.
- `docker buildx bake --print` run before commit; changes only under `apps/cloudflared/`.
