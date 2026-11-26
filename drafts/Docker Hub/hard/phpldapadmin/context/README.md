# Context index: phpldapadmin

| Source URL | File |
| --- | --- |
| https://github.com/leenooks/phpLDAPadmin (README via raw) | leenooks-readme.md |
| https://github.com/leenooks/phpLDAPadmin/wiki (Docker-Container page, follow-up) | leenooks-wiki-docker-v2.md (wiki root not fetched) |
| https://github.com/osixia/docker-phpLDAPadmin/blob/master/image/Dockerfile | osixia-dockerfile.md |
| https://github.com/osixia/docker-phpLDAPadmin README (follow-up, raw) | osixia-readme.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/phpldapadmin (values via raw) | truecharts-chart-values.md |
| https://hub.docker.com/r/osixia/phpldapadmin | dockerhub-osixia.md |
| https://phpldapadmin.org | phpldapadmin-org.md |
| https://gitlab.v2.rancher.geohub.space/g3s/i3s/i3s-helm-catalog | phpldapadmin-org.md (failure recorded) |

Skipped categories: none (no CLA, forgetool, containerforge, templated, binary or image-ref URLs in the list).

## Failures
- https://gitlab.v2.rancher.geohub.space/g3s/i3s/i3s-helm-catalog: ECONNREFUSED (one attempt, not retried).

## plan.md corrections
- None applied. Unverified conflict: TrueCharts chart uses the archived osixia/phpldapadmin:0.9.0 (PHP 7.3, legacy); upstream recommends phpldapadmin/phpldapadmin (v2, frankenphp, port 8080, LDAP_HOST env). Plan not checked against this.
