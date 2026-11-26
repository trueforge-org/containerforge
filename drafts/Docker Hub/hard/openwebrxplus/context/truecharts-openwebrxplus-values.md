# TrueCharts openwebrxplus chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openwebrxplus (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/slechev/openwebrxplus-softmbe`, tag 1.2.131, digest sha256:def4cb42…; IfNotPresent.
- Port: main 8073 (http).
- Env: OPENWEBRX_ADMIN_USER "admin"; OPENWEBRX_ADMIN_PASSWORD from secret env-secrets (default "changeme"). Commented: HEALTHCHECK_USB_XXXX_YYYY, OPENWEBRX_ENABLE_SATDUMP.
- Persistence: var -> /var/lib/openwebrx; config -> /etc/openwebrx; plugins -> /usr/lib/python3/dist-packages/htdocs/plugins.
- Device: usb (disabled by default) hostPath /dev/bus/usb.
- securityContext: uid/gid 0; readOnlyRootFilesystem false; runAsNonRoot false.
- Probes (liveness/readiness/startup): HTTP /status.json. Command/args: none.
