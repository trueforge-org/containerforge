# squat/generic-device-plugin (build source + README)

Source URL(s): https://raw.githubusercontent.com/squat/generic-device-plugin/f7c3291/Dockerfile (fetched 2026-11-27; blob/f7c3291 variant is same file), https://raw.githubusercontent.com/squat/generic-device-plugin/f7c3291/LICENSE (Apache-2.0, HTTP 200), https://raw.githubusercontent.com/squat/generic-device-plugin/main/README.md and .../main/flake.nix (follow-ups, main branch, not pinned to f7c3291).

## Build (Dockerfile at f7c3291)
- Stage 1: `FROM --platform=$BUILDPLATFORM docker.io/nixos/nix:2.35.3 AS builder`
- COPY . /tmp/build; build args BUILDOS, BUILDARCH, TARGETOS, TARGETARCH, VERSION.
- `VERSION="$VERSION" nix --extra-experimental-features "nix-command flakes" --option filter-syscalls false build --impure ".#generic-device-plugin-cross-$TARGETOS-$TARGETARCH"`
- `ln -s ../bin result/bin/"$BUILDOS"_"$BUILDARCH"`
- Stage 2: `FROM scratch`; COPY binary from result/bin/$TARGETOS_$TARGETARCH/generic-device-plugin to /generic-device-plugin.
- ENTRYPOINT ["/generic-device-plugin"]. No USER, no EXPOSE, no HEALTHCHECK, no ENV.

## Runtime deps
- None: static binary in scratch image.

## Flags (README, main branch)
- `--device` (repeatable): JSON `{"name": "<name>", "groups": [...], "count": N}`; path groups (`paths`, optional `mountPath`), USB groups (`usb` vendor/product/serial).
- `--config` path to config file.
- count default 1; globs allowed in paths.
- Example: `{"name": "fuse", "groups": [{"count": 10, "paths": [{"path": "/dev/fuse"}]}]}`

## Version/asset naming
- Version via VERSION build arg; flake default falls back to git rev. ldflags set `github.com/squat/generic-device-plugin/version.Version`.
- Build target `generic-device-plugin-cross-<os>-<arch>` from flake.nix.

## Arch
- Multi-arch via TARGETOS/TARGETARCH; build platform pinned to BUILDPLATFORM.

## Gotchas
- Build needs network access inside nix (flakes, --impure).
- Final image has no shell, no user; runs as root by default.
- Image itself is distroless-like scratch; TrueCharts runs privileged with host /dev mounted.
