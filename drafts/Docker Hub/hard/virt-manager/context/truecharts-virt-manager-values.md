# trueforge truecharts virt-manager values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/virt-manager/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/mber5/virt-manager`
- Tag: `latest@sha256:111674d877635e0f85baabfb202bba560e7ec5ccdf0d2f1ebcb48fc9c32bfd48`
- PullPolicy: IfNotPresent

## Service
- `main`: TCP 8185 -> 80

## Persistence
| Name | Mount |
| --- | --- |
| devkvm | /dev/kvm |
| images | /var/lib/libvirt/images |
| libvirt-sock | /var/run/libvirt/libvirt-sock |
| rootfolder | /root |

## Env
- `HOSTS` = `"['qemu:///stable']"`
  - Note: value looks like a typo for `qemu:///system` (upstream README uses `qemu:///system`). Unverified; not changed in plan.

## Security context
- runAsUser 0; runAsGroup 0; readOnlyRootFilesystem false; privileged and capabilities not set.
