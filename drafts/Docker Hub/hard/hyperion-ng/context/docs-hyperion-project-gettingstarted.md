# Hyperion docs: landing and getting started

Source URLs:
- https://docs.hyperion-project.org (landing, fetched 2026-11-26, no install facts)
- https://docs.hyperion-project.org/user/gettingstarted/Overview.html (fetched 2026-11-26)

## Supported systems
- Raspberry Pi (HyperBian image), Debian 11, Ubuntu 22.04, Fedora 39+, macOS (Intel/Apple Silicon), Windows 11.
- Browsers: Chrome 47+, Firefox 43+, Opera 34+, Safari 9.1+, Edge 14+.
- Some ARM devices have limited screen-capture support.
- Other OS: build from source (`CompileHowto.md` in hyperion.ng repo).

## Running (Linux service)
| Item | Detail |
| --- | --- |
| Headless | service installed automatically, runs as current user |
| GUI | no service by default; create manually |
| Root | some setups (ws281x LEDs) need root |

| Task | Command |
| --- | --- |
| Run as root | `sudo updateHyperionUser -u root` |
| Run as current user | `sudo updateHyperionUser` |
| Copy service file | `sudo cp /usr/share/hyperion/service/hyperion.systemd /etc/systemd/system/hyperion@.service` |
| Status | `systemctl status hyperion@${USER}` |

## Data and config
| Item | Value |
| --- | --- |
| User data dir | `.hyperion` in the running user's home |
| Contents | user config and custom effects |
| Config file name | not stated |

## Not stated in these pages
- deb/tar file names, Docker guidance, ports (web, JSON, Protobuf, flatbuffer, boblight), environment variables, binary start command.
- Landing page links: Configuration (`/user/Configuration.html`), CLI (`/user/advanced/CLI.html`), Advanced, JSON API `https://api.hyperion-project.org`.
- Landing page: MIT license.
