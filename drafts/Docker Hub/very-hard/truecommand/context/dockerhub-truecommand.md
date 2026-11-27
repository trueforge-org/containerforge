# Docker Hub: ixsystems/truecommand

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/ixsystems/truecommand/ (2026-11-27)
- https://hub.docker.com/v2/repositories/ixsystems/truecommand/tags?page_size=10 (2026-11-27)

## What it is
- Official iXsystems release images of TrueCommand (closed source, vendor product). Not automated.
- 85 stars, ~13.4M pulls, last_updated 2026-04-10.

## Requirements (from full_description)
- Linux kernel 4.x+.
- x86_64 (64-bit) only.

## Run
```
docker pull ixsystems/truecommand:[TAG]
docker run --detach -v "[hostdirectory]:/data" -p [portnumber]:80 -p [sslportnumber]:443 ixsystems/truecommand:[TAG]
```
- Data dir: `/data` (host bind mount, long-lived).
- Ports documented: 80 (HTTP) and 443 (SSL).

## Initial user
- Default credentials documented: username `admin`, password `admin`.
- First launch opens a first-user creation prompt; the default `admin` account is deactivated after that.

## Tags
- 29 tags. All amd64.

| Tag | Pushed | Digest |
| --- | --- | --- |
| latest | 2026-04-10 | sha256:35a6bb629397... |
| 3.3.0 | 2026-04-10 | sha256:35a6bb629397... |
| 3.2.0 | 2025-11-13 | sha256:19c218455cd2... |
| 3.1.0 | 2025-03-13 | sha256:59022b7f39ef... |
| 3.0.2 | 2024-08-13 | sha256:d2d90dd617ee... |
| 3.0.1 | 2024-03-12 | sha256:df4fe22a1940... |
| 3.0.0 | 2023-12-19 | sha256:8bb4e2467ea4... |
| 3.0.0-BETA1 | 2023-11-09 | sha256:d857fe86a501... |

- `latest` and `3.3.0` share the chart-pinned digest.

## Gotchas
- Default admin/admin credential is documented by the vendor on the public page.
- Release notes live on ixsystems knowledgebase (not fetched).
