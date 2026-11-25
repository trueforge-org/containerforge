# sourcegraph — implementation plan
> Source: ./draft.md · Target: apps/sourcegraph/ · Difficulty: very-hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart `appVersion` and pinned tag `6.12.5040` (pushed 2026-02-10). Source: https://hub.docker.com/v2/repositories/sourcegraph/server/tags/6.12.5040 and https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/Chart.yaml |
| Latest stable upstream | UNVERIFIED: the tag list was not sorted and the repository holds 13371 tags. |
| Digest (chart pin) | `sha256:57a5802dfb3fbe368a4bf720ef3dc854286344267ce6e2bac80072e51810fee7`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/values.yaml |
| Renovate | UNVERIFIED: no datasource can be confirmed. Only Docker Hub `sourcegraph/server` is known. |
| License | UNVERIFIED: the GitHub API was rate-limited. The draft says the code is no longer open source. |
| Source URL | https://github.com/sourcegraph/sourcegraph (the draft says it is no longer open source; the repo was not read) |
| Architectures | amd64 only. The tag manifest lists one amd64 image. Source: https://hub.docker.com/v2/repositories/sourcegraph/server/tags/6.12.5040 |
| Download | None. No standalone binary is published. |
| Checksum source | Not applicable: no binary download. |
| Upstream Dockerfile reviewed | None public: draft says so, not confirmed on a fetched page. UNVERIFIED. |
| Ports (chart) | 7080/http (main), 2633/tcp (admin console), 3370/tcp (grafana). Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/values.yaml. Draft's 7443 and 3178 are not in the chart: UNVERIFIED. |
| Data paths (chart) | `/var/opt/sourcegraph` (application data) and `/etc/sourcegraph` (config). Same source. |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. Same source. |
| Env vars | UNVERIFIED: no env list was fetched. The docs page returned marketing HTML only (https://sourcegraph.com/docs). |
| Dependencies | The draft and chart describe a multi-service monolith (frontend, gitserver, searcher, Postgres, Redis). UNVERIFIED for the image internals. |

## 2. Target layout

Not applicable for now: no buildable layout exists until the blockers in section 10 are resolved. If a design is found, the layout would be the usual `apps/sourcegraph/` set: `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `root/`. No `DOWNSTREAM_CHANGES.md`, because nothing would use it as a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` would be the base the draft names, because ContainerForge runtime images are built on it. The upstream image (`docker.io/sourcegraph/server:6.12.5040`) is the only artifact, and its base OS is UNVERIFIED. Closest sibling: none found in `apps/` for a multi-service monolith.

## 4. Dockerfile

Not applicable as a standard build. The only route the facts support is a repackaging of the published image, which does not fit the ContainerForge model:

1. `FROM` the upstream image would bring in a full multi-service runtime that is not built from source here. The house pattern is `FROM ghcr.io/trueforge-org/ubuntu` plus `COPY --from=` for binaries, and no binaries are published separately.
2. Copying out the Sourcegraph binaries with `COPY --from=sourcegraph/server:6.12.5040` would need their runtime libraries and layout, which are UNVERIFIED.

If this is ever attempted, the Dockerfile must still end with `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, and must keep `ARG VERSION` equal to the bake `VERSION` (`6.12.5040`).

## 5. docker-bake.hcl

Not applicable until section 4 has a feasible route. When it does, the values would be:

- `APP` = `sourcegraph`
- `VERSION` = `6.12.5040`, with `// renovate: datasource=docker depName=sourcegraph/server versioning=loose` (versioning to be confirmed, UNVERIFIED)
- `LICENSE` = UNVERIFIED (not confirmed on a fetched page)
- `SOURCE` = `https://github.com/sourcegraph/sourcegraph`

The four standard targets and the `default` group are copied from `apps/steamcmd/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Draft values only, to be confirmed before any port:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sourcegraph/sourcegraph"
ports:
  - port: 7080
    protocol: http
    required: true
  - port: 2633
    protocol: tcp
    required: false
  - port: 3370
    protocol: tcp
    required: false
volumes:
  - path: /config
    required: true
```

Env list is empty because no env var is verified (UNVERIFIED). `/var/opt/sourcegraph` and `/etc/sourcegraph` from the chart would need remapping to `/config`, which is an open decision (section 9). No dependency entry is added: the Postgres and Redis dependencies are UNVERIFIED for the image.

## 7. start.sh

Not applicable: no start script is planned until the upstream entrypoint and env vars are confirmed. Its requirements when written: idempotent, seeds `/config` only when missing, writes nothing to `/app`, caches in `/tmp`, binds `0.0.0.0`, and ends with `exec` of the final process.

## 8. container-test.yaml

Draft probes, to be confirmed:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
tcp:
- port: '7080'
- port: '2633'
- port: '3370'
http:
- port: '7080'
  path: /
```

Every port in `settings.yaml` needs a probe. `timeoutSeconds` is a guess; the chart does not show a startup window, so the value is UNVERIFIED. If the server needs Postgres and Redis to answer `/`, the database-dependent exception in the protocol applies only if all three of its criteria hold, which is UNVERIFIED.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/opt/sourcegraph` (chart PVC) | UNVERIFIED: the image's own use is not confirmed. Candidate remap: `/config/var` with a symlink or environment override, to be checked. |
| `/etc/sourcegraph` (chart PVC) | UNVERIFIED. Candidate remap: `/config/etc` with the same caveat. |

Draft expectations reconciled: the chart runs as UID 0 and the image is not built for rootless use; `readOnlyRootFilesystem: false` in the chart means nothing has been tested with `--read-only`. The target is `--read-only --tmpfs /tmp` with an empty `/config`, which is unproven for this image.

## 10. Risks, caveats and open questions

- Blocker: no public Dockerfile or source to rebuild. The image can only be re-published as-is, which does not match the ContainerForge model.
- Blocker: amd64 only. arm64 hosts cannot run it.
- Blocker: a multi-service monolith with external Postgres and Redis (draft; UNVERIFIED). A single container may not start alone.
- Blocker: the chart runs as root and the image writes under `/var/opt` and `/etc`. Rootless compatibility is unknown.
- Caveat: the first start needs web-UI setup (admin account, licence, site config) (draft; UNVERIFIED).
- Caveat: `/config` is not what the image uses, so existing chart users would have to move data.
- Open question: is there a sanctioned way to run it? If not, leave this app as a `skipped` draft.

Recommendation: do not start a port. Revisit when a feasible route (a buildable source, or a published binary per architecture) exists.

## 11. Build and test steps

Not applicable until the blockers are resolved. For reference, once a route exists, the protocol commands are:

```sh
cd apps/sourcegraph
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name sourcegraph-probe --read-only --tmpfs /tmp \
  -v sourcegraph-probe-config:/config sourcegraph:6.12.5040
docker logs -f sourcegraph-probe
forgetool containers test --image sourcegraph:6.12.5040 --config ./apps/sourcegraph/container-test.yaml
docker rm -f sourcegraph-probe; docker volume rm sourcegraph-probe-config
```

Readiness signal: UNVERIFIED (no startup log was fetched).

## 12. PR checklist

- Branch `feat/add-sourcegraph`, commit and PR title `feat(sourcegraph): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Untested to state honestly: everything, since no build was run and no startup was observed.
- Check `docker buildx bake --print` passes and bake `VERSION` equals the Dockerfile `ARG VERSION` before any PR.
