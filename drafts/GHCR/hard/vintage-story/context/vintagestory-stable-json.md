# Vintage Story: stable channel version feed

Source URL(s) + date: http://api.vintagestory.at/stable.json (fetched 2026-11-27)

## Latest stable
- Newest key: `1.22.7` (`latest: 1` on each platform entry).
- Previous key present: `1.22.6`.

## Linux server asset (`linuxserver` key)
| Version | Filename | Size | MD5 |
| --- | --- | --- | --- |
| 1.22.7 | vs_server_linux-x64_1.22.7.tar.gz | 51.4 MB | 3031212903b1c283084d5fe0cda6bce6 |
| 1.22.6 | vs_server_linux-x64_1.22.6.tar.gz | 51.4 MB | 84c59ac1bd4a3ceb7e0b040a0e90428f |

- CDN URL pattern: `https://cdn.vintagestory.at/gamefiles/stable/<filename>`.
- Local mirror pattern: `https://account.vintagestory.at/files/stable/<filename>`.

## Other keys (1.22.7)
- `linux` client tarball `vs_client_linux-x64_1.22.7.tar.gz` (590.5 MB), `windows`, `windowsupdate`, `windowsserver` (zip), `mac-x64`, `mac-arm64`.

## Gotchas
- Server asset is `linuxserver`, not `linux` (client). Use the `linuxserver` filename for server builds.
- JSON is keyed by version; the `latest` flag marks the current stable.
