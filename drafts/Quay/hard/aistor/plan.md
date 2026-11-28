# aistor — implementation plan
> Source: ./draft.md · Target: apps/aistor/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `RELEASE.2026-09-19T17-05-25Z` (chart `appVersion` 2026.09.19; chart `aistor` 2.0.0). Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/incubator/aistor/values.yaml and Chart.yaml. Same tag as the draft. |
| Container used by chart | `quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z@sha256:107cf2014a9583c74c11e3cdbd6903d89c2244355886b89ce532f4ecae9c23f3` (matches the draft). |
| Renovate | UNVERIFIED: no GitHub releases or git tags were found for the vendor. The version is a `RELEASE.<timestamp>` string from the `dl.min.io` path. Use a custom regex manager against the download URL, or a `docker` datasource on `quay.io/minio/aistor/minio` (UNVERIFIED that the tag list there is usable; check at build time). |
| License | UNVERIFIED: proprietary MinIO AIStor. The fetched pages (docs.min.io/aistor, min.io/product/aistor) show no open-source license. The chart says a free license key is available from https://www.min.io/pricing. The SPDX value for `LICENSE` in bake must be confirmed by the user before merge; do not guess it. |
| Source URL | https://min.io/product/aistor (product page). Docs: https://docs.min.io/aistor/ |
| Download amd64 | https://dl.min.io/aistor/minio/release/linux-amd64/minio (HTTP 200, `application/octet-stream`, 278278306 bytes, last-modified 2026-09-20). |
| Download arm64 | https://dl.min.io/aistor/minio/release/linux-arm64/minio (HTTP 200, 256114850 bytes, last-modified 2026-09-20). |
| Checksum source | Vendor-published SHA-256 per arch, verified in the fetch: https://dl.min.io/aistor/minio/release/linux-amd64/minio.sha256sum = `bc7c22c306f18af89726c44200f4f0bb35c93cab6a67ce5cb8ba76b322f18aca  minio.RELEASE.2026-09-19T17-05-25Z`; arm64 https://dl.min.io/aistor/minio/release/linux-arm64/minio.sha256sum = `e2c132738afa72f2c2b368d783c81460ad8f79aa00b190162d7a3c6c12e99766  minio.RELEASE.2026-09-19T17-05-25Z`. Re-download and check each during the build; the downloaded file name differs from the sum file name, so verify the hash only. |
| Upstream Dockerfile | None public (draft: `-`). The image is built by the vendor; only the binary is fetched. |
| Entry command | Chart: `minio server --certs-dir /etc/minio/certs` (values.yaml). |
| Env vars used by chart | `MINIO_ROOT_USER` (chart default `minio`), `MINIO_ROOT_PASSWORD` (secret, chart default must be changed), `MINIO_VOLUMES=/data`, `MINIO_CONSOLE_ADDRESS=":9001"`, `MINIO_BROWSER_REDIRECT_URL` (optional), `MINIO_LICENSE=/minio.license`. Source: chart values.yaml. |
| Ports | 9000/http (S3 API), 9001/http (WebUI console). Source: chart `service.api` and `service.main`. |
| Health | `GET /minio/health/live` on 9000; readiness `GET /minio/health/ready` when a licence is set (chart values). |
| License behaviour | Chart: "Without a valid license, AIStor starts in offline mode and blocks S3 operations." So the process starts without a licence; the S3 API is blocked. Source: values.yaml comment. |
| Data path | Chart mounts `/data` (`MINIO_VOLUMES=/data`). The rules require `/config`, so this image uses `/config/data`. This differs from the chart. |
| TLS | Off by default (`minio.tls: false`). Certs dir `/etc/minio/certs` used only when TLS is enabled. |
| Dependencies | None. |

## 2. Target layout

- `apps/aistor/Dockerfile`
- `apps/aistor/docker-bake.hcl`
- `apps/aistor/settings.yaml`
- `apps/aistor/container-test.yaml`
- `apps/aistor/start.sh` (data dir seeding, env to flags, `exec`)

