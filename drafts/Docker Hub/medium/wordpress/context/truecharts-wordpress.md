# truecharts: wordpress (chart 16.0.0, appVersion latest; fetched 2026-11-27)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wordpress/values.yaml , .../Chart.yaml

## Image
- repository `docker.io/bitnamisecure/wordpress`, tag `latest@sha256:549b3984a7cb1edbadb3050b251368bd47948a00042cfa6a88f3a2d4dce1a2c4`, pullPolicy IfNotPresent.

## Security
- readOnlyRootFilesystem false, runAsGroup 0 (runAsUser not set in values).

## Service / ports
| Service | Port | Protocol |
| --- | --- | --- |
| main | 10591 | http (targetPort not set; defaults to port) |

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| config | true | `/bitnami/wordpress` |

## Probes
- liveness, readiness, startup: all `tcp` on the service port.

## Env (from ConfigMap/Secret, plus wordpress values)
- `envFrom`: configMapRef `env-config`, secretRef `env-secret`.
- wordpress values (Bitnami-style names are not used in the chart's env): user `user`, pass `bitnami`, email `user@example.com`, first_name/last_name `TrueCharts`, blog_name `Truecharts Blog`, enable_reverse_proxy_headers true.
- Auth keys and salts: `authKey`, `secureAuthKey`, `loggedInKey`, `nonceKey`, `authSalt`, `secureAuthSalt`, `loggedInSalt`, `nonceSalt` (placeholders; must be changed).
- smtp: disabled (host, port 587, user, pass empty).
- php-config: `PHP_ENABLE_OPCACHE` yes, `PHP_MEMORY_LIMIT` 512M, others empty.

## Dependencies
- `mariadb` enabled, depconfig: `mariadbUsername: wordpress`, `mariadbDatabase: wordpress`.

## Gotchas
- Chart mounts `/bitnami/wordpress`, the Bitnami image data path.
- Default admin user `user` / password `bitnami` in values (chart default).
