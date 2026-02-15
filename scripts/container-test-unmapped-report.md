# Container Test YAML Unmapped Command Report

Apps where `container_test.go` currently contains command-based checks that are not representable in the current `container-test.yaml` schema.

- Generated on: 2026-02-15
- Total apps with unmappable command tests: 25

## Apps

- `devcontainer`
- `flood`
- `gluetun`
- `go-yq`
- `java11`
- `java17`
- `java21`
- `java25`
- `java8`
- `k8s-sidecar`
- `kubectl`
- `mariadb-client`
- `memcache`
- `mongosh`
- `nextcloud-fpm`
- `nextcloud-imaginary`
- `nextcloud-notify-push`
- `node`
- `postgresql-client`
- `python-node`
- `scratch`
- `tailscale`
- `valkey-tools`
- `watchtower`
- `yq`

## Source of truth

See each app’s `apps/<app>/container-test.yaml` file under the `# unmappedCurrentTests` section for the exact command(s) that are currently unmappable.
