# PocketMine docs and project sites (doc.pmmp.io, pmmp.io, poggit)

Source URL(s) + date:
- https://doc.pmmp.io/en/rtfd/installation.html (2026-11-27): static HTML returned site navigation only. Section titles seen: "Setup requirements", "Using the official installer", "Using Docker (Linux only)", "Installing/updating manually", "Opening ports in your firewall", "Forwarding ports in your router", "Plugins". Section bodies not present in the static text.
- https://pmmp.io (2026-11-27): "PocketMine-MP | Farewell", archived homepage.
- https://poggit.pmmp.io/get (2026-11-27): HTML page, reachable. Used by start.sh as `https://poggit.pmmp.io/get/<name>/<version>` to fetch plugin phars.

Facts from these pages: only the section titles above. No install steps, ports, or flags could be extracted from the static HTML.

Gotchas: do not infer install behaviour from the docs; use the Dockerfile and start.sh (github-pocketmine-dockerfile.md).
