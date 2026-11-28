# portainer — implementation plan
> Source: ./draft.md · Target: apps/portainer/ · Difficulty: hard (reduced to medium by switching to Community Edition) · Role: sidecar (beImage) in the draft; this plan ports Portainer CE as the standalone main image · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Edition decision | Draft targets Portainer EE 3.1.0 extracted from `portainer/portainer-ee`: closed licensed binary, redistribution not allowed. Plan targets Portainer CE built from public release tarballs instead (draft already names CE as the practical alternative). |
| Version | 2.45.4 (latest release of portainer/portainer, 2026-11-18). |
| Renovate | datasource=github-releases, depName=portainer/portainer, versioning=semver |
| License | zlib (LICENSE of portainer/portainer confirmed as zlib). |
| Source URL | https://github.com/portainer/portainer/ |
| Per-arch downloads | `https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-amd64.tar.gz` and `.../portainer-${VERSION}-linux-arm64.tar.gz` (tags have no `v` prefix). |
| Checksum | Per-platform `portainer-${VERSION}-linux-<arch>-checksum.txt` release assets. Release metadata lists sha256 amd64 `785524df829f847f55126baab67bf554dbf3413efd29ea7a643c4f57a655c1dc`, arm64 `73e3478f386e06fb6ce85fc4d0c031247752bf82acbdf59564cd57eea2bb7461`. UNVERIFIED that the checksum .txt contents match these. Download the .txt in the Dockerfile and verify with `sha256sum -c`. |
| Upstream Dockerfile reviewed | `build/linux/Dockerfile` (develop): `FROM portainer/base`; copies `dist/mustache-templates` -> `/mustache-templates/`, `dist/portainer` -> `/`, `dist/public` -> `/public/`, `build/docker-extension` -> `/`; EXPOSE 9000 9443 8000; VOLUME /data; ENTRYPOINT `/portainer`; WORKDIR `/`. |
| Tarball layout | UNVERIFIED: expected top directory `portainer/` containing the `portainer` binary, `public/`, `mustache-templates/` (docs, from memory). Inspect before writing the extract step. |
| Flags / env | UNVERIFIED: `--data /data`, `--bind :9000`, `--bind-https :9443`, `--tunnel-port 8000` are Portainer CLI flags from memory; confirm via `portainer --help`. No env vars confirmed. |

## 2. Target layout

