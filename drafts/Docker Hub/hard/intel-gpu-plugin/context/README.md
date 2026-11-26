# Context: intel-gpu-plugin

| Source URL | File |
| --- | --- |
| https://github.com/intel/intel-device-plugins-for-kubernetes/blob/v0.37.1/build/docker/intel-gpu-plugin.Dockerfile | upstream-dockerfile.md |
| https://github.com/intel/intel-device-plugins-for-kubernetes | upstream-project-readme.md |
| https://intel.github.io/intel-device-plugins-for-kubernetes/0.36 | FAILED (empty response) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/intel-gpu-plugin | truecharts-intel-gpu-plugin-chart.md |
| https://hub.docker.com/r/intel/intel-gpu-plugin | hub-docker-intel-gpu-plugin.md |
| https://github.com/intel | github-org-intel.md |
| (follow-up) cmd/gpu_plugin/README.md on main | upstream-gpu-plugin-readme.md |
| (follow-up) truecharts values.yaml on master | truecharts-intel-gpu-plugin-chart.md |

Skipped categories: none in urls.txt.

## Failures
- https://intel.github.io/intel-device-plugins-for-kubernetes/0.36: empty response, not retried. GPU facts covered by the GPU README.

## plan.md corrections
- No edits made. Version 0.37.1 matches upstream tag.
- Unverified conflict: plan says the chart expects `runAsUser 568` and read-only rootfs. The TrueCharts values.yaml has no securityContext set (common library defaults not checked).