No `defaults/` or `etc/` are needed: no seeded config is shipped. `health/` only if the protocol needs a custom probe (not planned). No `root/`. No `DOWNSTREAM_CHANGES.md`: no downstream `FROM`.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the download stage and the final stage. The binary is a static-enough Go executable from the vendor; the ubuntu base is the ContainerForge default for vendor Linux binaries (`apps/adguardhome-sync` does the same with a release tarball).
- Closest sibling: `apps/adguardhome-sync` (download a per-arch release artifact into `/app`, pinned version, `TARGETARCH` mapping).
- Verify at build time whether the binary needs glibc beyond the ubuntu base (`ldd` on the file in the build stage). UNVERIFIED until the binary is run.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS download`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map `TARGETARCH` to the vendor path: `amd64` to `linux-amd64`, `arm64` to `linux-arm64`. Fail the build for any other value.
3. `curl -fL -o /tmp/minio "https://dl.min.io/aistor/minio/release/${ARCHDIR}/minio"`. UNVERIFIED: this URL does not contain `${VERSION}`; it serves whatever release is current, so the build is not reproducible against the pinned `RELEASE.2026-09-19T17-05-25Z`. Check for a versioned path (e.g. `minio.<VERSION>`) or compare the checksum file name to `VERSION` and fail on mismatch.
4. Verify: `curl -fL -o /tmp/minio.sha256sum "https://dl.min.io/aistor/minio/release/${ARCHDIR}/minio.sha256sum"`, then compare the first field to `sha256sum /tmp/minio`. Use an explicit comparison, not `sha256sum -c` (the file name in the sum file differs). Fail the build on mismatch.
5. Install into the final stage: `mkdir -p /app/aistor && install -m 0755 /tmp/minio /app/aistor/minio`. Run `chown -R apps:apps /app/aistor`.
6. License: place the vendor licence text (from the vendor page or the product terms) at `/usr/share/licenses/aistor/LICENSE`. UNVERIFIED: no licence file was fetched; the user must supply it or confirm the terms (section 10).
7. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root`, then `COPY --from=download /app/aistor /app/aistor`, `COPY --from=download /usr/share/licenses/aistor /usr/share/licenses/aistor`, and `chown -R apps:apps /app/aistor`.
8. `ENV HOME=/config MINIO_VOLUMES=/config/data MINIO_CONSOLE_ADDRESS=:9001 MINIO_BROWSER_REDIRECT_URL= MINIO_ROOT_USER=minio`. Do not set `MINIO_ROOT_PASSWORD` in the image.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9000 9001
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "aistor"
}

variable "VERSION" {
  // renovate: datasource=docker depName=quay.io/minio/aistor/minio versioning=loose
  default = "RELEASE.2026-09-19T17-05-25Z"
}

variable "LICENSE" {
  // UNVERIFIED: proprietary vendor licence; confirm the value before merge.
  default = "LicenseRef-MinIO-AIStor"
}

