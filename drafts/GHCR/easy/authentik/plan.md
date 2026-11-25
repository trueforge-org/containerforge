# authentik — implementation plan
> Source: ./draft.md · Target: apps/<app>/ (see section 2: one app per outpost image) · Difficulty: easy · Role: sidecar (outposts) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2026.8.6` (release tag `version/2026.8.6`), matching the draft tags. Note: GitHub `releases/latest` now returns `version/2026.8.7` (published 2026-11-25); decide whether to bump to 2026.8.7 and re-check asset names and sizes below. Source: https://api.github.com/repos/goauthentik/authentik/releases/latest |
| Renovate | `datasource=github-releases depName=goauthentik/authentik versioning=loose` (tag prefix `version/`; use `extractVersion` `^version/(?<version>.+)$` if the tag is kept literal). UNVERIFIED: exact renovate regex against the bake file; check a sibling with a prefixed tag. |
| License | Core is MIT (LICENSE: "Content outside of the above mentioned directories ... is available under the MIT license"). `enterprise/` is separately licensed, not in the outpost binaries. GitHub API reports `NOASSERTION`, so use `MIT` and note it. Source: https://api.github.com/repos/goauthentik/authentik/contents/LICENSE |
| Source URL | https://github.com/goauthentik/authentik |
| Download (ldap amd64) | https://github.com/goauthentik/authentik/releases/download/version/2026.8.6/authentik-outpost-ldap_linux_amd64 (29926815 bytes) |
| Download (ldap arm64) | https://github.com/goauthentik/authentik/releases/download/version/2026.8.6/authentik-outpost-ldap_linux_arm64 (27993882 bytes) |
| Download (radius amd64/arm64) | `authentik-outpost-radius_linux_amd64` (29340911 bytes) / `authentik-outpost-radius_linux_arm64` (27370020 bytes), same base URL |
| Download (proxy amd64/arm64) | `authentik-outpost-proxy-x86_64-unknown-linux-gnu` (18567000 bytes) / `authentik-outpost-proxy-aarch64-unknown-linux-gnu` (arm64 size UNVERIFIED), same base URL |
| Checksum source | No per-asset checksum file in the release. `metadata.json` exists (160 bytes) but its content is UNVERIFIED (not read). Plan: read it in the build step, and if it does not list sha256 values, pin the sha256 of each downloaded binary in the Dockerfile after one manual download (recorded in the PR). |
| Upstream Dockerfile reviewed | `lifecycle/container/ldap.Dockerfile` at 98ec4a7684fcb0cccfe78888a12df1df1ad938be: golang:1.27-trixie builder (`go build -o /go/ldap ./cmd/ldap`, CGO_ENABLED=1, GOFIPS140=latest), runtime `ghcr.io/goauthentik/fips-debian:trixie-slim-fips`, `COPY --from=builder /go/ldap /`, `EXPOSE 3389 6636 9300`, `USER 1000`, `ENTRYPOINT ["/ldap"]`, `HEALTHCHECK CMD ["/ldap","healthcheck"]`, `ENV TMPDIR=/dev/shm/`. proxy and radius Dockerfiles: UNVERIFIED (not fetched, 403). |
| Ports | ldap: 3389/tcp, 6636/tcp (LDAPS), 9300 (metrics, from EXPOSE). Radius: 1812/udp per draft (UNVERIFIED). Proxy: 9000/9443 per draft (UNVERIFIED). |
| Env vars (real) | UNVERIFIED: the outpost connection env (server URL, outpost token; `AUTHENTIK_HOST`, `AUTHENTIK_TOKEN` are the usual names) was not read from a fetched page. Do not add them to settings.yaml until confirmed from `internal/outpost` source. |
| Data paths | Stateless: no VOLUME in ldap.Dockerfile. `TMPDIR=/dev/shm/` is set upstream; we use `/tmp`. |

Draft rows checked: the chart's five rows are five images, not one application. The `k8s-sidecar` row already exists as `apps/k8s-sidecar` (version 2.14.3, same tag), so it is skipped. The `geoipupdate` row is a separate app (see section 10).

## 2. Target layout

The draft is one folder with five images. Plan: one ContainerForge app per image, each with the standard five files, since each has its own process and its own `VERSION`.

- `apps/authentik-ldap/` (first; the fully verified one): Dockerfile, docker-bake.hcl, settings.yaml, start.sh, container-test.yaml.
- `apps/authentik-proxy/`, `apps/authentik-radius/`: same files, after their upstream Dockerfiles are read (UNVERIFIED).
- `apps/geoipupdate/`: same files (see section 10 for its own blocker).
- `apps/k8s-sidecar/`: already exists, no work.
- No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (none of these is used as a `FROM` base; check with `grep -rn "authentik" apps/*/Dockerfile` before the PR).

The rest of this plan describes `apps/authentik-ldap/`. The same steps apply to the other outposts with their own binary name and ports.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (from the brief's base table). Fits because the outposts are self-contained release binaries and need only CA certificates and glibc. Closest sibling for a prebuilt-binary ubuntu app: `apps/adguardhome-sync` (prebuilt binary on ubuntu). Upstream's fips-debian base is not needed: the outpost does not require a FIPS base for our purposes, which is a choice to record in the PR (UNVERIFIED that the binary runs without FIPS-only glibc paths).

## 4. Dockerfile

1. Single stage on the ubuntu base (no compile; the binary is downloaded).
2. `ARG VERSION`, `ARG TARGETARCH`.
3. `USER root`, then `apt-get install -y --no-install-recommends ca-certificates curl` only if the base lacks them (check the base first; do not reinstall packages the base has). Pin apt versions if any are added and check them against `VERSION`.
4. Map arch: `amd64 -> linux_amd64`, `arm64 -> linux_arm64`.
5. Download `https://github.com/goauthentik/authentik/releases/download/version/${VERSION}/authentik-outpost-ldap_linux_${ARCH}` to `/tmp/ldap`, verify sha256 (pinned per arch as `ARG LDAP_SHA256_AMD64` / `ARG LDAP_SHA256_ARM64` or from `metadata.json`), `install -m 0755 /tmp/ldap /app/ldap`, then `rm -f /tmp/ldap`.
6. License: upstream LICENSE copied to `/usr/share/licenses/authentik-ldap/LICENSE` (fetch it with the tag, not the default branch).
7. `ENV TMPDIR=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3389 6636 9300
VOLUME /config
WORKDIR /app
```

`VERSION` in the Dockerfile must equal `docker-bake.hcl` (section 5). `ENTRYPOINT` is set by `start.sh` (`exec /app/ldap`), so the Dockerfile sets no `ENTRYPOINT`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "authentik-ldap"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=goauthentik/authentik versioning=loose
  default = "2026.8.6"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/goauthentik/authentik"
}
```

Then the four standard targets and the default group copied from `apps/k8s-sidecar/docker-bake.hcl`. The download URL uses the tag `version/${VERSION}`; the Dockerfile builds it from `VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/goauthentik/authentik"
ports:
  - port: 3389
    protocol: tcp
    required: false
  - port: 6636
    protocol: tcp
    required: false
  - port: 9300
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
dependencies: []   # the authentik server is external, not a ContainerForge app; UNVERIFIED which env the outpost needs
```

The outpost token and server URL are required at runtime (UNVERIFIED names; add them as `required: true` with no default only after confirming the names). `/config` is declared (Dockerfile `VOLUME /config`) but unused; the outpost is stateless.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export TMPDIR=/tmp

# Outpost config comes from env (names UNVERIFIED, see section 6).
exec /app/ldap
```

Idempotent, nothing to seed, no writes to `/app`. Binds to all interfaces only if the outpost's listen address defaults to localhost: UNVERIFIED, check the log for `0.0.0.0:3389` or `:3389` and the LDAP port from outside the container. `exec` for signal handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '3389'
- port: '6636'
- port: '9300'
filePaths:
- /app/ldap
- /usr/share/licenses/authentik-ldap/LICENSE
```

Risk: with no server URL and no token, the outpost may exit instead of listening. If it exits, the protocol says this is a real failure, not something to narrow away. Next step: confirm the outpost stays up without a server (log check). If it cannot, the app has a hard dependency and the database-dependent exception does not apply (it covers databases only), so the test must be redesigned with a stub server or the app is marked `unfixable` and the user is told. Do not remove the tcp probes.

Every port in `settings.yaml` has a probe (section 8 rule). The `tcp` probes run against the container itself.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `TMPDIR=/dev/shm/` | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |
| Runtime user `1000` | `apps` (USER apps) |
| Healthcheck `/ldap healthcheck` | Not added to the image. Prefer the tcp probe in container-test.yaml. Adding a HEALTHCHECK is optional and not required by the brief. |
| `/config` | Declared as `VOLUME` per repo rules but not written (no persistent state). Draft expectation "read-only friendly, no writable paths" is consistent with this. |

Chart security expectations (non-root, read-only rootfs, not privileged): consistent with this plan, except the chart's user value (UNVERIFIED in the chart; draft says 1000 for outposts). Use `apps`.

## 10. Risks, caveats and open questions

- Five images in one draft: plan splits into one app per image. Confirm this split with the user before creating four folders.
- Upstream proxy and radius Dockerfiles, and their ports and env, are UNVERIFIED (not fetched). Their plans stay open until read.
- `geoipupdate` (row 5): upstream Dockerfile at https://github.com/maxmind/geoipupdate/blob/v8.0.0/docker/Dockerfile was not fetched. Release tarballs confirmed: `geoipupdate_8.0.0_linux_amd64.tar.gz` and `geoipupdate_8.0.0_linux_arm64.tar.gz`, checksum file `geoipupdate_8.0.0_checksums.txt` (not read). License Apache-2.0 (GitHub API). It needs a MaxMind account ID and license key, and it writes the database into a path that must be `/config`: UNVERIFIED env names and default database path. Mark as blocked-on-facts.
- Renovate on a `version/` tag prefix: confirm the regex works (UNVERIFIED).
- Draft `releases/download/version%2F2026.8.6` URL encoding is wrong: the real tag is `version/2026.8.6` and the slash must not be encoded. Use the unencoded form in the Dockerfile.
- Upstream Dockerfile uses CGO_ENABLED=1 on a debian base. The release binary may need glibc symbols that the ubuntu 26.04 base does not provide. UNVERIFIED: not checked (no `ldd` or `readelf` run on the binary). Check in the build step before relying on it.
- No blockers for the ldap outpost on paper (amd64 and arm64 binaries present, stateless, no privilege).

## 11. Build and test steps

```sh
cd apps/authentik-ldap
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name authentik-ldap-probe --read-only --tmpfs /tmp \
  -v authentik-ldap-probe-config:/config authentik-ldap:2026.8.6
docker logs -f authentik-ldap-probe
forgetool containers test --image authentik-ldap:2026.8.6 --config ./apps/authentik-ldap/container-test.yaml
docker rm -f authentik-ldap-probe; docker volume rm authentik-ldap-probe-config
```

Readiness signal: the outpost logs its listen address for 3389 and stays running. Expected text is UNVERIFIED until a run captures it. Also run `--read-only` with an empty `/config` volume; the container must not write there.

## 12. PR checklist

- Branch `feat/add-authentik-ldap` (one branch per app), commit `feat(authentik-ldap): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- Say what was not tested: the outpost has not been run against a live authentik server, the proxy and radius apps are not written, and arm64 has not been run.
- Check for `FROM` users of the new app before the PR (none expected).
