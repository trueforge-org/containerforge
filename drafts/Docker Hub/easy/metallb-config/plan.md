# metallb-config — implementation plan
> Source: ./draft.md · Target: apps/metallb-config/ (recommended: do not create it, see section 10) · Difficulty: easy · Role: main (placeholder, never run) · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| What the "app" is | The TrueCharts `metallb-config` chart renders MetalLB custom resources (`ipAddressPools`, `L2Advertisements`, BGP peers, communities; templates `_ipaddresspool.tpl`, `_l2advertisement.tpl`, `_bgpadvertisement.tpl`, `_peers.tpl`, `_community.tpl`). Its `values.yaml` sets `image.repository: hello-world`, `tag: latest@sha256:1e4c05b8...`, `workload.main.enabled: false`, `containers.main.enabled: false` and `service.main.enabled: false`. The image only satisfies the chart's required `image` value and is never run. |
| Image content | `docker-library/hello-world`: `FROM scratch`, `COPY hello /`, `CMD ["/hello"]`. It prints a message and exits. |
| Version | The upstream repo has no tags (`0` tags). HEAD is commit `522bcd2faf422c60b9d20e64d7cd6d56600aec97`, the same commit as the draft's Dockerfile link. |
| Renovate | `datasource=git-refs depName=https://github.com/docker-library/hello-world` with the commit SHA as `VERSION` (renovate behaviour UNVERIFIED). |
| License | `MIT` (`LICENSE`: "Copyright (c) 2014 Docker, Inc."). |
| Source (`SOURCE`) | https://github.com/docker-library/hello-world |
| amd64 download | `https://github.com/docker-library/hello-world/raw/522bcd2faf422c60b9d20e64d7cd6d56600aec97/amd64/hello`, sha256 `f4061a47648b7d8fffda5253cebff1d179df9457cfc7e539ad3e3bdc6872c341` (computed locally on 2026-11-23). |
| arm64 download | `.../522bcd2faf422c60b9d20e64d7cd6d56600aec97/arm64v8/hello` (directory is `arm64v8`), sha256 `aadcf773dad62f26c8fc7f2e4a0298aaca63ec90ec0e2e467191479baa20baec` (computed locally). |
| Checksum source | Upstream publishes none; the hashes above are pinned from the commit URLs. |
| Alternative from the draft | `apt:hello` (Ubuntu 26.04 has `hello 2.10-5build1`, Launchpad). Not used, because it is a different program and the draft's real artifact is the static `hello` binary. |
| Ports / env / config | None. |
| Upstream Dockerfile reviewed | https://github.com/docker-library/hello-world/blob/522bcd2faf422c60b9d20e64d7cd6d56600aec97/amd64/Dockerfile |
| Related | The draft's reason says "same placeholder hello-world image as clusterissuer". `drafts/Docker Hub/easy/clusterissuer/plan.md` plans the same image. `apps/scratch` already exists as a `FROM scratch` placeholder app. |

## 2. Target layout

If it is built anyway (see section 10 for the recommendation):

```
apps/metallb-config/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/`, `health/`: nothing to seed. No `root/`. No `DOWNSTREAM_CHANGES.md`.
- Closest sibling: `apps/scratch` (placeholder image) and the planned `clusterissuer`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

