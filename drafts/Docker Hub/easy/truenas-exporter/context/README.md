# context/ for truenas-exporter

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/prometheus/graphite_exporter (Dockerfile @v0.17.0, README @v0.17.0, sha256sums.txt @v0.17.0 via releases/download) | github-prometheus-graphite-exporter.md |
| https://github.com/Supporterino/truenas-graphite-to-prometheus (and /tree/main) | github-supporterino-truenas-graphite-to-prometheus.md |
| https://hub.docker.com/r/prom/graphite-exporter | dockerhub-prom-graphite-exporter.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/truenas-exporter (values.yaml) | truecharts-truenas-exporter.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base link.
- https://github.com/prometheus/graphite_exporter/blob/v0.17.0/Dockerfile: fetched raw instead.
- https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-amd64.tar.gz, `...linux-arm64.tar.gz`, `...dragonfly-amd64.tar.gz`, `...linux-amd64.tar.gz` (in the TrueNAS list): direct archive downloads (names recorded in the upstream summary).
- https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/sha256sums.txt: fetched via its releases/download URL (a text checksum file, not an archive). The raw variant is a 404.
- Local `http://<container-ip`-style draft fragments and `localhost` are not web sources.

## Fetch failures

- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/sha256sums.txt: 404 (raw path). Alternate `releases/download/` path succeeded.
- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/main.go: 404 (not fetched successfully).
- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/graphite_exporter.go: 404. Flag definitions (listen addresses) therefore unconfirmed.
- Supporterino `Dockerfile`, `TRUENAS.md`: content not shown by the fetch (Dockerfile listed in the tree only).

## plan.md corrections

None made. Verified and consistent: the checksum values for `linux-amd64` and `linux-arm64` (`109c1f94...c60469`, `95d49e7f...cfc3f435`) match `sha256sums.txt`; the upstream Dockerfile is busybox with `USER nobody`, `EXPOSE 9108 9109 9109/udp`, and `/bin/graphite_exporter`; the TrueCharts image is `prom/graphite-exporter:v0.17.0`.

Items left as unverified (not edited):
- Plan section 1: `--web.listen-address` and `--graphite.listen-address` flag names and the default ports. The README does not name them; `main.go` and `graphite_exporter.go` returned 404 at the tag. start.sh depends on these names.
- Plan section 1: the Supporterino Dockerfile `FROM prom/graphite-exporter:v0.16.0`, its `/config/graphite_mapping.conf` copy (19766 bytes) and its entrypoint. The fetch lists the Dockerfile but shows no content.
- Plan section 1: "the Supporterino repo is a wrapper". The README describes a mapping file and dashboards, not an image; the wrapper claim is unverified.
- Plan section 1: tarball content `getool`, `LICENSE`, `NOTICE` verified for amd64. Not fetched.
- Plan section 1: "`dragonfly-amd64` is a BSD build". Not verified; the checksum list only confirms it is a separate asset (`dragonfly` is one of the listed OS names).
