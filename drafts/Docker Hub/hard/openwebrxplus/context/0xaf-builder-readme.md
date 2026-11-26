# 0xAF/openwebrxplus-docker-builder README

Source URL(s): https://github.com/0xAF/openwebrxplus-docker-builder (raw master README) · fetched 2026-11-26

- Builds two images: `slechev/openwebrxplus` (standard) and `slechev/openwebrxplus-softmbe` (adds SoftMBE decoder: DMR, D-Star, YSF, FreeDV, DRM, NXDN).
- Build SoftMBE: `./run build buildfiles/Dockerfile-softmbe`. `USE_LEGACY_MBELIB=y` builds legacy mbelib; other non-empty values except `n` refused.
- Deployment: Docker Compose (`compose.yaml`, `.env.example`, `docker.md` for quick start, config, troubleshooting). `OWRX_IMAGE` in .env selects the variant.
- Native Debian packaging: mbelib-neo tag v2.0.0 via `buildfiles/prepare-mbelib-neo-debian.sh` and `dpkg-buildpackage -b -us -uc`; packages libmbe-neo2, libmbe-neo-dev, codecserver-driver-softmbe-neo.
- Not stated in README: ports, volumes, env defaults, architectures, USB requirements, licence of repo.
- Neo adapter conflicts with legacy adapter.
