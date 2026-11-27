# Context index: apache-musicindex

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apache-musicindex/values.yaml + Chart.yaml | truecharts-apache-musicindex.md |
| http://hacks.slashdirt.org/sw/musicindex/ (alt. for http://hacks.slashdirt.org/musicindex) | upstream-slashdirt-musicindex.md |
| https://packages.ubuntu.com/resolute/amd64/libapache2-mod-musicindex/download (+ arm64) | ubuntu-packages-musicindex.md |

Skipped categories: homepage/mirror pages on packages.ubuntu.com (covered by download pages), the packages.ubuntu.com overview page (see failures), arm64 duplicate of the same package (covered in the same file).
Docker Hub: https://hub.docker.com/v2/repositories/k8s-at-home/apache-musicindex/ returned "object not found". Image is GHCR (`ghcr.io/k8s-at-home/apache-musicindex`), so no Docker Hub file.

Failures:
- http://hacks.slashdirt.org/musicindex: 404. Alternative used: /sw/musicindex/ (ok).
- https://packages.ubuntu.com/resolute/libapache2-mod-musicindex: connection failed. Alternative used: amd64 download page (ok).
- Docker Hub API for k8s-at-home/apache-musicindex: object not found (no alternative fetched).

## plan.md corrections
- None verified as wrong. Plan's note "Upstream homepage could not be fetched (TLS name mismatch)" is stale: http://hacks.slashdirt.org/sw/musicindex/ answered 200 with version 1.4.1 and LGPLv2.1. Not edited (note only).
