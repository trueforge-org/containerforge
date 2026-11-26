# trueforge-org/truecharts charts/stable/clipplex values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/clipplex/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/jonnike/clipplex, tag latest pinned by digest (12b36150...), IfNotPresent
- Service main: port 10602 -> container 5000, http
- Env: PLEX_TOKEN from secret env-secrets; PLEX_URL empty (user input); PYTHONUNBUFFERED=1; STREAMABLE_LOGIN empty; STREAMABLE_PASSWORD from secret env-secrets
- Persistence: volume `clips` at /app/app/static/media
- securityContext: not defined

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/clipplex/Chart.yaml
- name clipplex; version 9.0.0; appVersion `latest`; type application; deprecated false
- description: Clip your plex media to share.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: jo-nike/clipplex, truecharts chart folder, hub jonnike/clipplex
