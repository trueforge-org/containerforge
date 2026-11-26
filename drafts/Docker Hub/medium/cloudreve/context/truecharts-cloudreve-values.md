# trueforge-org/truecharts charts/stable/cloudreve values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cloudreve/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/cloudreve/cloudreve, tag 4.19.1 pinned by digest (5c6c5baf7...), IfNotPresent
- Service main: port 5212 -> container 5212
- Env (CR_CONF_ prefix): Database.Type=postgres; Database.Host/User/Name templated from postgresql dep (user/db "cloudreve"); Database.Port 5432; Database.Password from secret postgresqlcreds key postgresql-password; Redis.Server = valkey host:6379; Redis.User "default"; Redis.Password from valkeycreds key valkey-password
- Persistence: `config` -> /cloudreve/data
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- Dependencies: valkey enabled; postgresql enabled

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cloudreve/Chart.yaml
- name cloudreve; version 16.0.0; appVersion 4.19.1; type application; deprecated false
- description: Self-hosted file management and sharing system, supports multiple storage providers
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: cloudreve/Cloudreve, truecharts chart folder, hub cloudreve/cloudreve
