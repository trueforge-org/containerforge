# Upstream Dockerfile and entry scripts: Dell iDRAC fan controller

Source URL(s):
- https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/24fa182fa86f5c247466f023316939096b96042d/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/24fa182fa86f5c247466f023316939096b96042d/supervisor.sh (fetched, head only)
- https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/24fa182fa86f5c247466f023316939096b96042d/healthcheck.sh (fetched, head only)

## What it is
- Bash scripts running in an Ubuntu image. Licence AGPL-3.0-only (LICENSE, LICENSE-COMMERCIAL.md, NOTICE copied into `/app`).

## Build steps
- `ARG BASE_IMAGE=ubuntu:latest`, `FROM ${BASE_IMAGE}` (ContainerForge should use its own base, not this).
- One RUN: `apt-get update && apt-get install --no-install-recommends ipmitool lm-sensors perl libio-socket-ssl-perl -y && rm -rf /var/lib/apt/lists/*`.
- `ADD` LICENSE, LICENSE-COMMERCIAL.md, NOTICE to `/app/`.
- `ADD` functions.sh, constants.sh, healthcheck.sh, Dell_iDRAC_fan_controller.sh, supervisor.sh to `/app/`.
- `RUN chmod 0755` on functions.sh, healthcheck.sh, Dell_iDRAC_fan_controller.sh, supervisor.sh.
- Upstream note: the monitoring script is started through `bash`, because its file mode in git is 644 and only the image's chmod makes it runnable.

## Runtime deps
- ipmitool, lm-sensors, perl, libio-socket-ssl-perl (HTTPS for Redfish). No curl/wget/openssl/python3 in the image.

## Entrypoint/flags
- ENTRYPOINT `["./supervisor.sh"]`, WORKDIR `/app`, no CMD.
- supervisor.sh is PID 1. Runs `bash ./Dell_iDRAC_fan_controller.sh` (or the given command). On exit without a clean handoff, it applies Dell's default fan profile.
- HEALTHCHECK `--interval=30s --timeout=30s --start-period=5s --retries=3 CMD ["/app/healthcheck.sh"]`. healthcheck.sh checks the monitoring loop is still reporting within CHECK_INTERVAL.

## Env vars (Dockerfile ENV defaults)
| Name | Default |
| --- | --- |
| IDRAC_HOST | local |
| FAN_SPEED | 5 |
| CPU_TEMPERATURE_THRESHOLD | auto |
| CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION | 30 |
| CPU_TEMPERATURE_SOURCE | auto |
| CHECK_INTERVAL | 5 |
| MAXIMUM_IPMI_UNREACHABLE_DURATION | 60s |
| MAXIMUM_CONSECUTIVE_IPMI_FAILURES | (empty) |
| DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE | false |
| KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT | false |
| MONITORING_ONLY_MODE | false |

Commented out (no default, user-set): IDRAC_USERNAME, IDRAC_PASSWORD, HIGH_FAN_SPEED (setting it turns on line interpolation).

## Ports
- None exposed.

## Volumes/paths
- `/app` holds scripts and licence files. No VOLUME.

## User/UID
- No USER line: runs as root.

## Labels
- `org.opencontainers.image.licenses="AGPL-3.0-only"`, plus title/description/source/url.

## Gotchas
- Scripts are not executable in git (644). Container relies on `chmod 0755` in the image and `bash` invocation.
- `IDRAC_HOST=local` is the in-server default (uses local IPMI `/dev/ipmi0`, host device needed).
- Upstream image is Ubuntu, not Alpine. Build base is ubuntu:latest by default.
- Source files are AGPL; the image must carry LICENSE and NOTICE (upstream does).
