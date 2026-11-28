# root — implementation plan
> Source: ./draft.md · Target: apps/root/ · Difficulty: hard (large C++ stack, Jupyter second server, amd64 only) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v6-40-04 (GitHub release 2026-08-27; the version in the asset name is 6.40.04) |
| Draft tag | `bgameiro/arch-cern-root:latest` (Arch, pacman). Not used. |
| Renovate | `datasource=github-releases depName=root-project/root`, tags look like `v6-40-04`, so `versioning=regex:^v(?<major>\d+)-(?<minor>\d+)-(?<patch>\d+)$`. UNVERIFIED: that renovate's regex versioning accepts the leading-zero patch `04`; test with `renovate-config-validator` or a dry run. |
| License | LGPL-2.1-or-later (from memory of the repo's LICENSE). UNVERIFIED: not re-fetched in this session. |
| Source | https://github.com/root-project/root (docs https://root.cern/manual/) |
| amd64 download | https://github.com/root-project/root/releases/download/v6-40-04/root_v6.40.04.Linux-ubuntu26.04-x86_64-gcc15.2.tar.gz (asset confirmed in the release list; ubuntu24.04 and ubuntu22.04 builds also exist) |
| arm64 download | None. The release has no Linux aarch64 asset (only `macos-...-arm64`). arm64 is not available from upstream binaries. UNVERIFIED: whether Ubuntu 26.04 ships `root-system` for arm64 via apt (not checked). |
| Checksum | UNVERIFIED: no checksum file was found. Use the sha256 digest GitHub shows for the release asset (`gh api repos/root-project/root/releases/latest`, field `digest`) and pin it in the Dockerfile as `ARG ROOT_SHA256`. |
| Upstream Dockerfile reviewed | BGameiro2000/dockerfile arch-cern-root Dockerfile was linked but not fetched. UNVERIFIED. It installs ROOT and Jupyter with pacman on Arch. |
| Ports | 8888/tcp Jupyter notebook server (Jupyter's well-known default; draft marks it inferred). |
| Env vars | Jupyter reads `JUPYTER_CONFIG_DIR`, `JUPYTER_DATA_DIR`, `JUPYTER_RUNTIME_DIR`, `IPYTHONDIR` (UNVERIFIED in this session, standard jupyter_core variables). ROOT needs `ROOTSYS`, `PATH`, `LD_LIBRARY_PATH`, `PYTHONPATH` from `bin/thisroot.sh` (UNVERIFIED, standard). |

## 2. Target layout

- `apps/root/Dockerfile`
- `apps/root/docker-bake.hcl`
- `apps/root/settings.yaml`
- `apps/root/container-test.yaml`
- `apps/root/start.sh`

No `defaults/` is needed (Jupyter creates its config on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

The release tarball is built for Ubuntu 26.04 with gcc 15.2, so it matches the ubuntu base exactly. The python base is not used because ROOT's PyROOT bindings are built against the system python of that Ubuntu release (UNVERIFIED). Closest siblings: `apps/adguardhome-sync` (tarball extracted to `/app`) and `apps/changedetection` (venv with pip packages).

## 4. Dockerfile

1. `ARG VERSION` (value `v6-40-04`) and `ARG ROOT_SHA256`, `ARG TARGETARCH`, then `USER root`.
2. Fail fast on arm64: `test "${TARGETARCH}" = "amd64"` with a clear message, because no arm64 asset exists.
3. `apt-get install -y --no-install-recommends` the runtime libraries ROOT needs (UNVERIFIED list; derive it with `ldd` against `/app/root/bin/root.exe` in the first build, typical: `libtbb12`, `libxpm4`, `libxft2`, `libxext6`, `libx11-6`, `libssl3t64`, `libgl1`, `libglu1-mesa`, `libpng16-16t64`, `libjpeg-turbo8`, `libgsl28`, `libfftw3-double3`, `python3`, `python3-venv`, `python3-numpy`, `python3-dev` only if PyROOT needs headers), plus `ca-certificates`, `curl`. Pin only when a package is the shipped product (none is).
4. Download, verify and extract:
   ```dockerfile
   RUN V="${VERSION#v}" && DOT="${V//-/.}" && \
       curl -fsSL -o /tmp/root.tar.gz "https://github.com/root-project/root/releases/download/${VERSION}/root_v${DOT}.Linux-ubuntu26.04-x86_64-gcc15.2.tar.gz" && \
       echo "${ROOT_SHA256}  /tmp/root.tar.gz" | sha256sum -c - && \
       mkdir -p /app && tar xzf /tmp/root.tar.gz -C /app && \
       mkdir -p /usr/share/licenses/root && \
       cp /app/root/LICENSE /usr/share/licenses/root/ 2>/dev/null || true && \
       rm /tmp/root.tar.gz
   ```
   The tarball is expected to unpack into `root/` (UNVERIFIED, check with `tar tzf`). If the LICENSE path differs, fix the `cp`, and do not leave `|| true` in the final file.
5. Jupyter in a read-only venv: `python3 -m venv /app/venv && /app/venv/bin/pip install --no-cache-dir notebook` (pin versions with `ARG JUPYTER_VERSION` and a `// renovate: datasource=pypi depName=notebook` line in the Dockerfile as in `apps/changedetection`). If PyROOT needs the system python, create the venv with `--system-site-packages`.
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. `ENV ROOTSYS=/app/root HOME=/config JUPYTER_CONFIG_DIR=/config/jupyter JUPYTER_DATA_DIR=/config/jupyter/data JUPYTER_RUNTIME_DIR=/tmp/jupyter IPYTHONDIR=/config/ipython PIP_CACHE_DIR=/tmp/pip XDG_CACHE_HOME=/tmp MPLCONFIGDIR=/tmp/mpl`.
8. `USER apps`, then `COPY --chmod=0755 . /`.
9. `EXPOSE 8888`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "root" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=root-project/root versioning=regex:^v(?<major>\d+)-(?<minor>\d+)-(?<patch>\d+)$
  default = "v6-40-04"
}
variable "LICENSE" { default = "LGPL-2.1-or-later" }
variable "SOURCE" { default = "https://github.com/root-project/root" }
```
Targets: `docker-metadata-action`, `image` (args `VERSION`, labels source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` with `platforms = ["linux/amd64"]` only (no arm64 asset; if the user wants arm64 later, add it with an apt or source route), `group "default"` with `image-local`. Add `ROOT_SHA256` as a variable and pass it in `args`; renovate will not update it, so document that a version bump needs a new digest. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/root-project/root"`.
- `ports`: `8888` tcp, required false.
- `env`: `TZ` default `Etc/UTC`; `JUPYTER_TOKEN` default `""` (empty means Jupyter generates a random token and prints it in the log; our `start.sh` reads it), required false; `JUPYTER_NOTEBOOK_DIR` default `/config/notebooks` (read by our `start.sh`), required false.
- `volumes`: `/config` required true. The draft's extra `/appdata` pvc is mapped to `/config/notebooks`; there is no separate volume.
- `dependencies:` none.

## 7. start.sh

- `set -eu`; `source /app/root/bin/thisroot.sh` (sets `PATH`, `LD_LIBRARY_PATH`, `PYTHONPATH`; check it works under `set -u`).
- `mkdir -p "${JUPYTER_NOTEBOOK_DIR:-/config/notebooks}" /config/jupyter /config/ipython /tmp/jupyter` (idempotent; seeds only when missing).
- Final command, binding to all interfaces, no browser:
  ```bash
  exec /app/venv/bin/jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser \
    --notebook-dir="${JUPYTER_NOTEBOOK_DIR:-/config/notebooks}" \
    ${JUPYTER_TOKEN:+--IdentityProvider.token="${JUPYTER_TOKEN}"}
  ```
  Passing the token through the process list exposes it; prefer `export JUPYTER_TOKEN` (Jupyter Server reads it from the environment, UNVERIFIED for the installed major version; the `notebook` 7 line is built on jupyter-server) and drop the flag if confirmed. Without a token Jupyter prints a random one, so the empty-env start works.
- `--allow-root` is not used because the process runs as `apps`.
- Nothing is written to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8888'
filePaths:
- /app/root/bin/root.exe
- /app/venv/bin/jupyter
healthCommands:
- command: /bin/bash -c 'source /app/root/bin/thisroot.sh && root-config --version'
```
The token path (`JUPYTER_TOKEN` set) is not exercised by the test; test it by hand.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root and `readOnlyRootFilesystem: false` with `/appdata`. Reconciled: user `apps` 568, read-only rootfs, notebooks and Jupyter config in `/config`, runtime dir and caches in `/tmp`.
- Write paths: `~/.jupyter` (remapped by `JUPYTER_CONFIG_DIR`), `~/.local/share/jupyter` (`JUPYTER_DATA_DIR`), Jupyter runtime files (`/tmp/jupyter`), IPython profile (`IPYTHONDIR`), ROOT history `~/.root_hist` and ROOT cache for ACLiC compiled macros (`HOME=/config`; ROOT's `TMPDIR` should be `/tmp`, UNVERIFIED), matplotlib cache (`MPLCONFIGDIR=/tmp/mpl`, add to `ENV`).
- ACLiC (compiling macros) needs a compiler, which is not installed. Document the limit instead of adding gcc.

## 10. Risks, caveats and open questions

- No arm64: blocker for a multi-arch image. The plan ships amd64 only unless the user accepts an apt or source route (UNVERIFIED).
- Jupyter without a token (when the user sets `JUPYTER_TOKEN=""` explicitly) is open code execution; the default random token avoids this.
- The runtime library list and the tarball's top-level folder name are UNVERIFIED and must be found on the first build.
- PyROOT's python must match the venv python; if not, use the system python with `--system-site-packages`.
- Image size is large (the tarball is hundreds of MB, UNVERIFIED size) and needs substantial RAM for analysis jobs.
- The draft's alternative of the python base was rejected (section 3). The draft's `root-system` apt package name is unverified and unused.

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/root`, one app at a time, 10 rounds at most.

```sh
cd apps/root
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create root-probe-config
docker run --rm -d --name root-probe --read-only --tmpfs /tmp \
  -v root-probe-config:/config root:v6-40-04
docker logs -f root-probe
forgetool containers test --image root:v6-40-04 --config ./apps/root/container-test.yaml
docker rm -f root-probe; docker volume rm root-probe-config
```

- Expected readiness signal: Jupyter log line "Jupyter Server ... is running at" with http://...:8888/ and the token URL; port 8888 open.
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: open a notebook, run `import ROOT; print(ROOT.gROOT.GetVersion())` in a Python kernel and a ROOT C++ macro; set JUPYTER_TOKEN and confirm login works.
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-root` from a freshly pulled `main`; commit and PR title `feat(root): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/root/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: arm64 (not supported), the JUPYTER_TOKEN path, PyROOT, runtime library completeness.
