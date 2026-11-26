# TrueCharts photoview chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoview/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/photoview (not fetched)

- Image: docker.io/viktorstrate/photoview:2.4.0 (sha256 pinned), pullPolicy IfNotPresent. NOTE: old registry.
- Service main port: 10159; app listen port templated from it (PHOTOVIEW_LISTEN_PORT)
- Env defaults: PHOTOVIEW_LISTEN_IP=127.0.0.1; PHOTOVIEW_DATABASE_DRIVER=postgres; PHOTOVIEW_MEDIA_CACHE=/cache; PHOTOVIEW_DISABLE_FACE_RECOGNITION/VIDEO_ENCODING/RAW_PROCESSING=false
- PHOTOVIEW_POSTGRES_URL from secret `secrets`; MAPBOX_TOKEN from secret env-secrets (default empty)
- Persistence: cache -> /cache (not emptyDir); photos -> /photos
- Probes: none defined; securityContext/user: none defined in this chart values
- Deps: postgresql enabled (user and db photoview)
