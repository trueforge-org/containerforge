# maxmind/geoipupdate v8.0.0 (chart geoip image)
Source URL(s): https://raw.githubusercontent.com/maxmind/geoipupdate/v8.0.0/docker/Dockerfile (fetched; blob variant same). Repo page not fetched.

- `FROM alpine:3`, `apk add jq`
- COPY `geoipupdate` binary to /usr/bin/geoipupdate (expects built binary in build context)
- COPY docker/entry.sh -> /usr/bin/entry.sh, docker/healthcheck.sh -> /usr/bin/healthcheck.sh
- `ENTRYPOINT ["/usr/bin/entry.sh"]`
- `HEALTHCHECK --interval=10s --timeout=10s CMD ["/usr/bin/healthcheck.sh"]`
- `VOLUME ["/usr/share/GeoIP"]`, `WORKDIR /var/lib/geoipupdate`
- Runtime deps: jq (entry script not fetched)
