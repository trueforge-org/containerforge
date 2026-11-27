# jlesage/docker-handbrake: Dockerfile (v26.09.1) + README

Source URL(s): https://raw.githubusercontent.com/jlesage/docker-handbrake/v26.09.1/Dockerfile (fetched 2026-11-27; blob/v26.09.1 variant is same file). README: https://raw.githubusercontent.com/jlesage/docker-handbrake/v26.09.1/README.md (follow-up, same repo). Upstream HandBrake repo HTTP 200 (not read).

## Build (Dockerfile v26.09.1)
- ARGs: HANDBRAKE_VERSION=1.11.2, LIBVA_VERSION=2.23.0, INTEL_VAAPI_DRIVER_VERSION=2.4.1, GMMLIB_VERSION=22.9.0, INTEL_MEDIA_DRIVER_VERSION=25.4.6, INTEL_MEDIA_SDK_VERSION=23.2.2, INTEL_ONEVPL_GPU_RUNTIME_VERSION=25.4.6, CPU_FEATURES_VERSION=0.11.0, HANDBRAKE_DEBUG_MODE=none, DOCKER_IMAGE_VERSION (build arg).
- Stages: xx (tonistiigi/xx) helper; handbrake (alpine:3.20, src/handbrake/build.sh, tarball HandBrake-<ver>-source.tar.bz2 from GitHub releases; xx-verify ghb + HandBrakeCLI); cpu_features (alpine:3.20, google/cpu_features v0.11.0).
- Final base: `jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
- add-pkg: libstdc++ gtk4.0 gst-plugins-good gst-libav libgudev libnotify libsamplerate libass libdrm jansson xz numactl libturbojpeg libtheora lame-libs opus libvorbis speex libvpx x264-libs pciutils libdvdcss font-cantarell librsvg adwaita-icon-theme lsscsi bash coreutils findutils expect xdpyinfo.
- install_app_icon.sh from jlesage/docker-templates icon URL (third-party, build-time).
- COPY rootfs/ /; handbrake-install -> /; list_cpu_features -> /usr/bin/.
- set-cont-env: APP_NAME HandBrake, APP_VERSION $HANDBRAKE_VERSION, DISABLE_GLX 1.
- Version: HandBrake 1.11.2 (app), image tag from git tag v26.09.1 (DOCKER_IMAGE_VERSION).

## Env (image defaults, Dockerfile)
| Name | Default |
| --- | --- |
| HANDBRAKE_DEBUG | 0 |
| HANDBRAKE_GUI | 1 |
| HANDBRAKE_GUI_QUEUE_STARTUP_ACTION | NONE |
| AUTOMATED_CONVERSION | 1 |
| AUTOMATED_CONVERSION_PRESET | General/Very Fast 1080p30 |
| AUTOMATED_CONVERSION_FORMAT | mp4 |
| AUTOMATED_CONVERSION_SOURCE_STABLE_TIME | 5 |
| AUTOMATED_CONVERSION_SOURCE_MIN_DURATION | 10 |
| AUTOMATED_CONVERSION_SOURCE_MAIN_TITLE_DETECTION | 0 |
| AUTOMATED_CONVERSION_KEEP_SOURCE | 1 |
| AUTOMATED_CONVERSION_WATCH_DIR | AUTO |
| AUTOMATED_CONVERSION_OUTPUT_DIR | /output |
| AUTOMATED_CONVERSION_OUTPUT_SUBDIR | (empty) |
| AUTOMATED_CONVERSION_OVERWRITE_OUTPUT | 0 |
| AUTOMATED_CONVERSION_NON_VIDEO_FILE_ACTION | ignore |
| AUTOMATED_CONVERSION_NON_VIDEO_FILE_EXTENSIONS | jpg jpeg bmp png gif txt nfo |
| AUTOMATED_CONVERSION_MAX_WATCH_FOLDERS | 5 |
| AUTOMATED_CONVERSION_CHECK_INTERVAL | 5 |
| AUTOMATED_CONVERSION_NO_GUI_PROGRESS | 0 |
| AUTOMATED_CONVERSION_USE_TRASH | 0 |
| AUTOMATED_CONVERSION_TRASH_DIR | /trash |

## README runtime env (selected)
| Name | Default | Note |
| --- | --- | --- |
| USER_ID / GROUP_ID | 1000 / 1000 | run-as user |
| SUP_GROUP_IDS | (none) | |
| WEB_LISTENING_PORT | 5800 | -1 disables web |
| VNC_LISTENING_PORT | 5900 | -1 disables VNC |
| VNC_PASSWORD | (none) | |
| SECURE_CONNECTION | 0 | 1 = HTTPS/VNC encrypted |
| SECURE_CONNECTION_VNC_METHOD | SSL | SSL or TLS |
| WEB_AUTHENTICATION | 0 | |
| WEB_AUTHENTICATION_USERNAME / PASSWORD | (none) | |
| WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME | 24 | hours |
| VNC_LOCALHOST_ONLY | 0 | |
| ENABLE_CJK_FONT | 0 | |

## Ports
- 5800 (web GUI), 5900 (VNC). Dockerfile EXPOSE not seen (tail not fetched).

## Volumes/paths
| Path | Mode | Purpose |
| --- | --- | --- |
| /config | rw | app config, logs (/config/log/hb/) |
| /storage | ro | host input files |
| /output | rw | converted output |
| /watch | - | VOLUME in Dockerfile (watch folder) |
| /trash | - | VOLUME in Dockerfile (AUTOMATED_CONVERSION_USE_TRASH) |

## User/UID
- Default USER_ID 1000, GROUP_ID 1000 (README); base image GUI runs app as that user (root for init).

## Healthcheck
- Not seen in fetched portion.

## Gotchas
- Chart's appVersion (26.11.2) differs from this Dockerfile's pinned tag v26.09.1 (urls.txt); the chart's image tag v26.11.2 has no source fetched here.
- Dockerfile uses build-time GitHub downloads (HandBrake source tarball, Intel libva/driver, cpu_features) and a third-party icon URL.
- Requires GUI base (jlesage/baseimage-gui) and runs with /storage read-only.
