# TrueCharts: generic-device-plugin (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/generic-device-plugin/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `generic-device-plugin` version 5.0.0, appVersion `latest`. Description: "Device Plugin to expose tun-device on talos". Category media.
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart keywords (jackett, torrent, usenet) are copy-paste; not meaningful.

## Image (values.yaml)
- repository: ghcr.io/squat/generic-device-plugin
- tag: `latest@sha256:6fd8023741b24c0302a97153605ff77f4d55535a4b5a8b0c8502b208e8310525`
- pullPolicy IfNotPresent.

## Args (workload.main.podSpec.containers.main.args)
- `--domain truecharts.org`
- `--device` with YAML: `name: tun`, groups: count 1000, paths `/dev/net/tun`.

## Ports
- service main: 8080 tcp (container port not set in values).

## Security
- readOnlyRootFilesystem: true; privileged: true; runAsNonRoot: false; runAsUser 0; runAsGroup 0.

## Persistence (hostPath)
| Name | hostPath | mountPath |
| --- | --- | --- |
| dev | /dev | /dev |
| device-plugin | /var/lib/kubelet/device-plugins | /var/lib/kubelet/device-plugins |

## Gotchas
- Requires privileged + host /dev and kubelet device-plugin socket dir.
- Device resource advertised as `devic.es/...` style per upstream flags; chart uses name `tun`.
