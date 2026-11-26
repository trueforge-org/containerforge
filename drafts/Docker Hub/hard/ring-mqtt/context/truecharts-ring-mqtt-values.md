# TrueCharts ring-mqtt values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ring-mqtt (raw values.yaml), fetched 2026-11-26

## Values (chart reference)
- image: docker.io/tsightler/ring-mqtt, tag 5.9.3@sha256:4a4e0db460d7023aa5851ff25491401fd23b2fd153b7269af481f0953cd6f00a
- service main: port 55123 (http, web); service rtsp: port 8554 (tcp)
- ring:
  | Key | Default |
  | --- | --- |
  | mqtt_url | mqtt://localhost:1883 |
  | mqtt_options | "" |
  | livestream_user / livestream_pass | "" |
  | disarm_code | "" |
  | enable_cameras | true |
  | enable_modes | false |
  | enable_panic | false |
  | hass_topic | homeassistant/status |
  | ring_topic | ring |
  | location_ids | [] |
- persistence: data -> /data; ring-config (configmap `ring-config`) mounted at /data/config.json (subPath config.json, readOnly)
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0, runAsNonRoot false
- probes: all disabled

## Gotchas
- values.yaml has a malformed key `location_ids": []` (stray quote), so the chart value may not parse as intended.
- Ring config is passed as /data/config.json from a ConfigMap, not env vars.