The binary is static, so it needs no runtime. Ubuntu (not `scratch`) keeps the `apps` user, the entrypoint and `COPY --chmod=0755 . /` working. `curl` is in the base.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION` (commit SHA); `ARG TARGETARCH`.
2. `ARG HELLO_SHA256_AMD64=f4061a47648b7d8fffda5253cebff1d179df9457cfc7e539ad3e3bdc6872c341` and `ARG HELLO_SHA256_ARM64=aadcf773dad62f26c8fc7f2e4a0298aaca63ec90ec0e2e467191479baa20baec` (bump with `VERSION`).
3. `USER root` for the install only.
4. `RUN set -eux`:
   - `case "${TARGETARCH}" in amd64) d=amd64; h="${HELLO_SHA256_AMD64}";; arm64) d=arm64v8; h="${HELLO_SHA256_ARM64}";; *) exit 1;; esac`
   - `curl -fsSLo /app/hello "https://github.com/docker-library/hello-world/raw/${VERSION}/${d}/hello"`
   - `echo "${h}  /app/hello" | sha256sum -c -`
   - `chmod 0755 /app/hello && chown -R apps:apps /app`
   - `mkdir -p /usr/share/licenses/metallb-config && curl -fsSLo /usr/share/licenses/metallb-config/LICENSE "https://raw.githubusercontent.com/docker-library/hello-world/${VERSION}/LICENSE"`
5. `COPY --chmod=0755 . /`
6. No `EXPOSE` (no ports). `VOLUME /config`.
7. Final `USER apps`.

No apt packages, so nothing to pin.

## 5. docker-bake.hcl

- `APP` = `metallb-config`
- `VERSION`:
  ```hcl
  // renovate: datasource=git-refs depName=https://github.com/docker-library/hello-world
  default = "522bcd2faf422c60b9d20e64d7cd6d56600aec97"
  ```
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/docker-library/hello-world`
- Four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`; `image-all` = amd64 + arm64.
- `cd apps/metallb-config && docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/docker-library/hello-world"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

No `dependencies:`. The chart's real dependency is the MetalLB operator (`operator.metallb`), which is a Kubernetes operator and not a ContainerForge app.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

/app/hello
echo "metallb-config is a placeholder image; it does nothing. Idling."
exec sleep infinity
```

Prints the upstream message once and stays alive so the run/log check can pass and nothing restart-loops. It writes no files, so an empty `/config` is fine and it is idempotent. There is no network listener.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

runners:
- entrypoint: /app/hello
  expectedOutput: Hello from Docker!
filePaths:
- /app/hello
- /start.sh
- /usr/share/licenses/metallb-config/LICENSE
```

No `tcp`/`http` probe because `settings.yaml` lists no ports. Default `timeoutSeconds`. No env vars needed.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: none (stdout only), so nothing to remap.
- Draft expectations (non-root 568, read-only rootfs, not privileged, no persistence) are already met. Confidence in the draft is low because the chart renders no workload at all.

## 10. Risks, caveats and open questions

- **Recommendation: do not port this as a separate app.** The chart disables its workload, container and service, so the image is never executed. A dedicated image only adds maintenance (commit and hash bumps) with no runtime value. Better options for the maintainers: point the chart at the existing `ghcr.io/trueforge-org/scratch` placeholder (an `apps/scratch` app exists and already has a tests file with the main runner disabled), or share one placeholder with `clusterissuer`.
- This is a placeholder, not MetalLB configuration. The real configuration is Kubernetes resources applied to a cluster, so there is nothing to run in a container (matches the draft's caveats).
- `git-refs` renovate behaviour is UNVERIFIED, and the SHA-pinned tag is long.
- The hash ARGs must be bumped together with `VERSION`.
- No technical blockers: static binaries exist for amd64 and arm64.

## 11. Build and test steps

Only if the app is built anyway:

```sh
cd apps/metallb-config
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create metallb-config-probe-config
docker run --rm -d --name metallb-config-probe --read-only --tmpfs /tmp \
  -v metallb-config-probe-config:/config metallb-config:522bcd2faf422c60b9d20e64d7cd6d56600aec97
docker logs metallb-config-probe   # expect the hello text and the idle line; container stays running
docker rm -f metallb-config-probe; docker volume rm metallb-config-probe-config
forgetool containers test --image metallb-config:522bcd2faf422c60b9d20e64d7cd6d56600aec97 --config ./apps/metallb-config/container-test.yaml
```

Readiness signal: the idle line plus a running container (there is no port to probe).

## 12. PR checklist

- Branch `feat/add-metallb-config` from `main`; commit and PR title `feat(metallb-config): add new container` (only if maintainers confirm the app is wanted).
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only boxes that apply; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows status).
- Untested so far: the image has not been built or run; the renovate datasource is unchecked; arm64 is not built; the hashes were computed from the pinned commit URLs, not from an upstream checksum file.
