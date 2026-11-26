# leaf2mqtt — implementation plan
> Source: ./draft.md · Target: apps/leaf2mqtt/ · Difficulty: medium (draft) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.6` (GitHub release, published 2022-04-17, name "Major Updates and API changes"). Matches the draft's chart image `ghcr.io/k8s-at-home/leaf2mqtt:v0.6`. |
| Upstream status | Repository is archived (`gh api repos/mitsumaui/leaf2mqtt`: `archived: true`). No maintenance; no later release. |
| Renovate | `datasource=github-releases depName=mitsumaui/leaf2mqtt versioning=loose` (UNVERIFIED: upstream renovate config not read; with an archived repo, renovate will never bump, which is expected). |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`). Repo ships `LICENSE`. |
| Source URL | https://github.com/mitsumaui/leaf2mqtt |
| Download | No release assets. Source tarball `https://github.com/mitsumaui/leaf2mqtt/archive/refs/tags/${VERSION}.tar.gz` (tag is `v0.6`). Compiled here. |
| Per-arch | `compile` on both (no prebuilt executable upstream). |
| Checksum source | None published. Plan: pin the tarball SHA-256 as a Dockerfile `ARG` computed once at implementation (UNVERIFIED value). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/mitsumaui/leaf2mqtt/v0.6/Dockerfile. Stage `build`: `FROM dart AS build` (`apt-get install git`, `WORKDIR /app`, `COPY pubspec.* ./`, `dart pub get`, `COPY . .`, `dart pub get --offline`, `dart compile exe src/leaf_2_mqtt.dart -o src/leaf_2_mqtt`). Final: `FROM scratch`, `COPY --from=build /runtime/ /`, `COPY --from=build /app/src/leaf_2_mqtt /app/bin/`, `CMD ["/app/bin/leaf_2_mqtt"]`. No USER, ENTRYPOINT, EXPOSE, VOLUME or ENV. |
| Dart SDK constraint | `pubspec.yaml` (v0.6): `environment: sdk: '>=2.10.0 <3.0.0'`. The project excludes Dart 3. This is the blocker in section 10. |
| Git dependencies | `pubspec.yaml`: `dartnissanconnectna` (gitlab.com/tobiaswkjeldsen), `dartnissanconnect` (gitlab.com/sensor-freak), `dartcarwings` (github.com/Tobiaswk). Fetched at build time via `git`. Resolution depends on `pubspec.lock` being present and those hosts being reachable. |
| Ports | None in upstream Dockerfile; draft says none (no web UI). Health only via logs (inferred). |
| Env vars and config path | UNVERIFIED: none in upstream Dockerfile. The draft says MQTT config is in `/config`; not confirmed in fetched files. The vehicle-service credentials and the config file format are UNVERIFIED (README/`src/` not read). |
| Dependencies | MQTT broker and vehicle-service account credentials (external, runtime). Not ContainerForge apps. |

## 2. Target layout

- `apps/leaf2mqtt/Dockerfile`
- `apps/leaf2mqtt/docker-bake.hcl`
- `apps/leaf2mqtt/settings.yaml`
- `apps/leaf2mqtt/container-test.yaml`
- `apps/leaf2mqtt/start.sh`

No `defaults/` (the operator supplies the config; nothing confirmed to seed). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

- Build stage and final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Upstream uses `FROM dart` (unpinned) and `FROM scratch`; scratch is replaced, because ContainerForge runs on ubuntu and needs `USER apps`, `/config` and `--read-only --tmpfs /tmp`.
- Closest sibling for a compiled-binary build stage: `apps/hishtory-server` (ubuntu `AS builder`, `COPY --from=builder`).
- Dart SDK in the build stage: not in any ContainerForge base. Must be installed in the builder from the official Dart archive with SHA-256 verification. Version: must satisfy `<3.0.0`, so a Dart 2.x SDK (UNVERIFIED which 2.x release builds v0.6 and whether it is still downloadable).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS builder`, `ARG VERSION`, `ARG TARGETARCH`, `ARG DART_SDK_VERSION` (Dart 2.x, UNVERIFIED value), `ARG DART_SDK_SHA256` (UNVERIFIED value), `ARG LEAF2MQTT_SHA256` (UNVERIFIED value), `USER root`.
2. `apt-get install -y --no-install-recommends git ca-certificates curl unzip` (check base first; `git` is needed by `dart pub get` for the three git dependencies).
3. Dart SDK: download `https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_SDK_VERSION}/sdk/dartsdk-linux-${TARGETARCH}-release.zip` (UNVERIFIED URL for 2.x; the Dart archive names architectures `x64` (amd64) and `arm64`; map `TARGETARCH` accordingly and check), verify with `sha256sum -c`, unzip to `/usr/local/dart`, `ENV PATH=/usr/local/dart/bin:$PATH`.
4. Source: `curl -fL -o /tmp/src.tar.gz https://github.com/mitsumaui/leaf2mqtt/archive/refs/tags/${VERSION}.tar.gz`, verify with `sha256sum -c`, extract to `/build/leaf2mqtt` with `--strip-components=1`.
5. In `/build/leaf2mqtt`: `dart pub get` (uses `pubspec.lock`), then `dart compile exe src/leaf_2_mqtt.dart -o /out/leaf_2_mqtt`. Env: `PUB_CACHE=/tmp/pub-cache`, `HOME=/tmp`.
6. Final stage `FROM <ubuntu>`, `USER root`:
   - `COPY --from=builder /out/leaf_2_mqtt /app/bin/leaf_2_mqtt`; `chown apps:apps` and `chmod 0755`.
   - Runtime libraries needed by an AOT Dart binary are UNVERIFIED. Test with `ldd` in the builder output; add packages only if missing.
   - License: `COPY --from=builder /build/leaf2mqtt/LICENSE /usr/share/licenses/leaf2mqtt/LICENSE`.
