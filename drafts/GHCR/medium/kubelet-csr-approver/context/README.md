# Context: kubelet-csr-approver

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kubelet-csr-approver/values.yaml + Chart.yaml | truecharts-kubelet-csr-approver.md |
| https://github.com/postfinance/kubelet-csr-approver (raw README master; cmd/kubelet-csr-approver/main.go and internal/cmd/cmd.go at v1.2.16) | github-postfinance-kubelet-csr-approver.md |

Skipped: GitHub HTML pages (https://github.com/kubelet-csr-approver/kubelet-csr-approver, https://github.com/postfinance/kubelet-csr-approver root and tag pages, covered by raw files). No Docker Hub URL. No CLA, forgetool, templated or binary URLs.

Failures:
- https://github.com/kubelet-csr-approver/kubelet-csr-approver (raw README `main`): 404. Alternative `master`: 404. Not retried. Org repo content unknown.
- Not fetched: upstream `charts/` (plan mentions it; out of budget).

## plan.md corrections
- None edited. The plan's UNVERIFIED port (8080/8081) and env/flag notes (lines 18-19) are now confirmed by upstream `internal/cmd/cmd.go` at v1.2.16 and the chart: metrics 8080, probe 8081, flags and env names listed in the GitHub file.
