# TrueCharts chart: external-dns

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/external-dns/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/external-dns/values.yaml (fetched 2026-11-27)

## What it is
- Chart `external-dns` version 10.0.0, appVersion 0.24.0, category networking.
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`). kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `registry.k8s.io/external-dns/external-dns` tag `v0.24.0@sha256:a80a146d2540fa138565e404f0625157271071a06093021f27ae19d8316d10f9`, pullPolicy IfNotPresent.

## externaldns values (mapped to upstream flags/env by chart)
| Key | Default |
| --- | --- |
| ingressClassName | "" |
| logLevel | "info" |
| logFormat | "text" |
| interval | "1m" |
| provider | "inmemory" |
| sources | ["service", "ingress"] |
| domainFilters / zoneidFilters | [] |
| cloudflareProxied | "" |
| registry | "txt" |
| policy | "sync" |
| piholeServer / piholePassword / piholeAPIVersion | "" |
| triggerLoopOnEvent | "false" |
| pdns.pdnsApiKey / pdns.pdnsServerUrl | "" (used with provider pdns) |
| txtOwnerId / txtPrefix / txtSuffix | "" |

## Service / ports
- `service.main.ports.main`: port 7979, protocol http, targetPort 7979.

## Probes
- liveness, readiness, startup: path `/healthz` (port not set in values).

## Env (secretKeyRef from `env-secrets` unless noted)
- CF_API_TOKEN, CF_API_KEY, DO_TOKEN, LINODE_TOKEN, OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET, OVH_CONSUMER_KEY, SCW_ACCESS_KEY, SCW_SECRET_KEY: secretKeyRef.
- CF_API_EMAIL: "" (plain). DNSIMPLE_OAUTH: "" (plain).

## RBAC / SA
- `rbac.main`: enabled, primary, clusterWide. Rules: nodes, pods, services, endpoints, ingresses, many CRDs (istio, ambassador, contour, gateway API, kong, traefik, openshift routes, zalando, f5, discovery endpointslices, namespaces).
- `serviceAccount.main`: enabled, primary. `podOptions.automountServiceAccountToken: true`.

## Secret
- `secret.env-secrets`: enabled; empty placeholder data for CF_API_TOKEN, CF_API_KEY, DO_TOKEN, LINODE_TOKEN, OVH_*, SCW_*.

## Security context / persistence
- Not set in values.yaml (chart defaults apply). No persistence block.

## Gotchas
- Default provider `inmemory` (no real DNS); must be set for production use.
- Probes and port 7979 are chart-defined; the fetched upstream README does not document 7979 or /healthz (see github-external-dns.md).
