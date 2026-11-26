# codeproject.github.io/codeproject.ai/install/install_on_linux.html (Linux install docs, v2.9.5)

Source URL(s) + fetch date:
- https://codeproject.github.io/codeproject.ai/install/install_on_linux.html · fetched 2026-11-26
- https://codeproject.github.io/codeproject.ai/ (docs home) · fetched 2026-11-26

## Package and arch
- Download the latest installation package: **x64 (Intel) or arm64** (e.g. Raspberry Pi, Orange Pi). Format is a **.deb** (unzip the download, then install with dpkg or the GUI).
- Example given: `sudo dpkg -i codeproject.ai-server_2.9.1_Ubuntu_x64.deb` (example version 2.9.1 on a v2.9.5 page; inconsistency noted).
- Per-version deb naming: `codeproject.ai-server_<version>_Ubuntu_<x64|arm64>.deb` (matches plan's zip-contained deb).

## Dependencies and steps
- NVIDIA GPU: latest CUDA drivers.
- .NET: `sudo apt update && sudo apt install dotnet-sdk-9.0` (docs use the SDK package, not runtime-only).
- Post-install step (after .NET is installed): `pushd "/usr/bin/codeproject.ai-server-2.9.1/server" && bash ../setup.sh && popd`.
- Manual start: `bash /usr/bin/codeproject.ai-server/start.sh`.
- Uninstall: `sudo dpkg -r codeproject.ai-server`.
- Sudo needed for apt, dpkg install and dpkg remove.

## Service behaviour
- The deb install runs the server under **systemd**; it starts after install and restarts on reboot.

## Ports / UI
- Dashboard `http://localhost:32168`; Explorer sample `http://localhost:32168/explorer.html`.

## Not covered on this page
Config/data paths (such as `/etc/codeproject/ai`), modules directory, Docker details (separate "CodeProject.AI in Docker" page), env vars.

## Docs home (https://codeproject.github.io/codeproject.ai/)
- Free, open-source AI server, "any platform, any language"; REST API server plus backend analysis services; source included. Runs locally, no off-device transfer.
- Capabilities: object/face/scene detection, face recognition, face-to-anime, text and licence-plate reading, summarisation, background removal/blur, sentiment.
- Page is for v2.9.5. Windows installer and Docker builds ship **only object detection modules**; other modules are installed from the dashboard **at runtime** (confirms plan's runtime module install).
- Docs links: Docker (`install/running_in_docker.html`), Docker FAQ (`faq/docker.html`), Docker Hub. Modules (`features/modules.html`), module settings (`api/module_settings.html`), API reference (`api/api_reference.html`), release notes (`about/release-notes.html`).
