# context README: dns-doh-companion

| Source URL | File |
| --- | --- |
| https://github.com/testdasi/simple-dns-doh/blob/354be66/Dockerfile | upstream-testdasi.md |
| https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/Dockerfile | upstream-testdasi.md |
| https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/install.sh | upstream-testdasi.md (followed sub-file) |
| https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/README.md | upstream-testdasi.md |
| https://hub.docker.com/r/testdasi/simple-dns-doh | upstream-testdasi.md (tags API used; HTML not fetched) |
| https://github.com/cloudflare/cloudflared | cloudflared-release.md (repo root, latest release API) |
| https://developers.cloudflare.com/1.1.1.1/dns-over-https/cloudflared-proxy | cloudflare-doh-docs.md |
| https://1.1.1.1/dns-query, https://1.0.0.1/dns-query | cloudflare-doh-docs.md (endpoints, not fetched) |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: upstream config.yml 404 (in upstream-testdasi.md); cloudflared-proxy docs URL served a different page (in cloudflare-doh-docs.md).

## plan.md corrections
None edited. Checked: upstream Dockerfile matches plan description (debian-slim base, EXPOSE 53 tcp/udp, CMD cloudflared --config /etc/cloudflared/config.yml). Latest cloudflared release 2026.11.2 (2026-11-23) matches plan's "latest upstream". The proxy-dns removal claim (plan section 1) was not re-verified.
Notable (not in plan): the upstream image takes cloudflared `releases/latest` in install.sh (unpinned), which is the reason the plan does not reuse it.
