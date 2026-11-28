# truecommand — implementation plan
> Source: ./draft.md · Target: apps/truecommand/ · Difficulty: very-hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart `appVersion` and pinned tag `3.3.0` (pushed 2026-04-10). Source: https://hub.docker.com/v2/repositories/ixsystems/truecommand/tags/3.3.0 and https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/Chart.yaml |
| Latest stable upstream | UNVERIFIED beyond the tags listed. The `latest` tag points to the same digest as `3.3.0`. Source: https://hub.docker.com/v2/repositories/ixsystems/truecommand/tags/?page_size=5 |
| Digest (chart pin) | `sha256:35a6bb629397c70b4fa79426df5bdd548d5bc0c283bbf592e4394ba3b54c8761`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/values.yaml |
| Renovate | UNVERIFIED: no datasource can be confirmed. Only Docker Hub `ixsystems/truecommand` is known. |
| License | UNVERIFIED. The docs page metadata reports CC BY-SA 4.0 for the documentation only: https://www.truenas.com/docs/truecommand/ . The product license is not confirmed. |
| Source URL | None public. The draft says closed source. |
| Architectures | amd64 only. Source: https://hub.docker.com/v2/repositories/ixsystems/truecommand/tags/3.3.0 . No arm64 entry in the latest tags. |
| Download | None. No standalone binary is published. |
| Checksum source | Not applicable: no binary download. |
| Upstream Dockerfile reviewed | None public (draft). UNVERIFIED. |
| Ports (chart) | Service `main` port 10031 maps to container port 80. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/values.yaml . Draft's 443 is UNVERIFIED. |
| Data paths (chart) | `/data` (chart persistence `data`). Same source. |
| Chart security | `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`. Same source. |
| Env vars | UNVERIFIED: no env list was fetched. The docs page returned marketing HTML only. |
| Dependencies | UNVERIFIED: an iXsystems account and vendor cloud sign-in are expected per the draft. |

## 2. Target layout

Not applicable for now: no buildable layout exists until the blockers in section 10 are resolved. If a design is found, the layout would be `apps/truecommand/` with `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `root/`. No `DOWNSTREAM_CHANGES.md`, because nothing would use it as a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` is the default base the draft names. The upstream image (`docker.io/ixsystems/truecommand:3.3.0`) is the only artifact, and its base OS is UNVERIFIED. Closest sibling: none found in `apps/` for a closed-source monitoring product.

## 4. Dockerfile

Not applicable as a standard build. The only route the facts support is a repackaging of the published image, which does not fit the ContainerForge model:

1. `FROM` the upstream image would bring in the whole vendor runtime, which is not built here.
2. `COPY --from=ixsystems/truecommand:3.3.0` would need the binaries' runtime libraries and layout, which are UNVERIFIED, and the vendor licence terms for redistribution are UNVERIFIED.

If a route is ever found, the Dockerfile must still end with `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, and keep `ARG VERSION` equal to the bake `VERSION` (`3.3.0`).

## 5. docker-bake.hcl

Not applicable until section 4 has a feasible route. When it does, the values would be:

- `APP` = `truecommand`
- `VERSION` = `3.3.0`, with `// renovate: datasource=docker depName=ixsystems/truecommand versioning=loose` (versioning to be confirmed, UNVERIFIED)
- `LICENSE` = UNVERIFIED
- `SOURCE` = UNVERIFIED: no public source. Use the vendor docs page https://www.truenas.com/docs/truecommand/ if a value is required.

The four standard targets and the `default` group are copied from `apps/steamcmd/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Draft values only, to be confirmed before any port:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.truenas.com/docs/truecommand/"
ports:
  - port: 80
    protocol: tcp
    required: true
volumes:
  - path: /config
    required: true
```

Port 80 is a draft value only: a non-root `apps` process cannot bind below 1024, so a port would need an in-container remap (for example 8080) that the unmodified vendor image may not support (UNVERIFIED). Env list is empty because no env var is verified (UNVERIFIED). The chart's `/data` path would need to map to `/config` (section 9). The draft's 443 port is not in the chart and is left out.

## 7. start.sh

Not applicable: no start script is planned until the upstream entrypoint and env vars are confirmed. Requirements when written: idempotent, seeds `/config` only when missing, writes nothing to `/app`, caches in `/tmp`, binds `0.0.0.0`, and ends with `exec`.

