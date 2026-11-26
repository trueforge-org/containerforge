# Docker Hub: epoupon/fileshelter

Source URL(s) + fetch date:
- https://hub.docker.com/r/epoupon/fileshelter (fetched 2026-11-26)

## What it is

Self-hosted file-sharing tool: upload files, receive a link. 50K+ pulls. Pull command `docker pull epoupon/fileshelter`.

## Tags and arch

- `latest` only shown; updated 9 months ago; digest `sha256:6524840f...`; 14.6 MB.
- Architectures: not listed on the page.
- Chart pins `6.4.0@sha256:6524840f2501d8e5362200c4bf4379d6f84416211d37900171d111110c77e83a`.

## Ports

- Container port 5091 (`-p <port>:5091`).

## Volumes

- `<path_to_persistent_data>:/var/fileshelter` (working data, needs write access).
- Optional bind mount of a custom config to `/etc/fileshelter.conf` (replaces the default config).

## Env vars

- None mentioned.

## Run example

- `--name=fileshelter`, `--user <user_id:group_id>`, `--restart unless-stopped`.

## Gotchas

- Hub docs and upstream both use `/var/fileshelter` for data (plan maps this to `/config` through the seeded config's `working-dir`).
