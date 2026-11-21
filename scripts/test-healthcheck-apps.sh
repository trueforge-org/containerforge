#!/usr/bin/env bash
# Runs the healthcheck parser in dry-run mode over every app's container-test.yaml.
# A config whose http/tcp/healthCommands section yields no check would make the app unhealthy,
# so it is reported here before it ships. No container is started.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
with_checks=0
no_probe=0
failed=0

for config in "${REPO_ROOT}"/apps/*/container-test.yaml; do
    app="$(basename "$(dirname "${config}")")"
    if output="$(HEALTHCHECK_DRY_RUN=1 bash "${REPO_ROOT}/include/healthcheck.sh" "${config}" 2>&1)"; then
        if [[ "${output}" == "no-probe" ]]; then
            no_probe=$((no_probe + 1))
        else
            with_checks=$((with_checks + 1))
        fi
    else
        echo "::error file=apps/${app}/container-test.yaml::healthcheck.sh cannot parse any check: ${output}"
        failed=$((failed + 1))
    fi
done

echo "apps with probes: ${with_checks}, without probes (process fallback): ${no_probe}, unparsable: ${failed}"
[[ "${failed}" -eq 0 ]]
