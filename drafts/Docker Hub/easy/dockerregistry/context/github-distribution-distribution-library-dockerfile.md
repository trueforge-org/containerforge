# distribution/distribution-library-image Dockerfile (commit 775973b)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/distribution/distribution-library-image/775973b655bb4b11561db92a1cf50113148ce530/Dockerfile (from the draft's blob link) · 2026-11-26

## Contents
- `FROM alpine:3.24`. `RUN apk add --no-cache ca-certificates`.
- One RUN: `version='3.1.2'`; `apkArch="$(apk --print-arch)"`; case map: x86_64->amd64 (sha256 `40df2224d410f72ae425c3371873b078bbdbda3b8b612be9571f0e6751f3acc8`), aarch64->arm64 (sha256 `09d26f88d2c0f161bd1b8bfc6c123571cc3d291dcca8af5477b3cacc4ec95e73`), armhf->armv6 (`4a2e24eb...`), armv7->armv7 (`5227ce1a...`), ppc64le (`3bee3e9f...`), s390x (`907d384a...`), riscv64 (`9bd0f9e3...`).
- `wget -O registry.tar.gz https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz`; `echo "$sha256 *registry.tar.gz" | sha256sum -c -`; `tar --extract ... --directory /bin/ registry`; `registry --version`.
- `COPY ./config-example.yml /etc/distribution/config.yml`; `ENV OTEL_TRACES_EXPORTER=none`; `VOLUME ["/var/lib/registry"]`; `EXPOSE 5000`.
- `COPY entrypoint.sh /entrypoint.sh`; `ENTRYPOINT ["/entrypoint.sh"]`; `CMD ["/etc/distribution/config.yml"]`.
- No ARG, USER, HEALTHCHECK.

## Notes vs plan.md
- Matches plan.md section 1 (alpine:3.24, binary path, config path, OTEL env, VOLUME, EXPOSE, entrypoint, CMD). Hashes match plan.md's amd64 and arm64 values.
- Upstream runs as root (no USER); binary goes to `/bin/`, plan installs to `/app/registry`.
