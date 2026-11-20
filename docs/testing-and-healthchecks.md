# Testing and healthchecks: evaluation and roadmap

This document evaluates how ContainerForge tests images and how container healthchecks work, including the part that runs in [forgetool](https://github.com/trueforge-org/forgetool). It ends with a roadmap for making the pipeline more reliable.

Scope: `.github/workflows/`, `.github/actions/`, `include/healthcheck.sh`, `scripts/test-healthcheck-*.sh`, every `apps/*/container-test.yaml` and `settings.yaml`, and `forgetool containers test`. Findings come from reading the code and configuration. Nothing was run, so claims about runtime behaviour are marked as such.

## Summary

How it works today:

1. A PR build bakes each changed app per architecture, merges the result into a mutable `sandbox` tag, and runs `forgetool containers test` against the merged digest (amd64 only).
2. forgetool starts the image with testcontainers-go and checks the `container-test.yaml` assertions: `mainRunner`, `runners`, `http`, `tcp`, `filePaths` and `healthCommands`.
3. Releases (push to `main`) rebuild the image, then push, attest and sign it. They do not run tests.
4. At runtime, `HEALTHCHECK CMD ["/healthcheck.sh"]` is inherited from the ubuntu and python base images. The script re-parses the app's `/container-test.yaml` in bash and runs the `http`, `tcp` and `healthCommands` probes against `127.0.0.1`.
5. The healthcheck script itself is tested by `healthcheck-tests.yaml`.

Top risks:

1. **The released image is never tested.** PRs test one build and `main` ships a different one.
2. **Base-image bumps merge untested.** `chore(ubuntu-dep)` and `chore(python-dep)` PRs skip build and test, yet pass the required status check.
3. **About 37% of apps have no real healthcheck.** 69 of 187 apps have no `http`, `tcp` or `healthCommands` probe, so `/healthcheck.sh` exits 0 even when the app is dead.
4. **forgetool is unpinned and the `sandbox` tag is shared.** Test runs are not reproducible, and concurrent PR runs can test each other's image.
5. **The read-only root filesystem, rootless and empty-`/config` cases are not tested in CI.** The repo protocol requires them, but CI never runs them.

## How it works today

### Pull request flow

- [pull-request.yaml](../.github/workflows/pull-request.yaml) triggers on `pull_request` and `merge_group`. It detects changed `apps/<app>` directories and calls [app-builder.yaml](../.github/workflows/app-builder.yaml) with `release: false`.
- `app-builder.yaml` builds one job per platform (amd64 on `ubuntu-latest`, arm64 on `ubuntu-24.04-arm`), merges the platform digests into one manifest tagged `sandbox`, and then runs the `test` job (`if: ! inputs.release`).
- The `test` job calls [app-tests/action.yaml](../.github/actions/app-tests/action.yaml), which installs forgetool and runs:

  ```sh
  forgetool containers test --image "${TEST_IMAGE}" --config "./apps/${APP}/container-test.yaml"
  ```

- The `status` job fails only when a build job failed. A skipped job counts as a pass.

### Release flow

- [release.yaml](../.github/workflows/release.yaml) runs on pushes to `main` that touch `apps/**`, and on `workflow_dispatch`. It calls `app-builder.yaml` with `release: true`, which rebuilds the image from `main`, pushes it, then attests and signs it.
- The `test` job is skipped when `release` is true, and `attest`, `sign` and `merge` do not depend on it.
- [retry-release.yaml](../.github/workflows/retry-release.yaml) re-dispatches `release.yaml` when the `rolling` image lags the bake version. That path is also untested.
- [vulnerability-scan.yaml](../.github/workflows/vulnerability-scan.yaml) scans `:rolling` daily with Grype. It is a vulnerability scan, not a functional test.

### What forgetool does

`forgetool containers test` (`cmd/containers_testcmd.go`, `pkg/containers/test/` in the forgetool repo) uses testcontainers-go.

- **Config keys:** `mainRunner`, `runners[]` (entrypoint, cmd, env, `expectedOutput`, `exitCode`), `http[]`, `tcp[]`, `filePaths[]`, `healthCommands[]`, `timeoutSeconds`, `readOnlyRootfs` and `mounts[]`. Only `--env` comes from the CLI.
- **Readiness:** testcontainers wait strategies (`ForHealthCheck`, `ForListeningPort`, `ForHTTP`, `ForExec`, `ForExit`). The main runner waits for the Docker HEALTHCHECK to report healthy when `http` or `tcp` checks exist.
- **Timeouts:** the main runner uses `max(timeoutSeconds, 180)`, plus 60 seconds when HTTP, TCP or file waits are present. A lower value is silently raised.
- **Containers per config:** the main runner can start two or three containers (health gate, combined waits, `healthCommands`), and each runner starts one or two more. All run sequentially.
- **Pass or fail:** a wait succeeding, or an exit code and `strings.Contains` match for runner output. There are no retries.
- **Logs:** `TESTHELPERS_CONTAINER_LOGS` selects when container logs are dumped (`all` and `always` dump on every run, `failure` is the default).
- **Settings:** the harness does not read `settings.yaml`. It sets no `cap_drop`, `privileged` or `shm_size`, and no user, network, platform or tmpfs options.

### Runtime healthcheck

- `HEALTHCHECK CMD ["/healthcheck.sh"]` is set in [apps/ubuntu/Dockerfile](../apps/ubuntu/Dockerfile) and [apps/python/Dockerfile](../apps/python/Dockerfile), and inherited by about 176 apps. `apprise-api`, `docusaurus` and `webhook` set it again, and `docusaurus` uses `--start-period=10m`.
- `COPY . /` places each app's `container-test.yaml` at `/container-test.yaml`, and [include/.dockerignore](../include/.dockerignore) allows it.
- [include/healthcheck.sh](../include/healthcheck.sh) parses that YAML with regular expressions and runs the `tcp` (via `/dev/tcp`), `http` (via `curl`, accepting 2xx and 3xx unless `statusCode` is set) and `healthCommands` entries. It ignores `runners`, `filePaths` and `mainRunner`.
- It exits 0 when no probe section exists, and also when a section exists but no check was parsed (it prints a warning).
- [healthcheck-tests.yaml](../.github/workflows/healthcheck-tests.yaml) runs `scripts/test-healthcheck-positive.sh` and `-negative.sh`. These build small images on an old pinned python base and cover the parser, not the real apps.

## Findings

### Coverage gaps

| Finding | Evidence |
| --- | --- |
| The released digest is never tested | `app-builder.yaml` `test` job is gated on `! inputs.release`. `release.yaml` rebuilds from `main`. |
| Base-bump PRs merge with nothing tested | `pull-request.yaml` skips `build` for titles starting `chore(ubuntu-dep): update ghcr.io/trueforge-org/ubuntu` or `chore(python-dep): ...`. `status` treats skipped as success, and automerge applies. |
| Fork PRs show green without container tests | By reading the workflow: `merge` is skipped for forks, `test` needs `merge`, and `status` passes on skipped jobs. Not run. |
| Downstream apps are not retested when a base changes | About 176 apps use `FROM ghcr.io/trueforge-org/...@sha256:`. No workflow finds dependents. Policy is manual (`DOWNSTREAM_CHANGES.md`). |
| Only amd64 is executed | The `test` job runs on `ubuntu-latest`. The arm64 image is built and pushed but never run. |
| Read-only rootfs, rootless and empty `/config` are not tested | No app sets `readOnlyRootfs: true` (0 of 187). No workflow uses `--read-only`, `--tmpfs` or `--user`. The build-test protocol requires all three. |
| No scheduled functional test | Only Grype on `:rolling`. Digest pinning covers upstream drift, so this is not a gap to fill. |

### Flakiness and reproducibility

- **forgetool is unpinned.** `app-tests/action.yaml` resolves `releases/latest` at run time and downloads without a checksum. The `version` input and the `VERSION` env var are never used. A bad forgetool release breaks every PR at once.
- **Shared `sandbox` tag.** `app-builder.yaml` pushes `sandbox` for every PR build and the merge job reads the digest back by tag. There is no `concurrency` group, so two runs for the same app can overwrite each other's tag and test the wrong digest.
- **No `timeout-minutes`** on any job, so the default is six hours.
- **No retries** around bake, registry login, push or pull. Only the two `curl` calls in `app-tests` retry.
- **`release.yaml` container-docs** reads `inputs.token`, which is not declared for `workflow_dispatch`, so the token is empty. It then falls back to a hard-coded `v4.1.1` when the lookup fails.
- **Swallowed errors:** `pre-commit run --all ||:`, a `gzip ... || echo` step, and `app-size-diff` returning `{}` when `docker manifest inspect` fails.
- **forgetool internals** (from reading its source):
  - Deferred container termination reuses the check's context, which may already be expired after a timeout.
  - Mount creation failures are only logged, so the container starts without the mount.
  - Waits like `ForExit` have no explicit timeout of their own.
  - Quoted `entrypoint` or `cmd` arguments are split on whitespace.
  - HTTP checks cannot use HTTPS.
  - A single config starts two to three containers, which slows CI.

### The read-only root filesystem check is unproven

- forgetool's `readOnlyRootfs: true` only sets `ReadonlyRootfs` on the container host config. It adds no tmpfs for `/tmp` or `/run`, and mounts nothing at `/config` unless the app lists it under `mounts[]`.
- The repo protocol runs `--read-only --tmpfs /tmp` with a `/config` volume. forgetool does not do this, so `/tmp` and `/run` stay on the read-only layer and any app that writes there would fail.
- No app enables the flag, and forgetool's unit tests stub the Docker backend, so the path has probably never run against a real container. Treat it as untested, not as known-good.

### Healthcheck design

- **Always healthy for many apps.** 69 of 187 apps have no `http`, `tcp` or `healthCommands` probe, so the inherited `/healthcheck.sh` exits 0 regardless of app state. Only 118 apps have a real probe, and only `postgresql` and `valkey` use `healthCommands`.
- **Two parsers for one file.** forgetool parses `container-test.yaml` as YAML, while the bash script uses regular expressions. They can disagree, for example on indentation, quoting or multi-line values.
- **Malformed sections pass.** A section header with no parsed checks prints a warning and exits 0.
- **Timing defaults.** Only `docusaurus` sets `--start-period`. Everything else uses Docker's defaults (30s interval, no start period), so slow first runs can report unhealthy.
- **Static ports.** Probe ports are fixed in `container-test.yaml`. Users who change an app's port by env get a healthcheck that probes the wrong one.
- **IPv4 loopback only.** All probes go to `127.0.0.1`.
- **Script drift.** Each app image carries the script version from its own last build, so images in the field run different versions.
- **Weak self-tests.** `healthcheck-tests.yaml` runs on `merge_group` and on script changes only, and the test images use an old python base rather than the real ubuntu and python bases.

### Assertion strength

- About 60 apps assert only that a file exists or that `--version` runs, for example `go-yq`, `yq`, `java8` and `cloudflareddns`.
- Only 9 `expectedOutput` assertions exist, in 6 files. `statusCode` is never set.
- `apps/scratch/container-test.yaml` has a no-op runner (`entrypoint: ''`).
- `mainRunner` has two shapes: `enabled: false` (7 files) and `cmd: sleep 999` (3 files).
- Tests run with no env. `postgresql`'s `pg_isready -U ${POSTGRES_USER}` expands to an empty user, and `mariadb` declares a required `MARIADB_ROOT_PASSWORD` but is only tested with a port check.
- 12 apps declare hard `dependencies:` (for example `healthchecks`, `netbox`, `nextcloud-fpm`). They are tested as a single container with no database. Only `wg-easy` uses the `# narrowed:` comment the protocol asks for.
- Nothing checks that every `settings.yaml` port has a probe, although the instructions require it.
- The 29 `timeoutSeconds` values (120 to 600) have no stated basis.

## Recommendations

Work is split into three phases. Phase A needs nothing from forgetool, phase B changes forgetool, and phase C updates ContainerForge once the forgetool changes are released. Within a phase, P0 comes first.

### Phase A: ContainerForge changes (no forgetool dependency)

**P0 release and gating**

- Keep testing on the PR and in the merge queue (`merge_group`), not on `main`.
- Release the digest that was tested instead of rebuilding. The `main` release should promote the digest built and tested in the `merge_group` run (or the PR head when there is no merge queue). Retag it with `regctl` or `imagetools`, then attest and sign it, without running `bake` again.
- Rebuild on `main` only for `workflow_dispatch` and retry-release, and make those paths run `app-tests` before `attest` and `sign`.
- Make `status` fail when `test` was skipped for a non-fork app change.
- Base-bump PRs (`chore(ubuntu-dep)` and `chore(python-dep)`) keep skipping the full per-app build and test, so they do not load the test backend. They instead run only the sampled smoke set from P1 and must be green before automerge.

**P0 forgetool pinning.** Pin forgetool through Renovate (`# renovate: datasource=github-releases`), verify the download against `checksums.txt`, and make the unused `version` input real. Fix the undefined `inputs.token` in `release.yaml`.

**P0 sandbox tag.** Use a unique tag per PR (`sandbox-pr<N>-<sha>`) and a `concurrency` group per app and ref.

**P1 CI reliability**

- When a base image changes, run a sampled smoke test of its dependents, not a full rebuild. Pick a fixed representative set per base plus a rotating few, found by grepping `FROM ghcr.io/trueforge-org/<base>`.
- Add an arm64 test job on `ubuntu-24.04-arm`.
- Set `timeout-minutes` on every job.
- Retry registry operations.
- Upload test logs as artifacts.
- Stop swallowing errors with `||:` and `|| echo`, and fix `app-size-diff` returning `{}` on failure.

**P1 interim healthcheck fixes** in `include/healthcheck.sh` and the base images

- Fail on malformed sections.
- Fall back to a process-alive check when an app has no probe.
- Set `--start-period` and `--interval` explicitly in the ubuntu and python bases.
- Allow overriding probed ports through env.
- Run `healthcheck-tests` on every change to the ubuntu and python bases, against the real base images.

**P2 assertions**

- Schema-validate `container-test.yaml` in pre-commit and CI.
- Add a lint for configs with only trivial checks, settings ports with no probe, and narrowed tests without the `# narrowed:` comment.
- Standardise the `mainRunner` shape.
- Fix the `scratch` no-op runner.

### Phase B: forgetool changes

**P0 correctness**

- Use a fresh context for container termination.
- Fail hard on mount setup errors.
- Warn when a timeout is clamped.
- Start a single container per main runner.
- Parse quoted arguments.
- Support HTTPS checks.
- Output JSON or JUnit results.
- Return a distinct exit code for infrastructure errors versus assertion failures, so CI can retry only infrastructure errors.

**P0 `readOnlyRootfs`**

- When the flag is set, add tmpfs mounts for `/tmp` and `/run` and an empty `/config` mount.
- Add an integration test with two canary images. One writes outside the allowed paths and must fail. The other writes only to `/tmp` and `/config` and must pass.

**P1 hardened profile.** Make it opt-in and toggleable through a `container-test.yaml` key (`hardened: true`) and/or a `--hardened` flag. It applies `cap_drop: ALL`, `no-new-privileges`, `--read-only` with tmpfs, and an empty `/config`. The default stays unchanged, so apps adopt it gradually.

**P1 healthcheck binary**

- Build it in the forgetool repo (`cmd/healthcheck`), reusing the `container-test.yaml` parser so tests and runtime cannot drift.
- Release it as a separate cut-down static binary (`forgetool-healthcheck_<ver>_linux_<arch>`) through a second goreleaser `builds:` entry on every release. Keep the full CLI out of the images.
- Include the process-alive fallback.

**P2 dependencies and credentials**

- Start sidecars from the `settings.yaml` `dependencies:` entries on a per-test network, with the dependency name as the network alias. Pin the images by digest or take them from the PR build. Wait for each dependency using its own `container-test.yaml` probes.
- Add a credentials contract. The dependency declares what it provides (`provides: {host, port, user, password, database}`), and the consumer maps it per dependency (`env: {DB_HOST: "{{ .host }}", ...}`).
- Generate random credentials per run and mask them in the logs.
- For required env with no default, inject a generated value or a new `test_value:`.
- Leave `opt_dependencies` out by default, which proves the app works without them.
- Share the same mapping with the compose generator, so docs, compose files and tests use one source of truth.

### Phase C: ContainerForge changes after forgetool

- Replace `include/healthcheck.sh` with the pinned, checksummed `forgetool-healthcheck` binary in the ubuntu and python bases. Retire the bash parser, or point its test scripts at the binary.
- Turn on retry-on-infrastructure-error in `app-tests`, publish JUnit annotations, and enable `readOnlyRootfs` or `hardened: true` app by app, starting with a pilot set.
- Add the `provides:` blocks to `postgresql`, `mariadb` and `valkey`, plus the dependency env mappings and `test_value:` entries. Pilot with `healthchecks`, then convert the other hard-dependency apps and drop the narrowing where it is no longer needed.
- Extend the settings lint: every required env has a `default`, a `test_value`, or first-run generation in `start.sh`.

## Caveats

- Nothing in this evaluation was executed. The forgetool findings come from reading its source on `main`, and `settings.yaml` and `container-test.yaml` counts come from searching the `apps/` tree.
- The forgetool repo's README and goreleaser config give inconsistent license statements. That is out of scope here but worth fixing before the healthcheck binary is redistributed in images.