## 8. container-test.yaml

Draft probes, to be confirmed:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '80'
http:
- port: '80'
  path: /
```

Every port in `settings.yaml` needs a probe. `timeoutSeconds` is a guess; the chart shows no startup window, so the value is UNVERIFIED.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (chart PVC `data`) | Candidate remap: `/config` with the same subfolder layout. UNVERIFIED: the image's real use of `/data` is not confirmed. |

Draft expectations reconciled: the chart runs as root (`runAsUser: 0`) and sets `readOnlyRootFilesystem: false`. The draft says the product expects host-level access, which the chart does not show as a privilege (`privileged` is not set in values). A ContainerForge image would run as `apps`, which may break any root-only behaviour. Not tested with `--read-only --tmpfs /tmp`.

## 10. Risks, caveats and open questions

- Blocker: closed source with no rebuild path. Only the published image exists.
- Blocker: amd64 only. arm64 hosts cannot run it.
- Blocker: the draft says it runs as root and expects host-level access (UNVERIFIED for the image). A rootless `apps` user may not work.
- Blocker: vendor cloud sign-in and an iXsystems account are expected (draft; UNVERIFIED). Without them the container may not be usable.
- Caveat: redistribution rights for a repackaged vendor binary are UNVERIFIED. Licence review is needed before any build.
- Open question: is there a sanctioned way to run it in ContainerForge? If not, leave this app as a `skipped` draft.

Recommendation: do not start a port. Revisit only if the vendor publishes a redistributable artifact or the licence allows repackaging.

## 11. Build and test steps

Not applicable until the blockers are resolved. For reference, once a route exists, the protocol commands are:

```sh
cd apps/truecommand
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name truecommand-probe --read-only --tmpfs /tmp \
  -v truecommand-probe-config:/config truecommand:3.3.0
docker logs -f truecommand-probe
forgetool containers test --image truecommand:3.3.0 --config ./apps/truecommand/container-test.yaml
docker rm -f truecommand-probe; docker volume rm truecommand-probe-config
```

Readiness signal: UNVERIFIED (no startup log was fetched).

## 12. PR checklist

- Branch `feat/add-truecommand`, commit and PR title `feat(truecommand): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Untested to state honestly: everything, since no build was run and no startup was observed.
- Check `docker buildx bake --print` passes and bake `VERSION` equals the Dockerfile `ARG VERSION` before any PR.

## Fix attempt (2026-11-28)
Nothing written; the folder stays a skipped draft. Tried and found:
- `https://github.com/iXsystems/TrueCommand` (named in the image labels) is 404 (private) from the GitHub API, so no source and no licence file. Image label `org.opencontainers.image.licenses` is empty.
- Image config of `ixsystems/truecommand:3.3.0` (linux/amd64, read with `crane config`/`crane export`, nothing run): `CMD ["/usr/bin/truecommand-mw"]`, no `ENTRYPOINT`, no `USER` (root), `EXPOSE 80 and 50135`, `VOLUME /data`, env `TC_CONFIG_FILE_PATH=/etc/middleware/config.yaml` and `GOTRACEBACK=crash`, labels `version=v3.3.0`, revision `4a7e47a9d10b31bed1affb6d894ce0bf35ab79d0`. Build history: ADD to `/bin`, COPY of the Angular UI to `/usr/www/truecommand`, COPY to `/etc/middleware/`, COPY of the binary.
- `/usr/bin/truecommand-mw` is a 64 MB statically linked Go 1.26 binary (module `github.com/iXsystems/TrueCommand/middleware`). The image holds only `/etc/middleware/VERSION`; the `config.yaml` named by `TC_CONFIG_FILE_PATH` is not in the image, so the binary must create or default it. The UI ships `3rdpartylicenses.txt` (third-party only).
- A `COPY --from=ixsystems/truecommand@sha256:35a6bb629397c70b4fa79426df5bdd548d5bc0c283bbf592e4394ba3b54c8761` of the binary and `/usr/www/truecommand` onto the ubuntu base looks feasible, but these cannot be settled without running it: how the binary picks its listen ports (80 cannot be bound by `apps` without a port override), where it writes besides `/data`, the config file format, and what 50135 is. Static strings showed no env var or flag names for them.
Still needed: a run of the image (not allowed in this task) or vendor docs for the port and data-dir settings, and a licence statement permitting redistribution.
