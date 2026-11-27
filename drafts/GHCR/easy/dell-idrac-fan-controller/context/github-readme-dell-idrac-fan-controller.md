# Upstream README: Dell iDRAC fan controller

Source URL(s):
- https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/master/README.md (fetched 2026-11-27; Docker and usage sections, grep)

## Distribution
- Docker Hub: `tigerblue77/dell_idrac_fan_controller` (upstream mirror, not the chart source).
- GitHub Containers: `ghcr.io/tigerblue77/dell_idrac_fan_controller`.
- Supported arch: AMD64, ARM64.

## Usage (local iDRAC)
- `docker run -d --name Dell_iDRAC_fan_controller` (restart flag and any device flag not shown in the grep) with `-e IDRAC_HOST=local`, `FAN_SPEED`, `CPU_TEMPERATURE_THRESHOLD`, `HIGH_FAN_SPEED`, `CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION`, `CPU_TEMPERATURE_SOURCE`, `CHECK_INTERVAL`, `MAXIMUM_IPMI_UNREACHABLE_DURATION`, `MAXIMUM_CONSECUTIVE_IPMI_FAILURES`, `DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE`, `KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT`, `MONITORING_ONLY_MODE`.
- Local mode needs the host's IPMI device (`/dev/ipmi0`) passed to the container.

## Usage (remote iDRAC)
- Same env list with `IDRAC_HOST=<iDRAC IP>`, `IDRAC_USERNAME`, `IDRAC_PASSWORD`.

## Value rules (from README)
| Var | Rule |
| --- | --- |
| FAN_SPEED | 0-100 % or hex `0x00`-`0x64` |
| CPU_TEMPERATURE_THRESHOLD | 20-125 C or `auto` |
| HIGH_FAN_SPEED | 0-100 % or hex, above FAN_SPEED; setting it turns interpolation on |
| CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION | 20-125 C, below CPU_TEMPERATURE_THRESHOLD |
| CPU_TEMPERATURE_SOURCE | `auto`, `ipmi` or `lm-sensors` |
| CHECK_INTERVAL | seconds or suffixed like `5m`, up to 15 minutes |
| MAXIMUM_IPMI_UNREACHABLE_DURATION | seconds or suffixed (`5m`), or empty |
| MAXIMUM_CONSECUTIVE_IPMI_FAILURES | integer >= 1, or empty |

## Account requirement
- The iDRAC account must be an Administrator. Lesser accounts get completion code `0xd4`, same as firmware without the fan commands.

## Firmware notes
- Newer iDRAC 9 firmware (Dell June 2024 release and later) removed the raw fan commands. Downgrade not possible past that release.
- iDRAC 6 (11th gen) may need per-fan addressing (`0xff` refused, falls back to walking IDs `0x00` upward).

## Gotchas
- Fan control is not read-only; the account is used to change fan speed.
