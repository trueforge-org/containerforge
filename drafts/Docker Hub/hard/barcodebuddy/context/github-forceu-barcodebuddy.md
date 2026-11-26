# Forceu/barcodebuddy (upstream application)

**Source URL(s) + fetch date:** https://github.com/Forceu/barcodebuddy (raw `master/README.md`, https://github.com/Forceu/barcodebuddy/releases/tag/v1.9.0.1, raw `master/LICENSE.md`); https://github.com/Forceu/barcodebuddy/blob/master/LICENSE returned 404 · fetched 2026-11-26

## What it is
Barcode Buddy works with Grocy. Barcodes scanned are consumed, added, or opened in Grocy. Unknown barcodes: product name looked up and picked in the Web UI. Saved tags can preselect a product.

## Availability
Bare metal, Android client, Docker (page warns "Image name has changed!"), Kubernetes and Home Assistant (community support).

## Requirements
PHP-capable web server (NGINX or Apache) or Docker; a Grocy API key; ideally a barcode scanner or Android device.

## Install/build steps
Docker details are in `Forceu/barcodebuddy-docker` (see `github-forceu-barcodebuddy-docker.md`). Documentation: https://barcodebuddy-documentation.readthedocs.io/en/latest/ (not fetched).

## Runtime / env / ports / volumes
README does not include a Docker run command, env vars, ports, volumes, device or input requirements, or a default login.

## Usage notes
Barcodes can be added manually or captured from scanner input. Behind a reverse proxy, disable caching (see setup docs).

## Lookup sources
openfoodfacts.org and upcitemdb.com. Credits PHP-Auth, NoSleep.js, SortableJS.

## Licence
README: "AGPL3+ (see LICENSE.md)". `LICENSE.md` is the GNU AGPL version 3 text ("or any later version" only applies if a program's notice says so). Plan.md's `AGPL-3.0` vs `-or-later` decision remains with the author's file headers (not checked here).

## Version/release info
- Latest release `v1.9.0.1`, marked Latest, 25 Sep (year not shown), 16:12, commit `98a8649` (signed by Marc Bulling).
- Release note: fixed a bug that blocked setting up a new instance (issue #299).
- Release shows "2 assets"; names did not load. These are likely the auto-generated source archives (plan.md says no uploaded assets). Not confirmed.

## Gotchas
- Repository `LICENSE` at `blob/master/LICENSE` returned 404; `LICENSE.md` exists.

## Contradictions with plan.md
- plan.md License row: "UNVERIFIED: not re-read from the LICENSE file". Now: `LICENSE.md` is AGPL v3 text; README says "AGPL3+". Left as UNVERIFIED in plan.md for the -only vs -or-later choice.
- plan.md Download row: "The latest release shows no uploaded assets via the GitHub API". The release page shows "2 assets" (names not loaded). Probably the auto source archives; not a conflict confirmed.
