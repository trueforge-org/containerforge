# clusterissuer — implementation plan
> Source: ./draft.md · Target: apps/clusterissuer/ · Difficulty: easy (but see the recommendation in section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| What the "app" is | The TrueCharts `clusterissuer` chart (cert-manager ClusterIssuer helper, `description: Certificate management for Kubernetes`). Its `values.yaml` sets `image.repository: hello-world`, `tag: latest@sha256:1e4c05b8...`, and `workload.main.enabled: false`, `containers.main.enabled: false`, `service.main.enabled: false`. The image is never run by the chart; it only satisfies the chart's required `image` value. |
| Image content | `docker-library/hello-world`: `FROM scratch`, `COPY hello /`, `CMD ["/hello"]`. It prints `Hello from Docker!` and exits. |
| Version | No release tags in `docker-library/hello-world` (`git ls-remote --tags` is empty). HEAD is commit `522bcd2faf422c60b9d20e64d7cd6d56600aec97`, the same commit the draft links. |
| Renovate | `datasource=git-refs depName=https://github.com/docker-library/hello-world currentValue=master` with the commit SHA as `VERSION`. `currentValue=master` (the repo default branch) follows the `apps/tvheadend/docker-bake.hcl` pattern. A Renovate bump will not update the two hash ARGs, so such a PR fails to build until they are updated. |
| License | `MIT` (the repo `LICENSE` starts "Copyright (c) 2014 Docker, Inc. Permission is hereby granted..."). The `hello` binary is built from `hello.c` in the same repo. |
| Source (`SOURCE`, `upstream_env_url`) | https://github.com/docker-library/hello-world |
| amd64 download | https://github.com/docker-library/hello-world/raw/522bcd2faf422c60b9d20e64d7cd6d56600aec97/amd64/hello (HTTP 200, static ELF x86-64, sha256 `f4061a47648b7d8fffda5253cebff1d179df9457cfc7e539ad3e3bdc6872c341`) |
| arm64 download | https://github.com/docker-library/hello-world/raw/522bcd2faf422c60b9d20e64d7cd6d56600aec97/arm64v8/hello (static ELF aarch64, sha256 `aadcf773dad62f26c8fc7f2e4a0298aaca63ec90ec0e2e467191479baa20baec`). Note the directory is `arm64v8`, not `arm64`. |
| Checksum source | Upstream publishes none. The hashes above were computed locally on 2026-11-23 from the pinned commit URLs; pin them as Dockerfile `ARG`s next to the commit. |
| Env vars / ports / config | None. No ports, no config files. |
| Upstream Dockerfile | Reviewed: https://github.com/docker-library/hello-world/blob/master/amd64/Dockerfile |

## 2. Target layout

```
apps/clusterissuer/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/`, `health/`: nothing to seed.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses it as a `FROM` base).
- Closest sibling for shape: `apps/steamcmd` / `apps/xvfb` (tiny ubuntu-based images with only a `runners` or `filePaths` test). Port-less siblings use `settings.yaml` with `ports: []`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

The binary is static and needs no runtime. Using ubuntu (not `scratch`) keeps the repo's `start.sh` entrypoint model, `apps` user and `COPY --chmod=0755 . /` working. `curl` is in the base.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION` (commit SHA), `ARG TARGETARCH`.
2. `ARG HELLO_SHA256_AMD64=f4061a47648b7d8fffda5253cebff1d179df9457cfc7e539ad3e3bdc6872c341` and `ARG HELLO_SHA256_ARM64=aadcf773dad62f26c8fc7f2e4a0298aaca63ec90ec0e2e467191479baa20baec` (must be bumped together with `VERSION`; a mismatch fails the build, which is the intended safety net).
3. `USER root` for the install only.
4. `RUN set -eux`: map `TARGETARCH` (`amd64` -> dir `amd64`, hash `HELLO_SHA256_AMD64`; `arm64` -> dir `arm64v8`, hash `HELLO_SHA256_ARM64`); `curl -fsSLo /app/hello "https://github.com/docker-library/hello-world/raw/${VERSION}/${dir}/hello"`; `echo "${hash}  /app/hello" | sha256sum -c -`; `chmod 0755 /app/hello`; `chown -R apps:apps /app`.
5. Licence: `mkdir -p /usr/share/licenses/clusterissuer && curl -fsSLo /usr/share/licenses/clusterissuer/LICENSE "https://raw.githubusercontent.com/docker-library/hello-world/${VERSION}/LICENSE"`.
6. `COPY --chmod=0755 . /`
7. No `EXPOSE` (no ports). `VOLUME /config` for consistency with siblings.
8. Final `USER apps`.

