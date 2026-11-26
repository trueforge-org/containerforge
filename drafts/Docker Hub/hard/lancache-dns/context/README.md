# Context: lancache-dns

| Source URL | File |
| --- | --- |
| http://lancache.net/docs/containers/dns | lancache-docs-dns.md |
| (follow-up) https://lancache.net/docs/containers/dns/variables/ | lancache-docs-dns-variables.md |
| https://github.com/lancachenet/dnstool | dnstool-repo.md |
| https://github.com/lancachenet/lancache-dns | lancache-dns-readme.md |
| https://github.com/lancachenet/lancache-dns/blob/6b4b60e/Dockerfile | dockerfile-6b4b60e.md |
| https://github.com/lancachenet/lancache-dns/blob/master/Dockerfile | dockerfile-master.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lancache-dns | truecharts-lancache-dns-chart.md |
| https://github.com/uklans/cache-domains | uklans-cache-domains.md |
| https://hub.docker.com/r/lancachenet/lancache-dns | hub-docker-lancachenet-lancache-dns.md |
| https://lancache.net | lancache-net-home.md |
| https://lancache.net/docs | lancache-net-docs.md |

Skipped categories: none in urls.txt.

## Failures
- None.

## plan.md corrections
- No edits made. No clear factual error proven by the fetched sources.
- Minor: plan's healthcheck is abbreviated as `dig +norecurse @127.0.0.1 . NS`. Upstream adds `+time=2 +tries=1` and pipes to `grep -q 'status: NOERROR'`. Not edited (abbreviation, not wrong).
- Unverified: plan's `USE_GENERIC_CACHE` default (false). The docs page gives no default for it.
- Unverified: plan's `ENABLE_DNSSEC_VALIDATION` and `LANCACHE_DNSDOMAIN` meanings. Docs say DNSSEC has no description; LANCACHE_DNSDOMAIN is an internal RPZ TLD.
