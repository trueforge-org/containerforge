# unpoller — implementation plan
> Source: ./draft.md · Target: apps/unpoller/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v5.10.1 (latest GitHub release, published 2026-11-23). The draft pins v5.9.6, which is outdated: use 5.10.1. Source: https://api.github.com/repos/unpoller/unpoller/releases/latest |
| Renovate | `datasource=github-releases depName=unpoller/unpoller versioning=semver` (tag has a `v` prefix; `VERSION` stores `5.10.1`) |
| License | MIT (GitHub SPDX `MIT`). Source: https://api.github.com/repos/unpoller/unpoller |
| Source URL | https://github.com/unpoller/unpoller (the draft's unifi-poller/unifi-poller name redirects to this repo; not archived) |
| Download amd64 | https://github.com/unpoller/unpoller/releases/download/v5.10.1/unpoller_5.10.1_linux_amd64.tar.gz |
| Download arm64 | https://github.com/unpoller/unpoller/releases/download/v5.10.1/unpoller_5.10.1_linux_arm64.tar.gz |
| Checksum source | https://github.com/unpoller/unpoller/releases/download/v5.10.1/unpoller_5.10.1_checksums.txt (also `.sig`). Confirmed: `72d09990174f305347d00f4ca618c23242307ba9c542285688b525523e005fd3` (amd64), `71c77a3636f0a58d7bbe28df07c656947dabad26f0c3b831f661e4197aa378f1` (arm64) |
| Upstream Dockerfile reviewed | Tag v5.10.1 `Dockerfile` (read via `gh api`): busybox builder copies `examples/up.conf.example` to `/etc/unpoller/up.conf`, plus `unpoller_manual.html` and `README.html`; final `gcr.io/distroless/static-debian13`, `COPY ${TARGETPLATFORM}/unpoller /usr/bin/unpoller`, `HEALTHCHECK CMD ["/usr/bin/unpoller", "--health"]`, `ENTRYPOINT ["/usr/bin/unpoller"]`. No USER, EXPOSE, VOLUME or ENV. |
| Port | 9130/tcp (metrics): `examples/up.conf.example` at v5.10.1 has `[prometheus] http_listen = "0.0.0.0:9130"`. |
| Env vars | Upstream maps config keys to env vars with the prefix `UP` (`ENVConfigPrefix = "UP"` in `pkg/poller/config.go`). The individual variable names are UNVERIFIED; do not list any until confirmed. |
| Config file | `/etc/unpoller/up.conf` is shipped by upstream as the example config. The `--config` flag name is UNVERIFIED (confirm with `unpoller --help` in step 11). |

## 2. Target layout

- `apps/unpoller/Dockerfile`
- `apps/unpoller/docker-bake.hcl`
- `apps/unpoller/settings.yaml`
- `apps/unpoller/container-test.yaml`
- `apps/unpoller/start.sh` (seeds `/config` and `exec`s the binary)
- `apps/unpoller/etc/unpoller/up.conf` (example config, seeded to `/config` only when missing; needed because the Dockerfile copies `etc/` from the app folder and `etc/` is in `.dockerignore`)

No `defaults/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base). The `etc/` copy is needed only if the example config is shipped; if the team prefers env-only config, drop it and write no config file.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because unpoller is a single Go release binary: no runtime is needed, so no java, python or node base. The draft says "ubuntu alone is enough", which matches. Closest sibling for a prebuilt-binary app: `apps/adguardhome-sync` (prebuilt binary on ubuntu). Note: sibling Dockerfiles use the tag `26.4`; the brief's `26.04` tag with the same digest is used here. The digest is the same, so the image is identical.

## 4. Dockerfile

1. `FROM <ubuntu> ` with `ARG VERSION` and `ARG TARGETARCH` (buildx provides `TARGETARCH`).
2. `USER root` for the install step only (curl and tar are expected in the base; confirm with a build).
3. Map and download the release tarball and its checksum file, verify, extract only the binary:

```dockerfile
RUN set -eux; \
    case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac; \
    base="https://github.com/unpoller/unpoller/releases/download/v${VERSION}"; \
    file="unpoller_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    mkdir -p /app/unpoller /tmp/unpoller-dl; \
    curl -fsSL -o "/tmp/unpoller-dl/${file}" "${base}/${file}"; \
    curl -fsSL -o /tmp/unpoller-dl/checksums.txt "${base}/unpoller_${VERSION}_checksums.txt"; \
    (cd /tmp/unpoller-dl && grep " ${file}\$" checksums.txt | sha256sum -c -); \
    tar -xzf "/tmp/unpoller-dl/${file}" -C /app/unpoller unpoller; \
    chmod 0755 /app/unpoller/unpoller; \
    rm -rf /tmp/unpoller-dl
