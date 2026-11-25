# minecraft-router — implementation plan
> Source: ./draft.md · Target: apps/minecraft-router/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.56.5 (marked Latest, released 17 Nov; https://github.com/itzg/mc-router/releases/latest). Chart and draft use 1.56.5. Docker Hub `itzg/mc-router:1.56.5` pushed 2026-11-17 (https://hub.docker.com/v2/repositories/itzg/mc-router/tags/1.56.5). |
| Renovate | `datasource=github-releases depName=itzg/mc-router versioning=semver` |
| License | UNVERIFIED: repo LICENSE could not be fetched (raw main and blob URLs returned 404). Expected to be the upstream license; confirm before setting `LICENSE` in bake. |
| Source URL | https://github.com/itzg/mc-router |
| Download amd64 | https://github.com/itzg/mc-router/releases/download/v1.56.5/mc-router_1.56.5_linux_amd64.tar.gz (confirmed asset name) |
| Download arm64 | https://github.com/itzg/mc-router/releases/download/v1.56.5/mc-router_1.56.5_linux_arm64.tar.gz (confirmed asset name) |
| Checksum source | `mc-router_1.56.5_checksums.txt` on the same release (name confirmed; hash values UNVERIFIED, file not fetched). |
| Tar layout | UNVERIFIED: archive contents not listed. Upstream image copies `/mc-router` to root, so the binary is probably named `mc-router` at the archive root. Confirm with `tar -tzf` once downloaded at build time. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/itzg/mc-router/main/Dockerfile: builder golang:1.27.4 with `CGO_ENABLED=0` and cache mounts, final `cgr.dev/chainguard/static`, `ENTRYPOINT ["/mc-router"]`. No CMD, USER, EXPOSE, VOLUME or ENV. |
| Ports | 25565/tcp (Minecraft proxy; draft and chart). API port 25564 is draft-inferred only: UNVERIFIED, not added. |
| Env vars | None set by upstream image. mc-router's own flags/env: UNVERIFIED (README not fetched). Do not invent any. |
| Dependencies | One or more reachable Minecraft backend servers (external). No database. |

## 2. Target layout

- `apps/minecraft-router/Dockerfile`
- `apps/minecraft-router/docker-bake.hcl`
- `apps/minecraft-router/settings.yaml`
- `apps/minecraft-router/container-test.yaml`
- `apps/minecraft-router/start.sh`

No `defaults/`, `etc/` or `health/` unless a verified config is needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The binary is static Go, so no runtime packages are needed. Closest sibling: `apps/adguardhome-sync` (release tarball extracted into `/app`).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download and verify:
   - `curl -fL -o /tmp/mc-router.tar.gz "https://github.com/itzg/mc-router/releases/download/v${VERSION}/mc-router_${VERSION}_linux_${TARGETARCH}.tar.gz"`
   - `curl -fL -o /tmp/checksums.txt "https://github.com/itzg/mc-router/releases/download/v${VERSION}/mc-router_${VERSION}_checksums.txt"`
   - `grep "mc-router_${VERSION}_linux_${TARGETARCH}.tar.gz" /tmp/checksums.txt | (cd /tmp && sha256sum -c -)` (line format confirmed at build time; UNVERIFIED).
3. Extract only the binary: `tar xzf /tmp/mc-router.tar.gz -C /tmp mc-router` (the exact member path to confirm, section 1), then `install -m 0755 /tmp/mc-router /app/mc-router`.
4. `chown -R apps:apps /app && chmod -R 755 /app`.
5. Cleanup: `rm -rf /tmp/mc-router.tar.gz /tmp/mc-router /tmp/checksums.txt`.
6. `ENV HOME=/config`. No cache paths are needed.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 25565
VOLUME /config
```

Use `VOLUME /config` only if the app writes state there; otherwise omit it (section 9). Keep `ARG VERSION` equal to the bake default.

## 5. docker-bake.hcl

Same layout as `apps/adguardhome-sync/docker-bake.hcl`:

- `APP` = `minecraft-router`
- `VERSION` = `1.56.5`, preceded by `// renovate: datasource=github-releases depName=itzg/mc-router versioning=semver`
- `LICENSE` = UNVERIFIED (set after the repo license is confirmed; do not guess)
- `SOURCE` = `https://github.com/itzg/mc-router`
- targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (`linux/amd64`, `linux/arm64`), `group "default"` (image-local)

Validate with `docker buildx bake --print` from `apps/minecraft-router`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/itzg/mc-router"
ports:
  - port: 25565
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

- `volumes: []` because the upstream binary keeps no state (draft: "no state beyond routing config"). If routing config is later confirmed to be a file, switch to `- path: /config` with `required: true`, and seed it in start.sh.
- Env vars: only TZ until mc-router's own env/flag names are confirmed. Do not add invented names.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /app
exec /app/mc-router "$@"
```

- Routing is set by command-line arguments; the exact flag names (for example mappings and bind address) are UNVERIFIED. Once confirmed, map them from env vars named in settings.yaml with defaults (for example `port` 25565 and the bind address `0.0.0.0`), following the start-script rule about binding all interfaces.
- No writes: no `/config` use, so no seeding is needed.
- `exec` so signals reach PID 1.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 30
tcp:
- port: '25565'
filePaths:
- /app/mc-router
- /start.sh
```

- Every settings port has a tcp probe (25565).
- The test runs with no env vars and no routing config. If mc-router exits without a mapping, the tcp probe fails. The fix is a verified default mapping (or a documented default behavior), not a weaker test. UNVERIFIED until the binary is run.
- No http probe: no HTTP port is confirmed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None in the upstream image | No write paths. Binary lives at `/app/mc-router` (read-only at runtime). |
| Discovery via Docker/Kubernetes APIs (chart feature) | Not applicable: no socket or API access for a rootless container. Use static mappings only. |

- Runs as `apps` on a high port (25565 is above 1024, no CAP_NET_BIND needed).
- Read-only rootfs with `--tmpfs /tmp`. No `/config` writes expected.
- Draft expectations: non-root yes, read-only yes, privileged no, extra persistence none. No conflicts.

## 10. Risks, caveats and open questions

- UNVERIFIED: repo LICENSE (raw main and blob URLs returned 404). Required before setting `LICENSE`.
- UNVERIFIED: tar member layout (binary name and path) and checksum line format. Confirm at build time before relying on the `tar` step.
- UNVERIFIED: mc-router flags/env vars and default bind address. Settings `env` stays minimal until confirmed.
- UNVERIFIED: API port 25564 (draft-inferred). Not added to `ports`.
- Docker/Kubernetes auto-discovery in the chart is not available in a rootless static setup. Document this as a feature gap in the PR.
- Chart's `latest` and copy-from image `ghcr.io/itzg/mc-router:1.56.5` (Docker Hub confirms amd64, arm64, arm/v6 for 1.56.5) are not used as a source; the release tarball is.
- Blockers: none known. Not musl-only (static build), no GPU, no privileged need.

## 11. Build and test steps

From `apps/minecraft-router/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name minecraft-router-probe --read-only --tmpfs /tmp \
  minecraft-router:1.56.5
docker logs -f minecraft-router-probe
docker rm -f minecraft-router-probe
forgetool containers test --image minecraft-router:1.56.5 --config ./container-test.yaml
```

- No `/config` volume is needed because the app keeps no state. The protocol's empty-`/config` check still applies to the test run: if a volume is mounted, use a fresh one.
- Expected readiness signal: a startup log line from mc-router showing the listener on 25565 (exact text UNVERIFIED), and the process still running after the startup window.
- arm64: build only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-minecraft-router`, commit `feat(minecraft-router): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it. The `license/cla` check shows status.
- State what was not tested: arm64, checksum values, tar layout, routing behavior, LICENSE (see section 10).
- Do not check "Built container locally" unless the image was built and run.