7. `ENV HOME=/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

VOLUME /config
```

No `EXPOSE`: the upstream exposes no port.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "leaf2mqtt"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mitsumaui/leaf2mqtt versioning=loose
  default = "v0.6"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/mitsumaui/leaf2mqtt"
}
```

The Dart SDK version ARG (if exposed as a bake variable) needs its own renovate annotation; Dart 2.x has no tracking release line, so keep it pinned with a comment. `group "default"`, `target "image"`, `image-local`, `image-all` copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mitsumaui/leaf2mqtt"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

No ports (upstream exposes none). Env: no upstream variable is confirmed; the config and credential variables are UNVERIFIED and must not be invented. `dependencies: []`: the MQTT broker is external.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /config
# UNVERIFIED: arguments/config path not confirmed upstream
exec /app/bin/leaf_2_mqtt
```

Idempotent, seeds nothing, no writes to `/app`. The config location and argument form are UNVERIFIED (the upstream `CMD` gives no arguments). Credentials must not be passed on the command line (process list); read them from the config file under `/config` or from env, per the upstream code (UNVERIFIED which).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/bin/leaf_2_mqtt
- /usr/share/licenses/leaf2mqtt/LICENSE
```

No `tcp` or `http` probes: no ports. Risk: with no MQTT broker and no vehicle credentials, the app may exit at startup. The protocol requires the container to stay running, and this app has no database dependency, so the DB-dependency narrowing does not apply. Resolve in the run step (section 11) before the test is committed. Coverage is file-only until upstream startup behaviour is confirmed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Pub cache, Dart home (build stage only) | `/tmp/pub-cache`, `HOME=/tmp` |
| Runtime writes | UNVERIFIED: none expected. Check logs on `--read-only`. |
| Config and state | `/config`. |

Upstream draft expectations: runs as root (`runAsUser 0`), no read-only rootfs, not privileged. This plan changes to `apps` and `--read-only`, which is the ContainerForge default; the chart's root setting is a deployment choice and must be reconciled in the chart's values, not in the image. Not privileged.

## 10. Risks, caveats and open questions

- Blocker: the pubspec constrains the SDK to `<3.0.0`. Current Dart 3 cannot resolve it, so the build needs a Dart 2.x SDK. The v0.6 build with a Dart 2 SDK is UNVERIFIED. If no reachable, checksummed Dart 2.x SDK exists for amd64 and arm64, the app cannot be built and the implementer must stop and report it, not patch the pubspec.
- Blocker: upstream is archived (2022). Git dependencies on gitlab.com and github.com may have moved or been removed, so `dart pub get` may fail at build time. Check before writing the Dockerfile.
- Upstream Dockerfile uses unpinned `FROM dart`. The Dart version for v0.6 is not documented (UNVERIFIED).
- Runtime behaviour: startup without a broker and credentials is UNVERIFIED. The app may exit, and that fails the test.
- No ports, so no health probe; health only via logs (inferred).
- Chart runs as root (draft). The image uses `apps`. The chart must be updated separately, not by the image.
- arm64: AOT output is per architecture; compile natively on buildx. Not validated.

Blockers: Dart 2.x SDK availability with SHA-256 for both architectures; archived git dependencies; startup without broker/credentials.

## 11. Build and test steps

```sh
cd apps/leaf2mqtt
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name leaf2mqtt-probe --read-only --tmpfs /tmp \
  -v leaf2mqtt-probe-config:/config leaf2mqtt:v0.6
docker logs -f leaf2mqtt-probe
forgetool containers test --image leaf2mqtt:v0.6 --config ./apps/leaf2mqtt/container-test.yaml
docker rm -f leaf2mqtt-probe; docker volume rm leaf2mqtt-probe-config
```

Expected readiness signal: UNVERIFIED (read from `src/` logging). The container must stay running with an empty `/config`.

## 12. PR checklist

- Branch `feat/add-leaf2mqtt`, commit and PR title `feat(leaf2mqtt): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the Dart 2.x build on both architectures, the git dependency resolution, the runtime against a real MQTT broker, the checksum values.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
