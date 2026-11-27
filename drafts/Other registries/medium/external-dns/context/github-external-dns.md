# kubernetes-sigs/external-dns v0.24.0 (README and go.mod)

## Source URL(s) + date
- https://raw.githubusercontent.com/kubernetes-sigs/external-dns/v0.24.0/README.md (fetched 2026-11-27)
- https://raw.githubusercontent.com/kubernetes-sigs/external-dns/v0.24.0/go.mod (fetched 2026-11-27)
- https://kubernetes-sigs.github.io/external-dns/latest/ (alternative for the docs site; fetched 2026-11-27)

## What it is
- ExternalDNS synchronizes Kubernetes Services (type LoadBalancer), Ingresses, and nodes with DNS providers, for selected zones (`--domain-filter`).
- Runs as a controller in cluster; can run locally with flags or env.

## Run / config
- All flags can be set as env vars, e.g. `--dry-run` -> `EXTERNAL_DNS_DRY_RUN=1`.
- Recommended: `--txt-owner-id` set to a stable unique value; `--dry-run` to preview.
- Policy: `--policy=sync` deletes records; `--policy=upsert-only` never deletes.
- Example single run: `external-dns --txt-owner-id my-cluster-id --provider google --google-project example-project --source service --once --dry-run`.
- Sources set via `--source` (README links docs/sources).
- Providers: in-tree list is being moved out of tree; new providers via webhook system.

## go.mod
- Module `sigs.k8s.io/external-dns`, `go 1.27.3`.
- Notable pins: `github.com/cloudflare/cloudflare-go/v7 v7.7.0` (v7.8.0 dropped RecordResponseUnion discriminator).
- Many provider SDKs (AWS v2, Azure, Alibaba, F5, etc.).

## Not verified in fetched sources
- Port 7979 and `/healthz`: not documented in README or docs page fetched; treat as chart-defined.
- Binary/image asset names: release page (github.com/kubernetes-sigs/external-dns/releases/tag/v0.24.0) loads assets via JS; none extracted.

## Gotchas
- Default docs install paths in README assume Helm/kubectl; no container-specific guidance.
