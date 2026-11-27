# blakeblackshear/frigate: docker/main/Dockerfile (commit a19e23ae, v0.18.3)

Source URL(s): https://raw.githubusercontent.com/blakeblackshear/frigate/a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676/docker/main/Dockerfile (fetched 2026-11-27; blob/ variant same file). Release tag v0.18.3 per draft/chart appVersion.

## Build stages (multi-stage, BuildKit syntax 1.6)
- ARGs: BASE_IMAGE=debian:12, SLIM_BASE=debian:12-slim, BASE_HOOK (optional shell hook), DEBIAN_FRONTEND, PIP_BREAK_SYSTEM_PACKAGES=1, DEBUG=false (wheels stage).
- nginx: build_nginx.sh (ccache).
- sqlite-vec: build_sqlite_vec.sh.
- intel-media-driver: build_intel_media_driver.sh (built vs bookworm libva).
- go2rtc: ADD v1.9.14 binary `go2rtc_linux_${TARGETARCH}`.
- tempio: install_tempio.sh.
- ov-converter (base_host): OpenVINO requirements-ov.txt; downloads TF SSDlite model, runs build_ov_model.py.
- libusb-build: libusb v1.0.26 built with --disable-udev (Coral/NCS2 support).
- models: edgetpu + cpu tflite (google-coral test_data), openvino-model/, yamnet audio tflite from Kaggle; labelmap.txt, audio-labelmap.txt.
- s6-overlay: install_s6_overlay.sh.
- wheels: python3.11, OpenCV build deps; pip requirements.txt, requirements-wheels.txt (+ requirements-dev.txt if DEBUG); build_pysqlite3.sh; install_hailort.sh.
- deps-rootfs (scratch) merges artifacts + docker/main/rootfs/.
- deps: slim-base; install_deps.sh; ffmpeg versions DEFAULT 8.0, INCLUDED 8.0:7.0:5.0; pip from get-pip (setuptools==77.0.3); installs wheels; axengine 0.1.3 wheel (GitHub release); install_memryx.sh; ldconfig.
- devcontainer: node 20, requirements-dev.txt, CMD sleep infinity (dev only).
- web-build: node:20, `npm install`, `npm run build` from web/.
- rootfs (scratch): frigate/, migrations/, web/ dist.
- frigate (final): FROM deps, COPY rootfs to /opt/frigate/.

## Env (deps stage)
| Name | Value |
| --- | --- |
| NVIDIA_VISIBLE_DEVICES | all |
| NVIDIA_DRIVER_CAPABILITIES | compute,video,utility |
| TOKENIZERS_PARALLELISM | true |
| TRANSFORMERS_NO_ADVISORY_WARNINGS | 1 |
| OPENCV_FFMPEG_LOGLEVEL | 8 |
| PYTHONWARNINGS | ignore:::numpy.core.getlimits |
| HAILORT_LOGGER_PATH | NONE |
| TF_CPP_MIN_LOG_LEVEL / TF_CPP_MIN_VLOG_LEVEL | 3 / 3 |
| TF_ENABLE_ONEDNN_OPTS | 0 |
| AUTOGRAPH_VERBOSITY | 0 |
| GLOG_minloglevel / GLOG_logtostderr | 3 / 0 |
| PATH | prepends /usr/local/go2rtc/bin, /usr/local/tempio/bin, /usr/local/nginx/sbin; appends /usr/bin/axcl |
| LD_LIBRARY_PATH | appends /usr/lib/axcl |
| DEFAULT_FFMPEG_VERSION | 8.0 |
| INCLUDED_FFMPEG_VERSIONS | 8.0:7.0:5.0 |
| S6_LOGGING_SCRIPT | T 1 n0 s10000000 T |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |

## Entrypoint / CMD
- ENTRYPOINT ["/init"] (s6-overlay); CMD [].

## Ports
- EXPOSE 5000 (API/UI), 8554 (RTSP), 8555/tcp and 8555/udp (WebRTC).

## Healthcheck
- `--start-period=300s --start-interval=5s --interval=15s --timeout=5s --retries=3`
- CMD: `test -f /dev/shm/.frigate-is-stopping && exit 0; curl --fail --silent --show-error http://127.0.0.1:5000/api/version || exit 1`
- devcontainer stage sets HEALTHCHECK NONE.

## Config/paths
- Frigate app: /opt/frigate (frigate/, migrations/, web/). Config: /config/config.yml (chart mounts it). Media: /media (chart).

## Runtime deps (apt, from install_deps.sh and build stages)
- ffmpeg (multiple versions), nginx (custom build), go2rtc, tempio, s6-overlay, Python 3.11, libusb, sqlite-vec, Intel media driver, optional HailoRT, MemryX, Axera runtimes.

## Gotchas
- Base is debian:12 (bookworm). Build requires BuildKit (`# syntax=docker/dockerfile:1.6`, `--mount` syntax).
- Downloads at build time from GitHub, Coral test_data, TF model, Kaggle (YAMNet), PyPI, and axengine release: network needed.
- install_deps.sh, requirements*.txt, build_*.sh scripts not fetched (in repo under docker/main/).
- Source cloned from commit a19e23ae; release v0.18.3 tag.
