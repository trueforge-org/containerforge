# Context: Other registries/medium/snapshot-controller

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snapshot-controller/values.yaml + Chart.yaml | truecharts-snapshot-controller.md |
| https://hub.docker.com/v2/repositories/library/golang/ and /tags?page_size=10 (via registry.hub.docker.com) | dockerhub-golang.md |
| https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v8.7.0/cmd/snapshot-controller/Dockerfile (blob variant) + go.mod + LICENSE | external-snapshotter-controller-dockerfile.md |
| https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v8.7.1 | external-snapshotter-controller-dockerfile.md (Release section) |
| https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/README.md | external-snapshotter-readme.md |
| https://kubernetes-csi.github.io/docs | kubernetes-csi-docs-index.md |
| https://kubernetes-csi.github.io/docs/external-snapshotter.html | kubernetes-csi-docs-external-snapshotter.md |
| https://kubernetes-csi.github.io/docs/snapshot-controller.html | kubernetes-csi-docs-snapshot-controller.md |

Skipped categories: none of the template-only or binary-download URLs in this list (the list was already filtered); plan-referenced Chart sources resolved via TrueCharts raw files.

## Failures
- https://github.com/snapshot-controller/snapshot-controller: HTTP 404 (WebFetch); raw README on main and master also 404 (one alternative tried).
- https://github.com/snapshot-controller/snapshot-controller-helm-chart: HTTP 404 (WebFetch); no alternative fetched.
- https://api.github.com/repos/kubernetes-csi/external-snapshotter/releases/latest: returned no tag_name (no alternative fetched beyond the release tag page above).
- https://hub.docker.com/v2/repositories/library/golang/: DNS EAI_AGAIN; used registry.hub.docker.com alternative (succeeded).

## plan.md corrections
- None made. Upstream docs are stale (release-6.2 / v8.2.0) and the registry names are k8s.gcr.io in the README; not proof of a plan error.
