# Source: mkvtoolnix.download apt repository (ubuntu)

Source URL(s) + date: https://mkvtoolnix.download/ubuntu/ (200, directory listing, fetched 2026-11-27)

## Facts
- Apt repo layout: `./dists/` and `./pool/` directories under /ubuntu/.
- https://mkvtoolnix.download/ubuntu (no trailing slash): HTTP 404. Use the trailing-slash form.
- GPG key URL in urls.txt (https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg) not fetched (binary).
- /doc (https://mkvtoolnix.download/doc) fetched: HTML manual index, not summarized (not needed for build facts).

## Gotchas
- Package versions in the apt pool not checked here; verify package names/versions per the plan's apt steps.
