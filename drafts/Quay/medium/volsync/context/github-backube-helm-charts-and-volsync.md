# github.com/backube/helm-charts and github.com/backube/volsync (repo pages)

Source URL(s): https://github.com/backube/helm-charts ; https://github.com/backube/volsync (WebFetch, fetched 2026-11-27)

## volsync
- Asynchronous data replication for Kubernetes volumes (rsync, rclone, restic movers; repo dirs also mover-syncthing). Maturity badge: alpha.
- License AGPL-3.0 (api/* Apache-2.0; docs CC BY-SA 4.0).

## Helm install (from repo README)
- helm repo add backube https://backube.github.io/helm-charts/
- helm install --create-namespace -n volsync-system volsync backube/volsync
- Default namespace: volsync-system.

## helm-charts repo
- "The backube Helm chart repository". Top-level: docs, LICENSE, README.md, build-index.sh. Usage docs at https://backube.github.io/helm-charts. License AGPL-3.0.
