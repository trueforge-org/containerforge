# vatesfr/xen-orchestra (upstream source, release API, docs)

## Source URL(s) + date
- https://raw.githubusercontent.com/vatesfr/xen-orchestra/master/README.md (fetched 2026-11-26)
- https://api.github.com/repos/vatesfr/xen-orchestra/releases/latest (fetched 2026-11-26)
- https://docs.xen-orchestra.com (fetched 2026-11-26, main page only)

## What it is
- XO (Xen Orchestra): web UI, CLI, REST API, Terraform provider for managing XCP-ng / XenServer. No agent needed.
- Licence: AGPL3 (README). Copyright Vates.
- Docs: https://docs.xen-orchestra.com/ (updated daily).

## Install/build
- README: quick start via Vates deploy form (turnkey appliance). Source build not described in README; see ronivay Dockerfile for the build steps (yarn + turbo).

## Release info (releases/latest API)
- Latest release returned: tag `xo-lite-v0.27.0`, name `xo-lite-v0.27.0`, published 2026-10-29T16:49:48Z.
- Asset: `xo-lite-0.27.0.tar.gz` (`https://github.com/vatesfr/xen-orchestra/releases/download/xo-lite-v0.27.0/xo-lite-0.27.0.tar.gz`).
- This is XO Lite, NOT the xo-server version. The API result does not give the xo-server version.

## Docs (main page)
- Describes XO 6 (web UI at `/v6/#/dashboard`), XCP-ng + XO = "Vates VMS".
- Automation: REST API, CLI, Terraform, Ansible.
- Backup repo: S3, NFS, SMB, Azure.

## Ports / env / volumes / user / healthcheck
- Not stated on these pages (see ronivay-xo-dockerfile-run.md for the container).

## Gotchas
- `releases/latest` is the XO Lite tag, so it cannot be used as the XO server version source. Use the xo-server `package.json` version on the pinned commit instead.
- Plan note: README-only check; the plan's "no release binaries" line (plan.md L13) is true for xo-server but the repo does publish an XO Lite tarball on releases.
