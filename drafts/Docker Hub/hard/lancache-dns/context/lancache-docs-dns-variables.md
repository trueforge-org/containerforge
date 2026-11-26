# lancache.net docs: lancache-dns variables

Source URL(s): https://lancache.net/docs/containers/dns/variables/. Fetched 2026-11-26.

Note: USE_GENERIC_CACHE, LANCACHE_IP, *CACHE_IP, DISABLE_* are NOT on this page (see docs/containers/dns file).

## General
| Var | Default | Meaning |
| --- | --- | --- |
| CACHE_DOMAINS_REPO | https://github.com/uklans/cache-domains.git | repo for CDN map files (testing only) |
| CACHE_DOMAINS_BRANCH | master | branch |
| UPSTREAM_DNS | 8.8.8.8 | upstream servers; separated by `;` or space; must NOT be lancache-dns itself |

## Advanced ("here be dragons")
| Var | Default | Meaning |
| --- | --- | --- |
| STEAMCACHE_DNS_VERSION | 1 | internal reference, do not change |
| ENABLE_DNSSEC_VALIDATION | false | no description given |
| LANCACHE_DNSDOMAIN | cache.lancache.net | internal RPZ CNAME TLD |

## Notes
- Env change = recreate container; cache data in external volume.
- Compose: edit `.env`; CLI: `-e VAR=VALUE`.
