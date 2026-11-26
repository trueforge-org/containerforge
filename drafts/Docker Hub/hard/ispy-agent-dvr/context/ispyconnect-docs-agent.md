# iSpy Agent DVR docs (Linux)

Source URL(s): https://www.ispyconnect.com/docs/agent. Fetched 2026-11-26.

## Platform
- Windows 10+, Linux x64 (Ubuntu), macOS, ARM (Raspberry Pi). No Linux min hardware/RAM stated.

## Install
- No fresh Linux install command on page; points to /download.
- Legacy: `curl -sL "https://www.ispyconnect.com/install" | bash -s -- -v 5800` (v5.8.0.0 example).

## Ports
- 8090 TCP/UDP UI (changes if 8090 taken; see `Agent/Media/XML/current_port.txt`)
- 3478 TCP/UDP STUN/TURN
- 50000-50100 TCP/UDP relay (optional)

## Paths
- Config XML: `Agent/Media/XML` (relative to install dir; install dir = where script run)
- Imported content (7.1.5.0+) copied to Agent media storage (mp4, mp3, mkv, jpg).

## Service (systemd)
- Service name `AgentDVR.service`; page documents stop and disable only.

## Deps
- libgdiplus and other system packages not mentioned. FFmpeg on separate page (/docs/agent/ffmpeg-install).
