# Storj node docs (storj.dev; docs.storj.io redirects here)

Source URL(s) + fetch date (all 2026-11-26):
- https://docs.storj.io/node (301 redirect to https://storj.dev/node; redirect followed)
- https://storj.dev/node (overview landing page)
- https://storj.dev/node/get-started/setup (Quickstart landing page)
- https://storj.dev/node/get-started/install-node-software/cli (CLI install landing page)
- https://storj.dev/node/get-started/install-node-software/cli/docker (Docker landing page)

## Result
All five pages are landing or overview pages. None returned hardware requirements, port numbers, identity commands, authorization steps, or a docker run command.

What the pages do say:
- Storj is S3-compatible; operators contribute spare drive space and are paid in USDC.
- Prerequisites: hardware (recommended), system requirements, internet, power. No figures on the page.
- Port forwarding: dynamic DNS is needed for dynamic IPs. No port numbers on the page.
- QUIC: UDP-based protocol; configure it (page has no details).
- Identity: may take hours or days, depending on processing power; a NAS or Raspberry Pi can get an identity generated elsewhere and transferred.
- CLI install: "Before starting" warning; links to prerequisites and "Create an Identity".
- Docker page: Docker must be installed; no run command on the page.
- Code is open source; contributors sign a CLA before contributing.

## Not obtained
- Requirements figures, port list (28967/14002), identity command/flags, authorization step, docker run example, env vars and volumes. The sub-pages referenced (`/node/get-started/identity`, `/node/get-started/install-node-software/cli/storage-node`) were not fetched because the one-level budget was used.
