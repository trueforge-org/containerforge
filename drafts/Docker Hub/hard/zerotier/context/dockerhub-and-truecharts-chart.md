# Docker Hub zerotier/zerotier and TrueCharts zerotier chart

## Source URL(s) + date
- https://hub.docker.com/r/zerotier/zerotier (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zerotier/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zerotier/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zerotier not parsed.

## Docker Hub
- Title: "zerotier/zerotier - Docker Image"
- Meta description: "zerotier-one in a container! https://www.zerotier.com"
- JS-rendered; tags not extractable.

## Chart (reference only)
- `zerotier` chart version 15.0.0, appVersion 1.14.2 (older than plan's 1.16.2).
- Depends on `common` 32.8.5.
- Image tag `1.14.2@sha256:575d150a0e09fbee1a7580625b361040a7f78f46cbfbe5016effe812abe202ff`, repo `docker.io/zerotier/zerotier`.
- Service `main`: protocol udp, targetPort 9993, port 10190.
- Persistence: `config` -> `/var/lib/zerotier-one`; `tun` hostPath `/dev/net/tun` -> `/dev/net/tun`.
- securityContext: capabilities add `NET_ADMIN`; runAsUser 0; readOnlyRootFilesystem false.
- Probes: all disabled.
- Env: `ZEROTIER_API_SECRET` and `ZEROTIER_IDENTITY_SECRET` from secret `env-secrets`; `ZEROTIER_IDENTITY_PUBLIC` empty.

## Gotchas
- Chart needs `NET_ADMIN` and `/dev/net/tun` for the daemon to create interfaces.
