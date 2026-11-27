# Context: rdtclient

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rdtclient/values.yaml + Chart.yaml | truecharts-rdtclient.md |
| https://raw.githubusercontent.com/rogerfar/rdt-client/a669bd3/Dockerfile (blob URL at same commit is a duplicate) | rdtclient-dockerfile.md |

Skipped: blob variant of the Dockerfile (duplicate); github.com repo HTML (replaced by the failure notes below).
No Docker Hub URL in list (image is GHCR).

Failures:
- https://api.github.com/repos/rogerfar/rdt-client: 403 rate limit. HTML alternative https://github.com/rogerfar/rdt-client returned only page chrome, no usable content.
- https://api.github.com/repos/rogerfar/rdt-client/releases/tags/v2.0.143: 403 rate limit. HTML alternative https://github.com/rogerfar/rdt-client/releases/tag/v2.0.143 returned only page chrome, no usable content.
- Release metadata (publish date, `RealDebridClient.zip` asset) therefore not re-checked in this run.

## plan.md corrections
None. Checked plan facts against the fetched chart and Dockerfile (images and digests, ports 6500/6800/6888, aria2 env, base images, ASP.NET 10.0.0 musl runtime, EXPOSE/HEALTHCHECK, ENV, data paths). No clear factual error proven.
Unverified (not settled by these fetches): release date, asset name and size (API only), GHCR arch list.
