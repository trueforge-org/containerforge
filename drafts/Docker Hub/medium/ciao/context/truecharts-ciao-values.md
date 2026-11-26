# trueforge-org/truecharts charts/stable/ciao values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ciao/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/brotandgames/ciao, tag latest pinned by digest (449c72cb...), IfNotPresent
- Service main: port 8090 -> container 3000, tcp
- Env: SECRET_KEY_BASE and SMTP_PASSWORD from secret `env-secrets`; SMTP_ADDRESS smtp.yourhost.com; SMTP_DOMAIN smtp.yourhost.com; SMTP_AUTHENTICATION plain; SMTP_EMAIL_FROM ciao@yourhost.com; SMTP_EMAIL_TO you@yourhost.com; SMTP_ENABLE_STARTTLS_AUTO true; SMTP_PORT 587; SMTP_USERNAME ciao
- Persistence: `databaselocation` at /app/db/sqlite
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ciao/Chart.yaml
- name ciao; version 11.0.0; appVersion `latest`; type application; deprecated false
- description: checks HTTP(S) endpoints for status code (or TCP-level errors), notifies via E-Mail or Webhooks
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: https://brotandgames.com/ciao/, truecharts chart folder, hub brotandgames/ciao
