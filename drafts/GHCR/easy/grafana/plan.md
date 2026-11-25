# grafana — implementation plan
> Source: ./draft.md · Target: apps/k8s-sidecar/ (existing app; no new apps/grafana/) · Difficulty: easy · Role: sidecar (sidecarImage) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | The chart's sidecar image is `ghcr.io/kiwigrid/k8s-sidecar:2.14.3`. Tag `2.14.3` published 2026-11-02 (https://api.github.com/repos/kiwigrid/k8s-sidecar/releases/tags/2.14.3). The sibling `apps/k8s-sidecar/docker-bake.hcl` already pins `VERSION = "2.14.3"`. |
| Renovate | Sibling already uses `// renovate: datasource=docker depName=ghcr.io/kiwigrid/k8s-sidecar`. Keep it. |
| License | MIT (GitHub API `license.spdx_id`, https://api.github.com/repos/kiwigrid/k8s-sidecar/license; also `org.opencontainers.image.licenses=MIT` in upstream Dockerfile). The sibling bake sets `LICENSE = AGPL-3.0-or-later`, which does not match the software. Fix in `apps/k8s-sidecar` if that app is changed. |
| Source URL | https://github.com/kiwigrid/k8s-sidecar |
| Download | No release assets. Source tarball `https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/2.14.3.tar.gz` (matches the sibling Dockerfile `RELEASE_URL`). |
| Checksum source | None published. Tag archive is content-addressed by tag only. UNVERIFIED: no checksum file. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/kiwigrid/k8s-sidecar/2.14.3/Dockerfile (fetched via `gh api`): `FROM python:3.14.10-alpine3.24@sha256:...` (musl), builder installs from `pyproject.toml` and `src/` into `/app/.venv`, final stage copies `.venv`, `ENV PYTHONUNBUFFERED=1`, `USER 65534:65534`, `ENTRYPOINT ["python","-u","-m","sidecar"]`. No `VOLUME`, no `EXPOSE`. |
| Upstream layout change | Upstream moved to a `pyproject.toml` plus `src/` layout from 2.5.5 (as the sibling Dockerfile comment says). The entrypoint is now `python -u -m sidecar`. The sibling `container-test.yaml` still uses `python -u /app/sidecar.py` and `CMD ["python","-u","/app/sidecar.py"]`. Verify that `/app/sidecar.py` still exists in 2.14.3 before keeping it: UNVERIFIED (the upstream tree was not listed). |
| Env vars | Sibling `settings.yaml` lists `FOLDER`, `LABEL`, `METHOD`, `NAMESPACE`, `RESOURCE`. UNVERIFIED against 2.14.3 source: these were not re-checked in this run. |
| Ports | None declared upstream. The draft's `8080/http` health port is UNVERIFIED and should not be added to `settings.yaml`. |
| Architecture | Upstream image is built from a musl (alpine) base. The chart pulls `ghcr.io/kiwigrid/k8s-sidecar:2.14.3`. Multi-arch status of that tag is UNVERIFIED. The sibling builds from the ContainerForge python base on ubuntu (glibc), so arch is a build question, not a copy-from. |
| copy-from | no (musl-built image does not run on glibc Ubuntu). |
| Dependencies | Needs the Kubernetes API (ServiceAccount, RBAC) and a Grafana main container to load the dashboards it finds. Not runnable standalone. |

## 2. Target layout

No new app. The chart's sidecar image is already `apps/k8s-sidecar`. Changes, if any, stay inside `apps/k8s-sidecar/`:

- `apps/k8s-sidecar/Dockerfile` (only if the 2.14.3 layout check in section 1 fails)
- `apps/k8s-sidecar/docker-bake.hcl` (LICENSE fix, see section 1)
- `apps/k8s-sidecar/container-test.yaml` (entrypoint check, see section 1)
- `apps/k8s-sidecar/settings.yaml` (env list check, see section 1)

No `apps/grafana/`. No `DOWNSTREAM_CHANGES.md` unless `apps/k8s-sidecar` is used as a `FROM` base (not seen in this run; check with `grep -r "k8s-sidecar" apps/*/Dockerfile` before any image change).

## 3. Base image

The sibling already uses `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Keep it. Fits because the sidecar is pure Python installed from source into a venv. Closest sibling: the app itself (`apps/k8s-sidecar`).

## 4. Dockerfile

Only if the existing sibling no longer matches 2.14.3. Required checks first:

1. Confirm the upstream entrypoint file for 2.14.3: `sidecar.py` at repo root, or `src/sidecar/__main__.py` (the module form `-m sidecar` implies a package under `src/`).
2. If the sibling's `cp -r /tmp/src_temp/.../src/* /app/` plus `CMD ["python","-u","/app/sidecar.py"]` still runs, keep the Dockerfile unchanged.
3. If the entrypoint moved, change the final `CMD` to `["python","-u","-m","sidecar"]` with `PYTHONPATH=/app` set so the copied package resolves. Do not copy the alpine base; keep the ubuntu-compatible python base.
4. Keep `USER apps` in the final stage (the upstream `65534` user is not used; ContainerForge runs `apps`).
5. Keep `COPY --chmod=0755 . /` and the builder copy structure.

## 5. docker-bake.hcl

Sibling values are correct except the license:

- `variable "LICENSE" { default = "MIT" }` (was `AGPL-3.0-or-later`; source is MIT per section 1).
- `VERSION` stays `2.14.3` with its renovate comment.
- Keep the four standard targets and the default group.
- Validate with `cd apps/k8s-sidecar && docker buildx bake --print`.

## 6. settings.yaml

Keep the schema header. Open items before editing:

- `ports`: stays `[]` (no upstream port; the draft's 8080 is UNVERIFIED).
- `env`: keep only variables the 2.14.3 source actually reads. The sibling list is UNVERIFIED against this release, so check each name in the upstream source before any change. Do not invent new vars.
- `volumes`: `/config` (required: true) stays.
- `dependencies`: none. The Grafana main container is wired by the chart, not by this app.

## 7. start.sh

The sibling has no `start.sh`. The sidecar needs no seeding: it watches the Kubernetes API and writes matched ConfigMaps to `FOLDER` (default `/tmp/`, per the sibling). Writable path is `/tmp`, not `/config`. If a `start.sh` is ever added, it must: create `FOLDER` under `/tmp` only, never write to `/app`, and `exec python -u -m sidecar` (or the verified entrypoint).

## 8. container-test.yaml

Current sibling test uses a `runners` entrypoint `python -u /app/sidecar.py`. Required checks:

- Confirm `/app/sidecar.py` exists in the 2.14.3 image; if it does not, update the runner to the verified entrypoint.
- Keep the forgetool schema header.
- No `tcp` or `http` probes: no ports are declared.
- Note the test runs with no Kubernetes API: the sidecar will fail to connect. The test must assert that the process starts and reports its connection attempt, not that it watches successfully. Confirm the forgetool runner semantics before writing the assertion; do not invent a passing condition.
- `timeoutSeconds`: match the python sibling.

## 9. Rootless and read-only-rootfs adaptations

- Runtime user: `USER apps` in the final stage (the sibling's `apps` user). Upstream uses `65534:65534`; the chart's common `runAsUser 568` is a chart value, not an app change.
- Upstream writes: the sidecar writes into `FOLDER` (default `/tmp/`), which is already `/tmp`. No remap needed beyond keeping `FOLDER` under `/tmp`.
- Draft persistence expectations: `/var/lib/grafana` PVC, configmap mounts for `grafana.ini` and `ldap.toml`, and emptyDir mounts are Grafana main container and chart concerns, not this sidecar's paths.
- Draft `podOptions automountServiceAccountToken true` and RBAC are required for the sidecar to watch the Kubernetes API; they stay as chart values, not image settings.
- Read-only rootfs: `docker run --read-only --tmpfs /tmp` should start the process; the Kubernetes API connection will fail outside a cluster (expected, see section 10).

## 10. Risks, caveats and open questions

- The sidecar cannot run usefully outside Kubernetes (draft caveat, confirmed by upstream purpose: it watches the Kubernetes API).
- Entrypoint and module layout for 2.14.3 changed from the sibling (section 1). Verify before any Dockerfile change.
- Env var names in the sibling `settings.yaml` are UNVERIFIED against 2.14.3.
- License mismatch in the sibling bake (`AGPL-3.0-or-later` vs upstream MIT): fix is in scope only if this plan is actioned.
- Upstream image architecture and `arm64` availability are UNVERIFIED. The ContainerForge build is independent of the upstream image tag.
- No blockers for the image build itself. The chart role (sidecar) means functional testing needs a Kubernetes cluster and a Grafana container, which CI does not run.

## 11. Build and test steps

From `apps/k8s-sidecar/` (no new app):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name k8s-sidecar-probe --read-only --tmpfs /tmp -v k8s-sidecar-probe-config:/config k8s-sidecar:2.14.3`, then `docker logs -f k8s-sidecar-probe`. Expected signal: the process stays up and logs its startup and watch attempt (no Kubernetes connection outside a cluster; log line text to be captured on first run). Clean up with `docker rm -f k8s-sidecar-probe; docker volume rm k8s-sidecar-probe-config`.
4. `forgetool containers test --image k8s-sidecar:2.14.3 --config ./apps/k8s-sidecar/container-test.yaml`

## 12. PR checklist

- Branch: `feat/add-grafana` is NOT needed; no new app. If changes are made, use a fix branch for `apps/k8s-sidecar` and the commit `fix(k8s-sidecar): <root cause>`.
- If a new app is later wanted, use `feat(<app>): add new container`.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only the boxes that apply.
- Say what was not tested: any Kubernetes API watch, the Grafana main container, and arm64.
