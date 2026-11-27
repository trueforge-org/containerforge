# GitHub: ekzhang/rustpad Dockerfile (commit 54e4a93)

Source URL(s): https://raw.githubusercontent.com/ekzhang/rustpad/54e4a9383c84d7317af42a7ddb177ce8bcba058d/Dockerfile (fetched 2026-11-27)

## Dockerfile (4 stages)
- `backend`: `FROM rust:alpine`; apk `musl-dev openssl-dev`; COPY . .; `cargo test --release`; `cargo build --release`.
- `wasm`: `FROM --platform=amd64 rust:alpine`; apk `curl musl-dev`; installs wasm-pack via `https://rustwasm.github.io/wasm-pack/installer/init.sh` (curl | sh); `wasm-pack build rustpad-wasm`.
- `frontend`: `FROM --platform=amd64 node:lts-alpine`; WORKDIR /usr/src/app; copies package.json + package-lock.json; copies wasm pkg; `npm ci`; ARG GITHUB_SHA, ENV VITE_SHA=${GITHUB_SHA}; `npm run check`; `npm run build`.
- Final: `FROM scratch`; COPY dist from frontend; COPY `rustpad-server` from backend release target; `USER 1000:1000`; `CMD ["./rustpad-server"]`. No EXPOSE, ENV, VOLUME or ENTRYPOINT.

## Runtime
- Binary: `rustpad-server` (cargo release). Serves static `dist` from the working dir (upstream layout, not checked in source).
- Runs as UID/GID 1000 in upstream image.

## Build deps (upstream)
- Rust toolchain (alpine/musl), openssl dev headers, wasm-pack, Node LTS (npm ci/check/build).
- Frontend build depends on wasm package output.

## Version / asset naming
- No release assets. Source tree pinned by commit SHA 54e4a9383c84d7317af42a7ddb177ce8bcba058d.
- `GITHUB_SHA` build arg sets `VITE_SHA`.

## Gotchas
- Upstream uses musl (`rust:alpine`) and `scratch`; ContainerForge plan builds glibc on ubuntu instead.
- wasm-pack install via curl|sh in the wasm stage (unpinned installer URL).
