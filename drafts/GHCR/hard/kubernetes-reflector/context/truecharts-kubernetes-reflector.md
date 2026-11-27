# TrueCharts kubernetes-reflector (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kubernetes-reflector/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `kubernetes-reflector` v11.0.0, appVersion 10.0.81
- Description: Kubernetes addon that reflects Secret and ConfigMap changes across namespaces

## Image
- repository ghcr.io/emberstack/kubernetes-reflector, tag 10.0.81 (digest pinned), pullPolicy IfNotPresent

## RBAC (clusterWide)
- configmaps, secrets: get, list, watch, create, update, patch, delete
- namespaces: watch, list
- serviceAccount enabled (primary), automountServiceAccountToken true

## Env vars (workload main)
| Var | Value |
| --- | --- |
| ES_Serilog__MinimumLevel__Default | Information (kubernetesReflector.logLevel) |
| ES_Reflector__Watcher__Timeout | "" |
| ES_Reflector__Kubernetes__SkipTlsVerify | "false" |

## Ports
- service main disabled. Probes target container port 8080.

## Probes
- liveness, readiness, startup: http `/health/ready` on 8080

## User/UID
- securityContext: readOnlyRootFilesystem true, runAsNonRoot true (no explicit UID in values)

## Gotchas
- Service disabled, so no Kubernetes Service object is created.
