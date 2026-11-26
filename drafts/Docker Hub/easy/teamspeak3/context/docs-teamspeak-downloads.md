# teamspeak.com downloads page

**Source URL(s)** (fetched 2026-11-26): https://www.teamspeak.com/en/downloads/

## What it is
Vendor downloads page for TeamSpeak clients and servers.

## Server builds listed
- Linux: "Server 64-bit • 3.13.9", "Server 32-bit • 3.13.9"
- Windows (64/32-bit), macOS (64-bit and Apple Silicon/Intel), FreeBSD 64-bit: all 3.13.9
- Docker: "Official Docker image for containerized deployment" -> https://hub.docker.com/_/teamspeak
- TeamSpeak 6 Server Beta is listed separately (no version); binaries/Docker at https://github.com/teamspeak/teamspeak6-server (not the TS3 server the draft uses).

## Not available in fetched content
- Direct file URLs (download buttons have no visible href in the fetched output).
- SHA256 checksums were **not visible** in the fetched page. The plan states the Linux 64-bit SHA256 is `35049b080d23b001d32079eff0be1404f2d9784fbc7457887422ec134c095d5a` (checked 2026-11-25); this could not be re-verified here.
- Licence/EULA text (only a Terms and Conditions link: /en/terms-and-conditions/).

## Version info
3.13.9 for TS3 server.

## Gotchas
- Client-side FFmpeg notice (LGPLv3.0) relates to the client, not the server.
- Linux 32-bit server build exists; plan only uses 64-bit (no arm64 listed here).
