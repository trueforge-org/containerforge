# aMule project site (amule-org.github.io) and docs

## Source URL(s) + date
- https://amule-org.github.io (2026-11-27, HTTP 200)
- https://amule-org.github.io/docs (2026-11-27, HTTP 200; index only)

## What it is
- aMule: free, GPL-licensed P2P file-sharing client for eD2k and Kademlia networks. Compatible with eMule. Runs on Windows, macOS, Linux, FreeBSD, OpenBSD.
- Home page: "aMule 3.2.0 is out". Ships x64 and ARM64 builds, and fully static headless binaries for Linux servers.
- License: GPL-2.0 (per home page text). plan.md says SPDX unverified; this page states GPL-2.0.

## Docs index (sections, no sub-pages followed)
- Overview, Quick Start, User Manual, Installation, Configuration, Interfaces.
- Interfaces: GUI (amule and amulegui), amuled (headless daemon), amuleapi (REST API and Web UI), amulecmd (CLI), amuleweb (legacy WebUI).
- Utilities, Migration, Troubleshooting, FAQ, Developer Guide (P2P networks, Contributing).

## Gotchas
- Docs index gives no port, path or env values; sub-pages (amuled, amuleweb, configuration) not followed (budget).
- Docs mark amuleweb as "Legacy WebUI" and amuleapi as "REST API & Web UI" (relevant when choosing which web interface the container runs).
