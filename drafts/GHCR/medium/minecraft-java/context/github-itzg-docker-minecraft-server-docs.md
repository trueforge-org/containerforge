# itzg/docker-minecraft-server docs: jvm-options.md and data-directory.md (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/itzg/docker-minecraft-server/master/docs/configuration/jvm-options.md (2026-11-27)
- https://raw.githubusercontent.com/itzg/docker-minecraft-server/master/docs/data-directory.md (2026-11-27)

## Memory (jvm-options)
| var | effect |
| --- | --- |
| MEMORY | default 1G; sets Xms and Xmx; accepts `<n>[gGmMkK]` or `<n>%` |
| INIT_MEMORY | initial heap (InitialRAMPercentage when %) |
| MAX_MEMORY | max heap (MaxRAMPercentage when %) |
| MEMORY="" | JVM uses 25% of container memory limit |
| JVM_OPTS | extra JVM args, space-delimited |
| JVM_XX_OPTS | -XX options, space-delimited |

## Data directory
- Everything managed is under container `/data` (pre-declared VOLUME).
- Bind mounts must map to `/data`.
- Rootless, Podman, SELinux, AppArmor: append `:Z` to the volume mapping.

## Gotchas
- Docs say 1 GB heap default; a container memory limit should include ~25% extra for non-heap.
