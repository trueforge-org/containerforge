# osixia/docker-phpLDAPadmin README (legacy image)

Source URL: https://raw.githubusercontent.com/osixia/docker-phpLDAPadmin/master/README.md (fetched, follow-up)

- Status: LEGACY. Not the recommended route; use phpldapadmin/phpldapadmin (phpLDAPadmin 2) or the Osixia Helm chart instead.
- Image tag: 0.9.0 = phpLDAPadmin 1.2.5; base osixia/web-baseimage.

## Env vars
| Var | Default | Purpose |
| --- | --- | --- |
| PHPLDAPADMIN_LDAP_HOSTS | ldap.example.org (tls, bind cn=admin,dc=example,dc=org) + ldap2/ldap3 examples | YAML list -> config.php; use #PYTHON2BASH: prefix with --env |
| PHPLDAPADMIN_LDAP_HOSTS_FRIENDLY | not stated | display name key |
| PHPLDAPADMIN_SERVER_ADMIN | webmaster@example.org | Apache ServerAdmin |
| PHPLDAPADMIN_SERVER_PATH | /phpldapadmin | URL path (reverse proxy) |
| PHPLDAPADMIN_HTTPS | true | Apache SSL config; false disables HTTPS |
| PHPLDAPADMIN_HTTPS_CRT_FILENAME | phpldapadmin.crt | cert name |
| PHPLDAPADMIN_HTTPS_KEY_FILENAME | phpldapadmin.key | key name |
| PHPLDAPADMIN_HTTPS_CA_CRT_FILENAME | ca.crt | CA name |
| PHPLDAPADMIN_TRUST_PROXY_SSL | not stated | true = trust X-Forwarded-Proto |
| PHPLDAPADMIN_LDAP_CLIENT_TLS | true | LDAP client TLS config |
| PHPLDAPADMIN_LDAP_CLIENT_TLS_REQCERT | demand | TLS_REQCERT |
| PHPLDAPADMIN_LDAP_CLIENT_TLS_CA_CRT_FILENAME / _CRT_ / _KEY_ | ldap-ca.crt / ldap-client.crt / ldap-client.key | client TLS files |
| PHPLDAPADMIN_SSL_HELPER_PREFIX | phpldapadmin | ssl-helper prefix |
| LDAP_CLIENT_SSL_HELPER_PREFIX | ldap | ssl-helper prefix |

## Ports
- Container 443 (HTTPS); quick start -p 6443:443. HTTP not explicitly listed; HTTPS off with PHPLDAPADMIN_HTTPS=false.

## Volumes
- /container/service/phpldapadmin/assets/config/config.php (custom config)
- /container/service/phpldapadmin/assets/apache2/certs (HTTPS certs)
- /container/service/ldap-client/assets/certs (LDAP client TLS)
- /container/environment/01-custom/env.yaml (use XX-dir with XX < 99)

## Notes
- Log levels via --loglevel (none, error, warning, info default, debug, trace)
- --copy-service workaround for mounted files; defaults in image/environment/default.yaml
