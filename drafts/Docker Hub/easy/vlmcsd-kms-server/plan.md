# vlmcsd-kms-server — implementation plan
> Source: ./draft.md · Target: apps/vlmcsd-kms-server/ · Difficulty: easy (draft) — medium in practice, needs a source build for arm64 · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/Wind4/vlmcsd (KMS emulator, C, GNU make). Chart image `mikolatero/vlmcsd` is a thin Alpine wrapper from https://github.com/mikolatero/docker-vlmcsd |
| Latest release / tag | `svn1113` (tags seen: svn1111, svn1112, svn1113). master HEAD `70e03572b254688b8c3557f898e7ebd765d29ae1` |
| Renovate | `datasource=github-tags depName=Wind4/vlmcsd versioning=loose` (tag names are `svn<N>`, not semver) |
| License | UNVERIFIED. The repo has no `LICENSE` file, and the source headers and `README` examined do not state one. Use `NOASSERTION` in `docker-bake.hcl` until the maintainers decide, and say so in the PR |
| Draft correction (apt) | The draft's `apt: vlmcsd` is wrong for this base: no `vlmcsd` package exists in Ubuntu (`resolute`, `noble`, `jammy` search pages say "No such package") or in Debian trixie. Do not use apt |
| Draft correction (binary) | `https://github.com/Wind4/vlmcsd/releases/download/svn1113/binaries.tar.gz` (22 MB, 526 entries) has Linux builds only for intel (`x64-glibc`, `x64-musl-static`, x86), arm 32-bit, mips, ppc, s390 and sparc. There is NO linux aarch64 binary (the only aarch64 files are Android and iOS). So arm64 needs a source build |
| Source tarball | `https://github.com/Wind4/vlmcsd/archive/refs/tags/svn1113.tar.gz` (extracts to `vlmcsd-svn1113/`, contains `GNUmakefile`, `Makefile` (BSD make redirect), `src/`, `etc/vlmcsd.ini`, `etc/vlmcsd.kmd`, `man/`) |
| Build | `make` with GNU make from the source root builds `bin/vlmcsd` (server) and `bin/vlmcs` (test client). Confirmed by upstream `mikolatero/docker-vlmcsd` Dockerfile (`apk add git make build-base`, `make`, copies `bin/vlmcsd`) and `src/GNUmakefile` (`all: $(REAL_CLIENT_NAME) $(REAL_PROGRAM_NAME)`) |
| Checksum source | None published for the source tarball or binaries. Mitigation: pin the tag and, optionally, a `sha256` ARG computed when porting |
| Upstream Dockerfile reviewed | `mikolatero/docker-vlmcsd` (Alpine build and run): `EXPOSE 1688/tcp`, `CMD ["/vlmcsd","-D","-d","-t","3","-e","-v"]`, copies `etc/vlmcsd.kmd` next to the binary |
| Port | `1688/tcp` (default KMS port). Default listen addresses `0.0.0.0` and `::` unless `-L` is used (man page) |
| Relevant flags (man `vlmcsd.8`) | `-D` foreground, `-e` log to stdout (ignores `-l`), `-v` verbose, `-d` disconnect after one request, `-t <s>` TCP timeout (default 30), `-L ip[:port]`, `-P port`, `-i inifile`, `-m clients`, `-r0/1/2` ePID mode, `-K0..3`, `-c1`, `-o1/2/3` private-IP restrictions |
| Env vars | None. vlmcsd reads no environment variables for configuration (UNVERIFIED by full source scan; `getenv` search in `src/vlmcsd.c` returned nothing). `TZ` is honored by libc |
| State | None. No config file is required |

## 2. Target layout

```
apps/vlmcsd-kms-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (optionally ship `etc/vlmcsd.ini` later). `root/` is never used. No `DOWNSTREAM_CHANGES.md`. The folder name follows the draft (`vlmcsd-kms-server`); check with maintainers whether `vlmcsd` is preferred.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Build stage: the same ubuntu image `AS build`, with `build-essential` installed (not in the base). No sibling builds C from source in a separate stage; use the `apps/tvheadend` Dockerfile (builds from git with apt build deps) as the pattern, and `apps/it-tools` as an example of `AS build`. The draft says "ubuntu alone is enough", which holds for the final stage.

## 4. Dockerfile

Stage 1 (`AS build`):
1. `ARG VERSION` (`svn1113`), `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends build-essential` (already has `gcc`, `make`; `curl` and `tar` come from the base). Pin versions only if hadolint demands (these are build-only, not shipped).
3. `curl -fsSL -o /tmp/vlmcsd.tar.gz "https://github.com/Wind4/vlmcsd/archive/refs/tags/${VERSION}.tar.gz" && tar xzf /tmp/vlmcsd.tar.gz -C /tmp && cd /tmp/vlmcsd-${VERSION} && make -j"$(nproc)"`. Build natively per platform (buildx runs the build stage under each target platform, so arm64 is native or QEMU; no cross toolchain).
4. Artifacts: `bin/vlmcsd`, `bin/vlmcs`, `LICENSE`-like files (none exist), `man/vlmcsd.8`, `etc/vlmcsd.ini`.

Stage 2 (final):
1. `ARG VERSION`; `USER root` only for `mkdir`.
2. `COPY --from=build /tmp/vlmcsd-${VERSION}/bin/vlmcsd /app/vlmcsd` and `.../bin/vlmcs /app/vlmcs`; `COPY --from=build .../man/vlmcsd.8 /usr/share/doc/vlmcsd/vlmcsd.8` and `.../etc/vlmcsd.ini /usr/share/doc/vlmcsd/vlmcsd.ini.sample`.
3. `chown -R apps:apps /app && chmod 755 /app/vlmcsd /app/vlmcs`.
4. License notice: since the upstream ships no license file, write `/usr/share/licenses/vlmcsd/README` containing the upstream URL and a note that no license text was published. Replace it with the real file when the license is settled.
5. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 1688`. No `VOLUME /config` is required (stateless), but keep `VOLUME /config` for consistency with the other apps in this family if the maintainers want an empty-`/config` check; the plan keeps it.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "vlmcsd-kms-server" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=Wind4/vlmcsd versioning=loose
  default = "svn1113"
}
variable "LICENSE" { default = "NOASSERTION" }  // UNVERIFIED: no upstream license file
variable "SOURCE"  { default = "https://github.com/Wind4/vlmcsd" }
```

Standard targets from `apps/adguardhome-sync/docker-bake.hcl` (metadata action, image, image-local tagged `${APP}:${VERSION}`, image-all amd64 and arm64, default group). Run `docker buildx bake --print`.

## 6. settings.yaml

- Header with schema, `schema_version: 1`, `upstream_env_url: "https://github.com/Wind4/vlmcsd"`.
- `ports`: `1688` / `tcp` / `required: true`.
- `env`: `TZ` / `Etc/UTC` / false. That is all: vlmcsd has no env configuration. Do not invent others.
- `volumes`: `/config` / `required: false` (nothing is written).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
# stateless: no /config seeding needed
exec /app/vlmcsd -D -e -v -t 30 -L 0.0.0.0:1688
```

