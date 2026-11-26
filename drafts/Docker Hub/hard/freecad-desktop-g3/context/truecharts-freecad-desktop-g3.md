# TrueCharts chart freecad-desktop-g3 (values)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/freecad-desktop-g3 (chart directory, referenced by draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/freecad-desktop-g3/values.yaml (fetched 2026-11-26, WebFetch summary)

What it is: the TrueCharts Helm chart that deploys the accetto FreeCAD image.

Container image: `docker.io/accetto/ubuntu-vnc-xfce-freecad-g3`, tag `latest`, pinned digest `sha256:caee5716ab3e3dc71ed5aabfeac70e631a71ebb348a02b020c3274b3b14e5df5`, pullPolicy IfNotPresent.

Security context (main container): readOnlyRootFilesystem `false`; runAsUser `0`, runAsGroup `0`.

Env: `VNC_PW` from secret `env-secrets` key `VNC_PW`; `VNC_RESOLUTION` = `1360x768`. Secret default value in chart: `unraid` (plain test value).

Ports: main service `6901` (http); `webuivnc` service enabled with `5901` (tcp).

Persistence: `internalshare` volume enabled, mounted at `/UNRAID_SHARE`. Type not shown in fetched text.

Gotchas:
- The chart's secret default `unraid` is a TrueCharts artefact and must not be copied into ContainerForge.
- Chart expects root, writable rootfs, `/UNRAID_SHARE`: the plan maps this to `/config/projects` (UNVERIFIED, plan decision).

Failed to fetch: none.
