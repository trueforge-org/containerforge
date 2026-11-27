# Upstream: postfinance/kubelet-csr-approver (tag v1.2.16)

Source URL(s) + date: https://raw.githubusercontent.com/postfinance/kubelet-csr-approver/master/README.md (fetched 2026-11-27); https://raw.githubusercontent.com/postfinance/kubelet-csr-approver/v1.2.16/cmd/kubelet-csr-approver/main.go; https://raw.githubusercontent.com/postfinance/kubelet-csr-approver/v1.2.16/internal/cmd/cmd.go (flag definitions).
Failed: https://raw.githubusercontent.com/kubelet-csr-approver/kubelet-csr-approver/main/README.md (404) and .../master/README.md (404). Org repo not used.

## What it is
- Kubernetes controller that auto-approves `kubelet-serving` CSRs that pass configurable checks (provider regex, DNS, IP prefixes, username prefix `system:node:`, SAN count, expiration cap).
- Kubelet side: set `serverTLSBootstrap: true` in `/var/lib/kubelet/config.yaml` and restart kubelet.
- Supports the most recent three Kubernetes minor releases.

## Build (upstream)
- No Dockerfile in repo. Image built with `ko` (`.ko.yaml`, main `./cmd/kubelet-csr-approver/`).
- Entry: `cmd/kubelet-csr-approver/main.go` calls `internal/cmd.Run()` and `os.Exit(code)`.
- Go module `github.com/postfinance/kubelet-csr-approver`.
- Build version info: `internal/cmd` logs `commit` and `ref` (set via ldflags per plan).

## Flags and env (internal/cmd/cmd.go; env names from README where documented, others derived from ff.WithEnvVars and not confirmed)
| Flag | Env | Default | Purpose |
| --- | --- | --- | --- |
| -level | LEVEL | 0 | log level -5 (Fatal) to 10 (Verbose) |
| -metrics-bind-address | METRICS_BIND_ADDRESS | :8080 | metrics endpoint |
| -health-probe-bind-address | HEALTH_PROBE_BIND_ADDRESS | :8081 | probes (`healthz` ping) |
| -leader-election | LEADER_ELECTION | false | enable leader election |
| -provider-regex | PROVIDER_REGEX | .* | SAN name validation regex |
| -max-expiration-sec | MAX_EXPIRATION_SEC | 367*24*3600 | max cert lifetime (367 days) |
| -bypass-dns-resolution | BYPASS_DNS_RESOLUTION | false | skip DNS check |
| -bypass-hostname-check | BYPASS_HOSTNAME_CHECK | false | allow DNS name not prefixed by hostname |
| -ignore-non-system-node | IGNORE_NON_SYSTEM_NODE | false | ignore CSRs not from system:node |
| -skip-deny-step | SKIP_DENY_STEP | false | approve only, never deny |
| -allowed-dns-names | ALLOWED_DNS_NAMES | 1 | DNS SANs allowed per CSR |
| -provider-ip-prefixes | PROVIDER_IP_PREFIXES | 0.0.0.0/0,::/0 | allowed IP ranges (comma-separated) |

- Flag `-level` and the rest are read from the flag set `fs` (`ctrlconfig.RegisterFlags(fs)` also adds controller-runtime flags).
- Leader election namespace `kube-system`, lease ID `kubelet-csr-approver`.

## Ports
- 8080 metrics, 8081 health probe (flag defaults above).

## Healthcheck
- `mgr.AddHealthzCheck("healthz", healthz.Ping)`: `/healthz` on the probe port.

## Runtime deps
- Kubernetes API access (CSR approval, leases, events). No external services except optional DNS resolution.

## Config files
- None. Config is flags/env only.

## Version/asset naming
- Git tags carry `v` prefix (`v1.2.16`). No release assets (source tarball).

## Arch
- Not stated upstream in fetched files. Plan builds amd64 and arm64.

## Gotchas
- Upstream README documents DNS resolution as required unless `--bypass-dns-resolution` is set.
- Default `provider-ip-prefixes` is open (all IPs) unless set.
- Chart `sources` GitHub link (kubelet-csr-approver org): raw README not found on `main` or `master`; the image's upstream is postfinance.