- `apps/portainer/Dockerfile`
- `apps/portainer/docker-bake.hcl`
- `apps/portainer/settings.yaml`
- `apps/portainer/container-test.yaml`
- `apps/portainer/start.sh`
No `defaults/`, no `root/`, no DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Static Go binary, so plain ubuntu is enough (upstream `portainer/base` is a minimal image). Closest sibling: `apps/adguardhome-sync` (release tarball into /app, arch via TARGETARCH).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (values `amd64`/`arm64` match asset names directly), `USER root`.
2. `curl -fL -o /tmp/portainer.tar.gz https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-${TARGETARCH}.tar.gz` and `curl -fL -o /tmp/portainer.sha256 .../portainer-${VERSION}-linux-${TARGETARCH}-checksum.txt`; verify with `sha256sum` against the tarball hash.
3. `tar xzf /tmp/portainer.tar.gz -C /tmp/pt`; `mkdir -p /app`; move binary to `/app/portainer`, `public` to `/app/public`, `mustache-templates` to `/app/mustache-templates`. Portainer looks for assets relative to the working dir (upstream uses `/public`), so set `--assets /app/public` (UNVERIFIED flag) or symlink `/public -> /app/public`.
4. Licenses: `curl` the repo `LICENSE` at tag `${VERSION}` into `/usr/share/licenses/portainer/LICENSE` (the archive does not necessarily contain it; UNVERIFIED).
5. `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
6. `ENV HOME=/config` (upstream cache `/.cache` per the draft is replaced by `XDG_CACHE_HOME=/tmp/cache`).
7. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 9000 9443 8000`; `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "portainer" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=portainer/portainer versioning=semver
  default = "2.45.4"
}
variable "LICENSE" { default = "Zlib" }
variable "SOURCE" { default = "https://github.com/portainer/portainer/" }
```
Plus the four standard targets and `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/portainer/portainer/"`.
- ports: `9000` tcp (HTTP UI), `9443` tcp (HTTPS UI), `8000` tcp (edge agent tunnel); all required false.
- env: `TZ` default `Etc/UTC`; `PORTAINER_DATA` default `/config` (start.sh-internal, passed as `--data`); `PORTAINER_BIND` default `:9000`; `PORTAINER_BIND_HTTPS` default `:9443`; `PORTAINER_TUNNEL_PORT` default `8000`. (These are ContainerForge wrapper variables, not upstream env vars: say so in a comment.)
- volumes: `/config` required true (draft's `/data` is remapped to `/config`).
- dependencies: none.

## 7. start.sh

`mkdir -p /config /tmp/cache`; export `XDG_CACHE_HOME=/tmp/cache`; no seeding (Portainer initialises its own DB in the data dir); final: `exec /app/portainer --data "${PORTAINER_DATA:-/config}" --bind "${PORTAINER_BIND:-:9000}" --bind-https "${PORTAINER_BIND_HTTPS:-:9443}" --tunnel-port "${PORTAINER_TUNNEL_PORT:-8000}" --assets /app/public` (flag names UNVERIFIED, confirm with `--help`). `:9000` binds all interfaces. No TLS key written to /app: Portainer self-generates certs in the data dir. Admin password is set in the UI on first start within 5 minutes (UNVERIFIED current behaviour).

## 8. container-test.yaml

Schema header; `timeoutSeconds: 120`; `tcp` probes for `9000`, `9443`, and `8000`; `http: - port: '9000' path: /` (UNVERIFIED status code; Portainer may redirect to a timeout/init page); `filePaths`: `/app/portainer`, `/app/public/index.html` (UNVERIFIED), `/usr/share/licenses/portainer`. Edge tunnel port 8000 may only open after init/edge-compute enabled (UNVERIFIED); if it does not listen by default, remove it from settings.yaml `ports` rather than weakening the test.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `/data` (-> `/config`), `/.cache` (-> `/tmp/cache`), generated TLS certs (inside data dir), `/tmp` scratch.
- Draft expects UID 568, read-only rootfs: matches `USER apps`. Docker socket access: `/var/run/docker.sock` must be mounted and readable by the `apps` user (group add via host `--group-add`); this is not baked into the image (open question).
- Draft extra persistence `/data`: folded into `/config`.

## 10. Risks, caveats and open questions

- EE vs CE: EE binary cannot be redistributed; plan intentionally ports CE. Confirm with maintainers that CE is acceptable (draft says amd64/arm64 `no` for EE).
- Docker socket mount means host-level control; document it.
- Tarball layout and CLI flags UNVERIFIED.
- Portainer enforces an initial-admin timeout; first run may require restart.
- CE 2.x LTS vs STS tag series: renovate may jump between series.
- Checksum asset format unverified.

## 11. Build and test steps

```sh
cd apps/portainer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name portainer-probe --read-only --tmpfs /tmp \
  -v portainer-probe-config:/config portainer:2.45.4
docker logs -f portainer-probe
forgetool containers test --image portainer:2.45.4 --config ./apps/portainer/container-test.yaml
docker rm -f portainer-probe; docker volume rm portainer-probe-config
```
Expected readiness: logs show the web server starting on `:9000` and `:9443` (exact wording UNVERIFIED) with no database errors, without the Docker socket mounted (it may log an environment warning).

## 12. PR checklist

- Branch `feat/add-portainer`; commit `feat(portainer): add new container`; PR template filled; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, arm64, tarball layout, flags, read-only run, Docker socket access, port 8000 behaviour.
