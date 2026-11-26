# tenstartups/ser2sock entrypoint.sh (+ repo README)

Source URL(s): https://github.com/tenstartups/ser2sock (README one-liner: "Ser2sock application for allowing IP access to a serial device"); https://raw.githubusercontent.com/tenstartups/ser2sock/master/entrypoint.sh (fetched 2026-11-26). Repo URL root not separately fetched beyond raw README.

## entrypoint.sh (full content summary)
- `#!/bin/sh`, `set -e`
- Requires `SERIAL_DEVICE`; if empty: prints "You must specify the SERIAL_DEVICE environment variable." to stderr, exit 1
- Final line: `exec ser2sock -f -p ${LISTENER_PORT} -s ${SERIAL_DEVICE} -i 0.0.0.0 -b ${BAUD_RATE}`

## Env used by entrypoint
| Name | Required | Used as |
| --- | --- | --- |
| SERIAL_DEVICE | yes (exit 1 if empty) | `-s` serial device, e.g. /dev/ttyUSB0 |
| LISTENER_PORT | (Dockerfile default 10000) | `-p` |
| BAUD_RATE | (Dockerfile default 9600) | `-b` |

## Gotchas
- Entrypoint passes `-f` (upstream usage: `-f <config pathname>`). `-f` is followed by `-p`, so the option parser may treat `-p` as the config path. UNVERIFIED against binary; check when building.
- Bind is fixed to 0.0.0.0.
