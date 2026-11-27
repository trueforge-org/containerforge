# tphakala/birdnet-go Dockerfile + Docker/entrypoint.sh (commit bc1e0de67d9a2292b4742a79f868a7720f8e6a12)

Source URL(s) + date: https://raw.githubusercontent.com/tphakala/birdnet-go/bc1e0de67d9a2292b4742a79f868a7720f8e6a12/Dockerfile ; .../Docker/entrypoint.sh (fetched 2026-11-27)

## Stages
| Stage | Base |
| --- | --- |
| buildenv | `golang:1.27-trixie` (apt, nodejs, dev-user UID 10001) |
| build | buildenv (compiles bin/, reset_auth.sh, Docker/entrypoint.sh, startup-wrapper.sh) |
| runtime-base | `debian:trixie-slim` (apt runtime libs; ONNX Runtime, TFLite, OpenVINO, Intel NEO/IGC) |
| models-amd64 / models-arm64 | scratch, copy `*.tflite` (amd64) or `*.onnx` (arm64) from build |
| final | `${BASE_IMAGE}` (default `runtime-base`) |

- Versions (ARG defaults): TENSORFLOW 2.17.1, TFLITE v2.17.1, ONNXRUNTIME 1.25.1, OPENVINO 2026.2 (build 2026.2.0.21903.52ddc073857, sha256 per arch), NEO 26.22.38646.4, IGC 2.36.3+21719 (tag v2.36.3), GMMLIB 22.10.0; legacy NEO 24.35.30872.22, IGC igc-1.0.17537.20.
- Build args: BUILD_VERSION, SENTRY_DSN, PROJECT_NAME, PROJECT_REPO_URL, PROJECT_COMMUNITY_URL.

## Final stage
- Copies: /models/ (arch models), /usr/bin/reset_auth.sh, /usr/bin/entrypoint.sh, /usr/bin/startup-wrapper.sh (chmod 755), /usr/bin/ (go binaries from build/bin).
- `RUN mkdir -p /config /data/clips /data/models && chmod 777 /config /data /data/clips /data/models`.
- `VOLUME /config`, `VOLUME /data`, `WORKDIR /data`.
- `EXPOSE 80 443 8080 8090`.
- No USER line in the final stage (entrypoint handles privileges).
- HEALTHCHECK: `--interval=30s --timeout=10s --start-period=120s --retries=3`, curl to `http://localhost:${P}/health` (P from BIRDNET_WEBSERVER_PORT, default 8080) or https on TLS port (BIRDNET_SECURITY_TLSPORT, default 8443); requires JSON `.status == "healthy"`; uses jq.
- ENTRYPOINT: `["/usr/bin/tini", "-s", "--", "/usr/bin/entrypoint.sh", "/usr/bin/startup-wrapper.sh"]`
- CMD: `["birdnet-go", "realtime"]`
- Labels: usage example `docker run ... -p 8080:8080 -v ./config:/config -v ./data:/data --device /dev/snd:/dev/snd`; podman rootless `keep-id`.

## Env (startup)
| Env | Default | Use |
| --- | --- | --- |
| BIRDNET_UID / BIRDNET_GID | 1000 / 1000 | file ownership |
| BIRDNET_STARTUP_FAIL_DELAY | 10 | seconds before exit on error |
| TZ | unset | timezone |
| BIRDNET_MODELPATH | unset | custom model path |
| BIRDNET_WEBSERVER_PORT | 8080 | healthcheck port |
| BIRDNET_SECURITY_TLSPORT | 8443 | healthcheck TLS port |
| SKIP_CHOWN | unset | skip chown of /config and /data |
| SKIP_DEVICE_PERMS | unset | skips device permission handling (exact scope not read) |

## Entrypoint (Docker/entrypoint.sh, 333 lines)
- check_and_chown: chowns /config (recursive) and /data (plus items one level deep) to APP_UID:APP_GID when mismatched.
- Creates /config, /data/clips, /data/models.
- Rootless: detects user namespace (ROOTLESS_USERNS, PROC_UID_MAP), sets HOME=/config when needed.
- Device access: group handling for DRI devices (vars RENDER_GID, DRM_GROUP, DRI_DEVICE; exact logic not read).
- Pre-flight: disk space check (REQUIRED_SPACE_MB, DATA_SPACE_MB), writability of config.
- Model permissions: chmod a+r on model files, a+rx on model dirs.

## Gotchas
- Container starts as root (no USER in final), entrypoint drops to BIRDNET_UID:BIRDNET_GID.
- Model files ~116 MB; first start loads models (plan notes startup timing UNVERIFIED).
- The upstream image is Debian trixie (glibc).
