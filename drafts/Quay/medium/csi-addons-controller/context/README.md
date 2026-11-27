# Context: Quay/medium/csi-addons-controller

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/csi-addons-controller/values.yaml + Chart.yaml | truecharts-csi-addons-controller.md |
| https://github.com/csi-addons/kubernetes-csi-addons/blob/c9203233.../Dockerfile (+ raw variant) and raw main Dockerfile | csi-addons-kubernetes-csi-addons-dockerfile.md |
| https://api.github.com/repos/csi-addons/kubernetes-csi-addons/contents/Makefile | failed (rate limit); fallback raw main Makefile: csi-addons-makefile.md |
| https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/main/Makefile | csi-addons-makefile.md |
| https://api.github.com/repos/csi-addons/kubernetes-csi-addons | failed (rate limit); fallback github repo page: csi-addons-docs-and-repo.md |
| https://github.com/csi-addons/kubernetes-csi-addons | csi-addons-docs-and-repo.md |
| https://api.github.com/repos/csi-addons/kubernetes-csi-addons/releases/latest | failed (rate limit); fallback releases page: failed (EAI_AGAIN) |
| https://github.com/csi-addons/kubernetes-csi-addons/releases/latest (fallback) | failed (DNS EAI_AGAIN) |
| https://csi-addons.github.io | csi-addons-docs-and-repo.md |
| https://github.com/kubernetes-csi/external-snapshotter | external-snapshotter-readme.md (copied from Other registries/medium/snapshot-controller, same upstream repo) |
| docs/deploy-controller.md (follow-up from repo) | csi-addons-deploy-controller.md |

Skipped categories: none.

## Failures
- api.github.com repos/csi-addons/kubernetes-csi-addons: rate limited (alt = repo page, succeeded).
- api.github.com contents/Makefile: rate limited (alt = raw Makefile, succeeded).
- api.github.com releases/latest: rate limited; alt releases/latest page: DNS EAI_AGAIN (not retried).
- Total: 4 failed fetch attempts.

## plan.md corrections
- None made.