- `-D -e` keep it in the foreground and log to stdout so `docker logs` works and signals reach the process.
- `-L 0.0.0.0:1688` makes the bind explicit for IPv4 and avoids a startup warning on hosts without IPv6; add `-L [::]:1688` only if IPv6 is wanted (UNVERIFIED how the server behaves with it in a container without IPv6; the man page says it continues if at least one socket works).
- `-v` is verbose (logs every request); the draft's upstream uses it, but consider dropping it to cut log volume (open question).
- Do not use `-d` (violates DCE RPC; upstream wrapper uses it with `-t 3`). Keep the defaults unless clients misbehave.
- Nothing is written to `/app` or `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '1688'
filePaths:
- /app/vlmcsd
- /app/vlmcs
```

A TCP probe on 1688 proves the listener; a protocol-level check is done by hand with the bundled client (`/app/vlmcs`, section 11). No env is required, so no code path is hidden.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Chart runs as root | `USER apps` (UID 568); port 1688 is unprivileged |
| Daemonizes by default, optional pid file `-p`, log file `-l` | Foreground with `-D`, log to stdout with `-e`; no pid file, no log file |
| `-u`/`-g` privilege drop | Not used |
| No state | Nothing to move to `/config` or `/tmp` |

All draft security expectations hold: non-root, read-only rootfs, not privileged, no extra persistence.

## 10. Risks, caveats and open questions

- License is unknown (no file in the repo). Needs a maintainer decision before merge; hosting a KMS emulator may also need a policy decision, as it only serves Windows/Office volume-license clients and the upstream README says it is not meant to activate unlicensed copies.
- The draft's apt path does not exist and its binary path has no arm64. The plan builds from the tagged source for both architectures. This is a deviation from "easy: prebuilt binary".
- `make` flags and hardening: the default build is dynamic against glibc, which is fine on ubuntu. UNVERIFIED: whether `make` needs extra packages in a minimal ubuntu (only `build-essential` is assumed).
- UNVERIFIED: whether `make` defaults produce a PIE binary or use `-static`; irrelevant at runtime on ubuntu.
- Version drift between the draft's two install paths (apt and binary tarball) is gone: one source-built version.
- The source tarball has no checksum upstream; the tag is the only integrity anchor.
- KMS needs correct system time on clients only when `-c1` is used; not enabled.

## 11. Build and test steps

```sh
cd apps/vlmcsd-kms-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create vlmcsd-probe-config
docker run --rm -d --name vlmcsd-probe --read-only --tmpfs /tmp \
  -v vlmcsd-probe-config:/config vlmcsd-kms-server:svn1113
docker logs -f vlmcsd-probe     # expect the startup banner with the listening address on port 1688, no fatal error
docker exec vlmcsd-probe /app/vlmcs -v 127.0.0.1:1688   # real KMS handshake (client flags UNVERIFIED, check `vlmcs -h`)
forgetool containers test --image vlmcsd-kms-server:svn1113 --config ./apps/vlmcsd-kms-server/container-test.yaml
docker rm -f vlmcsd-probe; docker volume rm vlmcsd-probe-config
```

Also build once for `linux/arm64` (`--set image-local.platform=linux/arm64`) because the source build is the only arm64 path. Exact readiness log text is UNVERIFIED; the success signal is "process alive plus port 1688 open".

## 12. PR checklist

- Branch `feat/add-vlmcsd-kms-server`; commit and PR title `feat(vlmcsd-kms-server): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and boxes; tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; check `license/cla`.
- Say clearly: license set to `NOASSERTION`, source-built for both arches, and list untested items (arm64 run, `vlmcs` handshake against a real Windows client, IPv6).
- Pre-completion: bake print, build, empty-`/config` read-only run, forgetool test, no weakened assertions, cleanup done.
