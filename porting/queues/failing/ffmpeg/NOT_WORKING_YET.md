# ffmpeg: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&   apt-get update &&   apt-get install --no-install-recommends -y     autoconf     automake     bindgen     bison     build-essential     bzip2     cmake     clang     diffutils     doxygen     flex     g++     gcc     git     gperf     i965-va-driver-shaders     libasound2-dev     libcairo2-dev     libclang-18-dev     libclang-cpp18-dev     libclc-18     libclc-18-dev     libelf-dev     libexpat1-dev     libgcc-10-dev     libglib2.0-dev     libgomp1     libllvmspirvlib-18-dev     libpciaccess-dev     libssl-dev     libtool     libv4l-dev     libwayland-dev     libwayland-egl-backend-dev     libx11-dev     libx11-xcb-dev     libxcb-dri2-0-dev     libxcb-dri3-dev     libxcb-glx0-dev     libxcb-present-dev     libxext-dev     libxfixes-dev     libxml2-dev     libxrandr-dev     libxshmfence-dev     libxxf86vm-dev     llvm-18-dev     llvm-spirv-18     make     nasm     ocl-icd-opencl-dev     perl     pkg-config     python3-venv     x11proto-gl-dev     x11proto-xext-dev     xxd     yasm     zlib1g-dev &&   mkdir -p /tmp/rust &&   RUST_VERSION=$(curl -fsX GET https://api.github.com/repos/rust-lang/rust/releases/latest | jq -r '.tag_name') &&   curl -fo /tmp/rust.tar.gz -L \"https://static.rust-lang.org/dist/rust-${RUST_VERSION}-$TARGETARCH-unknown-linux-gnu.tar.gz\" &&   tar xf /tmp/rust.tar.gz -C /tmp/rust --strip-components=1 &&   cd /tmp/rust &&   ./install.sh &&   cargo install bindgen-cli cargo-c cbindgen --locked &&   python3 -m venv /config/venv &&   pip install -U --no-cache-dir     pip     setuptools     wheel &&   pip install --no-cache-dir cmake==3.31.6 mako meson ninja packaging ply pyyaml" did not complete successfully: exit code: 22

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-ffmpeg:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&   apt-get update &&   apt-get install --no-install-recommends -y     autoconf     automake     bindgen     bison     build-essential     bzip2     cmake     clang     diffutils     doxygen     flex     g++     gcc     git     gperf     i965-va-driver-shaders     libasound2-dev     libcairo2-dev     libclang-18-dev     libclang-cpp18-dev     libclc-18     libclc-18-dev     libelf-dev     libexpat1-dev     libgcc-10-dev     libglib2.0-dev     libgomp1     libllvmspirvlib-18-dev     libpciaccess-dev     libssl-dev     libtool     libv4l-dev     libwayland-dev     libwayland-egl-backend-dev     libx11-dev     libx11-xcb-dev     libxcb-dri2-0-dev     libxcb-dri3-dev     libxcb-glx0-dev     libxcb-present-dev     libxext-dev     libxfixes-dev     libxml2-dev     libxrandr-dev     libxshmfence-dev     libxxf86vm-dev     llvm-18-dev     llvm-spirv-18     make     nasm     ocl-icd-opencl-dev     perl     pkg-config     python3-venv     x11proto-gl-dev     x11proto-xext-dev     xxd     yasm     zlib1g-dev &&   mkdir -p /tmp/rust &&   RUST_VERSION=$(curl -fsX GET https://api.github.com/repos/rust-lang/rust/releases/latest | jq -r '.tag_name') &&   curl -fo /tmp/rust.tar.gz -L \"https://static.rust-lang.org/dist/rust-${RUST_VERSION}-$TARGETARCH-unknown-linux-gnu.tar.gz\" &&   tar xf /tmp/rust.tar.gz -C /tmp/rust --strip-components=1 &&   cd /tmp/rust &&   ./install.sh &&   cargo install bindgen-cli cargo-c cbindgen --locked &&   python3 -m venv /config/venv &&   pip install -U --no-cache-dir     pip     setuptools     wheel &&   pip install --no-cache-dir cmake==3.31.6 mako meson ninja packaging ply pyyaml" did not complete successfully: exit code: 22
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch + base-policy pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Still fails while fetching/installing rust toolchain for this build flow.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch K)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in early heavy toolchain bootstrap path despite rust version fallback; upstream/toolchain step exits non-zero.
- Full log: `amd64-build.log`
