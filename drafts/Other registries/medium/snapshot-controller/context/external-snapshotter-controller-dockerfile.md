# kubernetes-csi/external-snapshotter (v8.7.0) cmd/snapshot-controller/Dockerfile + go.mod + LICENSE

Source URL(s): https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v8.7.0/cmd/snapshot-controller/Dockerfile (blob variant listed in urls.txt maps to this raw file), .../v8.7.0/go.mod, .../v8.7.0/LICENSE (fetched 2026-11-27)

## Dockerfile (verbatim essentials)
```
FROM gcr.io/distroless/static:latest
LABEL maintainers="Kubernetes Authors"
LABEL description="Snapshot Controller"
ARG binary=./bin/snapshot-controller
COPY ${binary} snapshot-controller
ENTRYPOINT ["/snapshot-controller"]
```
- Build stage: none. Expects a pre-built static binary at ./bin/snapshot-controller.
- Runtime base: gcr.io/distroless/static:latest (unpinned). No USER directive in the Dockerfile.
- Binary path inside image: /snapshot-controller.

## go.mod
- module github.com/kubernetes-csi/external-snapshotter/v8
- go 1.26.0

## License
- Apache License 2.0.

## Release (v8.7.1)
- Tag v8.7.1 marked latest, published 23 Nov (year not shown), commit 9aea5b8.
- Release page: assets count 2, names not readable. Container images "To be released."
- Compatibility: CSI spec 1.0-1.13; min and recommended Kubernetes 1.25.
- Full changelog: CHANGELOG/CHANGELOG-8.7.md in the tag.

## Gotchas
- Docs site (kubernetes-csi.github.io) still shows release-6.2 install steps and v8.2.0 image tags; treat as stale.
- api.github.com releases/latest returned no tag_name (fetch failed, see README).