variable "SOURCE" {
  default = "https://min.io/product/aistor"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

- The renovate line above is a proposal; the `docker` datasource on the Quay repo is UNVERIFIED for this tag format and must be tested by renovate before merge. Alternative: a `customManagers` regex in renovate config (a repo change, out of scope unless the user agrees).
- `LICENSE` value is a placeholder until confirmed (section 10). Do not merge with an unconfirmed value.
- Validate with `docker buildx bake --print` in `apps/aistor`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://min.io/product/aistor"
ports:
  - port: 9000
    protocol: tcp
    required: true
  - port: 9001
    protocol: tcp
    required: false
env:
  - name: MINIO_ROOT_USER
    default: "minio"
    required: false
  - name: MINIO_ROOT_PASSWORD
    default: ""
    required: true
  - name: MINIO_LICENSE
    default: ""
    required: false
  - name: MINIO_BROWSER_REDIRECT_URL
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `MINIO_ROOT_PASSWORD` is `required: true` with an empty default, which the rules do not allow unless `start.sh` generates or handles it. Handle it in `start.sh` (section 7): generate a random value into `/tmp` only if unset, print a warning, or fail clearly. Decide with the user; the default choice is to fail clearly, not to use a fixed password.
- `MINIO_LICENSE` is read as the licence content by the vendor; the chart mounts a file at `/minio.license`. UNVERIFIED which form AIStor accepts. Keep the variable and document it as the chart does, after confirmation.
- Ports 9000 and 9001 both need a probe in `container-test.yaml`.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

if [[ -z "${MINIO_ROOT_PASSWORD:-}" ]]; then
  echo "MINIO_ROOT_PASSWORD is not set; refusing to start with no root password" >&2
  exit 1
fi

args=(
  server
  --address ":9000"
  --console-address ":${MINIO_CONSOLE_ADDRESS##*:}"
)
if [[ -n "${MINIO_LICENSE:-}" ]]; then
  export MINIO_LICENSE
fi

cd /app/aistor
exec /app/aistor/minio "${args[@]}" /config/data
```

- Seeds only the data directory, and only when missing. No writes to `/app`.
- Applies the root password on every start from the environment, so a change takes effect (per the rules for database passwords). It is not written to a file.
- `exec` the server so it receives signals as PID 1.
- The health probe paths are served by the server itself; no extra script is needed.
- Test runs with no env vars: with the `fail clearly` choice above, `start.sh` exits 1 and the container test fails. The test must set `MINIO_ROOT_PASSWORD` through `container-test.yaml` env if the schema allows it, or the start path without password is reviewed as in section 8. UNVERIFIED that the schema accepts env. See section 8.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9000'
- port: '9001'
http:
- port: '9000'
  path: /minio/health/live
- port: '9001'
  path: /
filePaths:
- /app/aistor/minio
- /usr/share/licenses/aistor/LICENSE
```

- Port 9000 and 9001 both have a probe (coverage minimum).
- The protocol test runs with no env vars. Because `start.sh` requires `MINIO_ROOT_PASSWORD`, the test as written fails unless the forgetool schema allows passing env to a test, or the team agrees a narrowed test for the required-env path. Do not weaken it. Put the required-env code path in `filePaths` only as a file check if the schema supports it, and run the full start with the password yourself per section 11.
- Offline mode: without a licence the server starts and health live answers, so `/minio/health/live` is the probe to use. Readiness needs a licence (chart: `/minio/health/ready` only when a licence is set); do not probe readiness in the test.
- `timeoutSeconds: 120` is a guess based on the chart startup probes; confirm against measured startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (chart PVC, `MINIO_VOLUMES=/data`) | `/config/data` (`MINIO_VOLUMES=/config/data`, created by `start.sh`). Existing chart users must move their data from `/data` to `/config/data`. |
| `/etc/minio/certs` (chart PVC, only when TLS is on) | Not mounted by default. If the user enables TLS they must mount certs read-only at `/etc/minio/certs`; no write is needed. |
| `/minio.license` (chart secret) | Not part of `/config`. Pass the licence through `MINIO_LICENSE` (UNVERIFIED form, section 10). Do not write it to disk from `start.sh`. |
| `HOME` | `/config` (server writes its own state under data dir; confirm it does not write to `$HOME`). |

- `readOnlyRootFilesystem`: the image writes only to `/config` and `/tmp`, so it is compatible with `--read-only --tmpfs /tmp`. UNVERIFIED until the probe run.
- Chart security expectations reconciled: runs as `apps` (568) via `USER apps` (chart default 568 matches); not privileged (chart default false); draft's read-only-rootfs "possible" is now expected to pass. The chart's extra `/data` PVC and `/etc/minio/certs` PVC are not reproduced as writable paths.

## 10. Risks, caveats and open questions

- Licence and redistribution (blocker for merge): the vendor binary is proprietary. Confirm with the user whether ContainerForge may publish an image that contains it, and which `LICENSE` value to use. Do not merge until confirmed.
- Licence key: without a licence the server runs in offline mode and blocks S3 (chart comment). The image must document that a licence is needed for real use; it is manual setup.
- Password handling: `start.sh` fails when `MINIO_ROOT_PASSWORD` is unset, so the no-env test fails. This is a conflict between the rules (test with no env, image must start without env) and the vendor requirement. Decide with the user before writing `container-test.yaml`.
- `MINIO_LICENSE` form: the chart mounts a file at `/minio.license` and sets `MINIO_LICENSE=/minio.license`. Whether AIStor reads a path or the key content is UNVERIFIED. Test it.
- Data migration: chart uses `/data`; this image uses `/config/data`. Document for chart users.
- Renovate: the `docker` datasource and tag format for `quay.io/minio/aistor/minio` are UNVERIFIED.
- Production: erasure coding needs several drives or nodes; a single drive is for testing only (draft, inferred).
- Download reliability: `dl.min.io` returned HTTP 200 without an account during the fetch; redistribution is the open question, not access.
- arm64: `dl.min.io/.../linux-arm64/minio` exists (HTTP 200); arm64 run is not tested.

## 11. Build and test steps

```sh
cd apps/aistor
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name aistor-probe --read-only --tmpfs /tmp \
  -e MINIO_ROOT_PASSWORD='<long-test-password>' \
  -v aistor-probe-config:/config aistor:RELEASE.2026-09-19T17-05-25Z
docker logs -f aistor-probe
curl -fsS http://127.0.0.1:9000/minio/health/live   # run with -p 9000:9000 -p 9001:9001 to test
docker rm -f aistor-probe; docker volume rm aistor-probe-config
forgetool containers test --image aistor:RELEASE.2026-09-19T17-05-25Z --config ./apps/aistor/container-test.yaml
```

- The probe run sets `MINIO_ROOT_PASSWORD` by hand because the protocol's no-env run cannot start (section 8). Record that it was done.
- Expected readiness signal: MinIO banner and an offline-mode line when no licence is set. The exact text is UNVERIFIED; capture the first 100 lines on the first run.
- Check that a second start with the same `/config` volume keeps data (`/config/data` persists).
- Check the server does not write to `/app` (rootfs is read-only in the probe).
- arm64: only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-aistor`, commit `feat(aistor): add new container`, PR title `feat(aistor): add new container`, target `main`.
- Tell the user that a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- State in the PR that the licence and redistribution terms are unconfirmed, the licence value is a placeholder, the test uses a manual password, and the arm64 image and the readiness path with a licence are untested.
- `docker buildx bake --print` passes; `VERSION` in bake equals the Dockerfile `ARG VERSION`; no assertion weakened.