No apt packages, so nothing to pin. The image contains exactly the commit named in `VERSION`.

## 5. docker-bake.hcl

- `APP` = `clusterissuer`
- `VERSION`:
  ```hcl
  // renovate: datasource=git-refs depName=https://github.com/docker-library/hello-world currentValue=master
  default = "522bcd2faf422c60b9d20e64d7cd6d56600aec97"
  ```
  (same pattern as `apps/tvheadend`, see section 1; the image tag will be the 40-char SHA, which is ugly but honest. If maintainers prefer, use the short SHA and `git-refs` with `versioning=loose`.)
- `LICENSE` = `MIT`
- `SOURCE` = `https://github.com/docker-library/hello-world`
- Four standard targets plus `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`; `image-all` = `linux/amd64`, `linux/arm64`.
- Validate: `cd apps/clusterissuer && docker buildx bake --print`.

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

No `dependencies:` entry. The chart's real dependency is the cert-manager operator (`operator.cert-manager`), which is a Kubernetes operator and not a ContainerForge app (`apps/` has no cert-manager).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

/app/hello
echo "clusterissuer is a placeholder image; it does nothing. Idling."
exec sleep infinity
```

- Prints the upstream message once, then stays alive so the run/log check in the build protocol can pass and orchestrators do not restart-loop.
- No files are written anywhere; `/config` can be empty; idempotent.
- No network listener (no ports declared).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

runners:
- entrypoint: /app/hello
  expectedOutput: Hello from Docker!
filePaths:
- /app/hello
- /start.sh
- /usr/share/licenses/clusterissuer/LICENSE
```

No `tcp`/`http` probe because `settings.yaml` lists no ports. Default `timeoutSeconds` is enough.

## 9. Rootless and read-only-rootfs adaptations

- Upstream write paths: none (the binary only writes to stdout). Nothing to remap.
- Draft security expectations: confidence low; the chart renders no workload at all. Our image runs as UID 568 (`apps`), `readOnlyRootFilesystem: true`, not privileged, no persistence. This is a superset of any reasonable chart setting.

## 10. Risks, caveats and open questions

- **Recommendation: reconsider porting at all.** The chart's `workload.main.enabled`, container, probes and service are all `false`, so the image is never pulled for execution. The draft itself notes the name mismatch (cert-manager chart, hello-world image). A ContainerForge image for this adds maintenance (commit bumps plus hash bumps) for no runtime value. Ask the maintainers whether to skip this draft or to let the chart use `ghcr.io/trueforge-org/whoami` or similar existing placeholder instead.
- If it is ported anyway, the image is a placeholder, not a certificate manager.
- Renovate bumps follow every `master` commit, including ones that do not change the binaries (section 1).
- Hash ARGs must be updated with each `VERSION` bump.
- No blockers technically: static binaries exist for amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/clusterissuer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create clusterissuer-probe-config
docker run --rm -d --name clusterissuer-probe --read-only --tmpfs /tmp \
  -v clusterissuer-probe-config:/config clusterissuer:522bcd2faf422c60b9d20e64d7cd6d56600aec97
docker logs clusterissuer-probe        # expect "Hello from Docker!" then the idle line; container stays running
docker rm -f clusterissuer-probe; docker volume rm clusterissuer-probe-config
forgetool containers test --image clusterissuer:522bcd2faf422c60b9d20e64d7cd6d56600aec97 --config ./apps/clusterissuer/container-test.yaml
```

The readiness signal is the idle line plus a still-running container (no port to probe).

## 12. PR checklist

- Branch `feat/add-clusterissuer`, commit and PR title `feat(clusterissuer): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, only check boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section, and mention the placeholder nature.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested: arm64 build and run, renovate handling of the commit-SHA `VERSION`, behaviour inside the TrueCharts chart.
- `docker buildx bake --print` before commit; changes only under `apps/clusterissuer/`.
