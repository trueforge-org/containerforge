# Hyperion docs: CLI

Source URL: https://docs.hyperion-project.org/user/advanced/CLI.html
Date fetched: 2026-11-26

## hyperiond
| Flag | Purpose |
| --- | --- |
| `--version` | version, build date, commit |
| `--resetPassword` | reset admin password to `hyperion` |
| `--userdata <path>` | override user data dir (default `~/.hyperion`) |
| `-s` / `-i` / `-d` | silent / info / debug log level (temporary) |
| `--export-effects <dir>` | export effects |
| `--desktop` | desktop mode |
| `--readonlyMode` | start read-only |
| `--exportConfig <dir>` | export config (`""` = `~/.hyperion/archive`, `"."` = cwd) |
| `--importConfig <file>` | import HyperionBackup JSON |

- No environment variable documented. Quote paths with spaces.

## hyperion-remote
- Auto-discovers server. Flags: `-c <color>`, `-e <effect>`, `-d <ms>`, `-I <instance>`, `-h`.
- Uses JSON-RPC.

## Capture executables (flatbuffer clients)
hyperion-aml, hyperion-dispmanx, hyperion-framebuffer, hyperion-osx, hyperion-qt, hyperion-v4l2, hyperion-x11, hyperion-xcb. Availability varies by platform.

## hyperion-qt options (selected)
| Flag | Default |
| --- | --- |
| `-d, --display` | 0 |
| `-f, --framerate` | 25 (1-30) |
| `-s, --size-decimator` | 8 |
| `-a, --address` | 127.0.0.1:19400 |
| `-p, --priority` | 150 (100-199 suggested) |
| `--screenshot` | save one frame then exit |

## Ports
- Flatbuffer: 19400 (default).
