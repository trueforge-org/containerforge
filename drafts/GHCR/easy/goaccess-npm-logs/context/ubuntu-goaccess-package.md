# Ubuntu package goaccess (resolute)

## Source URL(s) + date

- https://packages.ubuntu.com/resolute/goaccess
- Fetched 2026-11-27

## Facts

| Item | Value |
| --- | --- |
| Suite | resolute (26.04 LTS) |
| Package | `goaccess` `1:1.9.4-1` |
| Source files | goaccess_1.9.4-1.dsc, goaccess_1.9.4.orig.tar.xz, goaccess_1.9.4-1.debian.tar.xz |
| Architectures listed | amd64, arm64 |
| Homepage | goaccess.io |

- Epoch `1:` must be stripped for version checks (apt shows `1:1.9.4-1`; binary version `1.9.4`).

## Gotchas

- Apt version (1.9.4) is older than the wrapper's bundled GoAccess 1.10.2 (see goan-wrapper-dockerfile-start.md).
