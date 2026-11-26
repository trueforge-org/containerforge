# TrueCharts chart collabora (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/collabora (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/collabora/values.yaml) · fetched 2026-11-26

## Image
`docker.io/collabora/code:26.04.6.2.1` pinned by digest (`a2f5d4e8…f0b5342b`), pullPolicy IfNotPresent. (The draft used 26.04.6.1.1; the chart is on 26.04.6.2.1.)

## Ports
Service main http 9980 (targetPort 9980).

## Env (ConfigMap `collabora-config`, via envFrom)
- username `admin`, password `changeme` (placeholder), interface `default`, dictionaries `de_DE en_GB en_US el_GR es_ES fr_FR pt_BR pt_PT it nl ru`, server_name `example.com`, aliasgroup1 `https://cloud.example.com`, ssl_enable `false`, ssl_termination `true`, no_gen_ssl `true`, extra_params `--o:welcome.enable=false`.
- Chart key names (`ssl_enable`, `ssl_termination`, `no_gen_ssl`, `interface`) are not the same as the plan's env list (`DONT_GEN_SSL_CERT`); the mapping of chart keys to container env is not shown in values.

## Persistence / mounts
None defined.

## Security context (main)
runAsUser 1001, runAsGroup 1001, readOnlyRootFilesystem false, allowPrivilegeEscalation true, capabilities add `CHOWN`, `FOWNER`, `SYS_CHROOT`, `MKNOD`; drop none.

## Probes
None defined.

## Gotchas
- Chart runs non-568 user with extra capabilities; rootless rework in plan.md applies.
