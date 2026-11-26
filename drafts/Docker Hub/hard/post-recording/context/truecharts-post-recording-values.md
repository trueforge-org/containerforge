# TrueCharts post-recording values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/post-recording (raw values.yaml), fetched 2026-11-26

## Relevant values (chart reference only)
- image: docker.io/chacawaca/post-recording, tag latest@sha256:98f0e32c2e58476c3b72418a197ce181f9b9ae3c656a9e51c98660fe6b2f6603
- Persistence: config -> /config, watchfolder -> /watch, backupfolder -> /backup (all enabled)
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0
- service.main disabled (no web port)
- Env overrides: CONVERSION_FORMAT=mkv, DELETE_TS=1, POST_PROCESS=comchap, SOURCE_EXT=ts, SUBTITLES=0
- All probes disabled

## Gotchas
- Chart runs as root and sets mkv default output, which differs from the image default mp4.
