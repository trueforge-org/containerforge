# Docker Hub: rroemhild/mailpile

Source URL(s), fetched 2026-11-27:
- https://hub.docker.com/v2/repositories/rroemhild/mailpile/
- https://hub.docker.com/v2/repositories/rroemhild/mailpile/tags?page_size=10

## Repository
- Namespace `rroemhild`, name `mailpile`, public, automated build: true
- Description: "A minimal Mailpile Docker image based on Alpine Linux."
- Status: 6, described as **archived**
- Pull count 1,260,423; stars 15
- Registered 2015-06-02; last modified 2025-04-01; last updated 2020-12-11
- Storage ~4.18 GB

## Tags
| Tag | Last updated | Full size | Arch / os |
| --- | --- | --- | --- |
| latest | 2020-12-11 | 54474626 | amd64 / linux only |

- Only 1 tag exists in the API response (count 1). No arm or other variants.

## Run config (from repo description)
- Image runs detached with name `mailpile`.
- Ports: 33411:33411 (host:container).
- Volumes (bind-mounted to host paths of choice):
  - `/root/.local/share/Mailpile`: Mailpile data
  - `/root/.gnupg`: GPG keys and config
- Compose example: version 3, service `mailpile`, same image, the two volumes and port 33411:33411.

## Gotchas
- Image is archived and the only tag was last pushed 2020-12-11. It is amd64-only, so any new build will not be a like-for-like replacement.
- Paths are under /root, so the image expects root HOME.