```

   Caveat: the checksum file comes from the same release as the tarball, so it proves integrity against the release, not an independent pin. Pinning per-arch SHA-256 values as bake `ARG`s is stricter and is an open question (section 10).
4. License: `mkdir -p /usr/share/licenses/unpoller && curl -fsSL -o /usr/share/licenses/unpoller/LICENSE https://raw.githubusercontent.com/unpoller/unpoller/v${VERSION}/LICENSE` (file name at the tag is UNVERIFIED; confirm in step 2 of the build).
5. Seed-default config copied into the image: `COPY --chmod=0644 etc/ /etc/` (provides `/etc/unpoller/up.conf`).
6. `ENV` for any writable path: none needed. Set `HOME=/tmp` only if the binary writes there (UNVERIFIED).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9130
VOLUME /config
```

`COPY --chmod=0755 . /` is required by the Dockerfile rules and must stay. Note that `COPY . /` also copies `start.sh`, which is in the allow-list.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "unpoller"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=unpoller/unpoller versioning=semver
  default = "5.10.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/unpoller/unpoller"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `cd apps/unpoller && docker buildx bake --print`. The Dockerfile reads the same value through `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/unpoller/unpoller"
ports:
  - port: 9130
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Port 9130 is confirmed by the upstream example config (section 1).
- `env`: list only the variables confirmed from upstream docs (none fetched). Do not invent names. A `UniFi controller URL, user and password` will be required by the app; if these come from env, they need entries with `required: true` and a `start.sh` mapping, and they cannot be given a default.
- `dependencies: []`: no ContainerForge app is needed. The UniFi controller is an external service (draft caveat).

## 7. start.sh

Idempotent behaviour, no writes to `/app`:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
if [ ! -s /config/up.conf ]; then
    cp /etc/unpoller/up.conf /config/up.conf
fi

exec /app/unpoller/unpoller --config /config/up.conf
```

- `--config` is UNVERIFIED. If upstream reads config only from env or a fixed path, drop the seeding and the flag, and remove the `etc/` copy from the Dockerfile.
- Env-to-config mapping (once the variables are confirmed): write them into the config only if the app does not read them directly.
- Bind: metrics server must listen on `0.0.0.0` (the default bind is UNVERIFIED; check the config `bind` or `listen` key and set it to all interfaces).
- Final `exec` keeps PID 1 signal handling.

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml` (forgetool URL).
- `tcp` probe on 9130 with a `timeoutSeconds` value taken from a prebuilt-binary sibling (`apps/adguardhome-sync`).
- `filePaths`: `/app/unpoller/unpoller`, `/usr/share/licenses/unpoller/LICENSE`, `/etc/unpoller/up.conf` (if shipped).
- No env vars are passed, so unpoller will start without a controller. Expect it to keep running and retry, or to exit. If it exits without a controller, it fails the run-without-env pass criterion. The fix is to make the process run without a controller only if upstream allows it (UNVERIFIED). Do not weaken the test: if upstream requires a controller, add the code path to `filePaths` and test it manually per the protocol.

## 9. Rootless and read-only-rootfs adaptations

- User: `USER apps` in the final stage. Upstream distroless has no user declaration (runs as root by default in distroless `static` is UNVERIFIED); the ContainerForge `apps` user is the target.
- Read-only rootfs: the binary only reads `/config` and `/etc/unpoller`, writes nothing under `/app`. Confirm with `--read-only --tmpfs /tmp` (protocol step 3).
- Writable paths: `/config` (persistent config), `/tmp` (scratch). No caches.
- Upstream security expectations from the draft (non-root yes, read-only rootfs yes, privileged no) match this plan. No extra persistence (draft: none).

## 10. Risks, caveats and open questions

- The draft's version (v5.9.6) is outdated: upstream latest is v5.10.1. The `copy-from` image tag `ghcr.io/unpoller/unpoller:v5.9.6` is also outdated; this plan does not use it.
- Checksum: verified against the release's own checksum file. Pinning SHA-256 per arch is stricter (open question).
- Env vars, the metrics port and the `--config` flag are UNVERIFIED (upstream docs were not fetched).
- The UniFi controller must be reachable, and a local read-only account is needed for polling (draft, inferred). Without a controller the app cannot be fully tested.
- License file name at the tag is UNVERIFIED.
- Blockers: none found. No musl issue (the binary is a Go release tarball; confirm that it is static or glibc-compatible by running it on the base).

## 11. Build and test steps

From `apps/unpoller/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Confirm the flags: `docker run --rm unpoller:5.10.1 /app/unpoller/unpoller --help`
4. Run with an empty `/config`:
   `docker run --rm -d --name unpoller-probe --read-only --tmpfs /tmp -v unpoller-probe-config:/config unpoller:5.10.1`
   `docker logs -f unpoller-probe`
   Expected readiness: process still running and a log line that the metrics server is listening on 9130 (exact text UNVERIFIED). No fatal errors.
5. Cleanup: `docker rm -f unpoller-probe; docker volume rm unpoller-probe-config`
6. `forgetool containers test --image unpoller:5.10.1 --config ./apps/unpoller/container-test.yaml`
7. arm64 is not built locally unless the amd64 build fails for an arm64-specific reason (protocol).

## 12. PR checklist

- Branch `feat/add-unpoller`, commit `feat(unpoller): add new container`, PR title matches.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what is untested: the arm64 build, a live UniFi controller, and any path that needs a controller.
- Note the draft's outdated version (v5.9.6) and that the plan uses v5.10.1.
