# Actions Runner

A GitHub Actions self-hosted runner image. It can run in two ways:

| Mode | Use it for | How it starts |
| --- | --- | --- |
| **Kubernetes / ARC** (default) | [Actions Runner Controller](https://github.com/actions/actions-runner-controller) | ARC passes its own command (for example `/home/runner/run.sh`). Nothing else runs. |
| **Standalone** (opt-in) | `docker compose` or plain `docker run` | You set `command: /scripts/standalone.sh`. It registers the runner, then runs it. |

If you use ARC, you don't need anything on this page.

## Standalone setup with docker compose

### 1. Get a registration token

- **Repository runner:** repository → *Settings* → *Actions* → *Runners* → *New self-hosted runner*.
- **Organisation runner:** organisation → *Settings* → *Actions* → *Runners* → *New runner*.

Copy the token from the `config.sh --token …` line. It expires after about an hour, and it is only used for the first registration.

### 2. Create `docker-compose.yml`

```yaml
services:
  runner:
    image: oci.trueforge.org/containerforge/actions-runner:<version>
    command: /scripts/standalone.sh
    restart: unless-stopped
    environment:
      RUNNER_REPOSITORY_URL: https://github.com/<owner>/<repo>   # or https://github.com/<org>
      RUNNER_TOKEN: <registration token>
      RUNNER_NAME: my-runner
      RUNNER_LABELS: self-hosted,linux
    volumes:
      - ./config:/config
      - /var/run/docker.sock:/var/run/docker.sock   # optional, see "Docker access"
```

Replace `<version>` with a tag from the registry.

### 3. Start it

```sh
docker compose up -d
docker compose logs -f runner
```

The runner then shows as *Idle* in GitHub under *Settings* → *Actions* → *Runners*.

## Restarts and persistence

After registering, the script saves the runner credentials to `/config/runner`. Keep `/config` on a volume or bind mount. When the container restarts, it reuses the registration and doesn't need a new token. You can then remove `RUNNER_TOKEN` from the compose file.

Without a persistent `/config`, the runner registers again on every start and needs a fresh token each time.

## Docker access

Workflows that use `docker` (builds, service containers) need a Docker daemon. The script handles three cases:

1. **Host socket mounted:** the script gives the runner user the socket's group, then restarts itself so the group applies.
   Mounting the host socket gives the container full control of the host's Docker daemon. Only do this for runners you trust.
2. **No socket, container is privileged:** the script starts its own `dockerd`. Add `privileged: true` to the service to use this. Set `RUNNER_DIND=false` to turn it off.
3. **No socket, not privileged:** the script prints a warning and runs the runner anyway. Steps that need Docker fail, but other steps work.

If `DOCKER_HOST` is set to a `tcp://` or `ssh://` address, the script leaves Docker alone and uses that daemon.

## Environment variables

These only apply to `/scripts/standalone.sh`.

| Variable | Default | Description |
| --- | --- | --- |
| `RUNNER_REPOSITORY_URL` | none, **required** | Repository or organisation URL to register with. |
| `RUNNER_TOKEN` | none | Registration token. Required for the first registration only. |
| `RUNNER_NAME` | container hostname | Runner name shown in GitHub. |
| `RUNNER_LABELS` | none | Comma-separated extra labels. |
| `RUNNER_GROUP` | none | Runner group (organisation runners). |
| `RUNNER_WORKDIR` | `/tmp/runner/work` | Directory where jobs run. |
| `RUNNER_EPHEMERAL` | `false` | `true` registers a one-job runner that is removed after the job. |
| `RUNNER_DISABLE_UPDATE` | `false` | `true` turns off the runner's self-update. |
| `RUNNER_REMOVE_ON_EXIT` | `false` | `true` removes the runner from GitHub when the container stops. This needs `RUNNER_TOKEN` to still be set. |
| `RUNNER_DIND` | `auto` | `false` stops the script from starting its own `dockerd`. |

## Troubleshooting

- **`RUNNER_REPOSITORY_URL is required`:** the variable is missing. The script exits with code 1.
- **`RUNNER_TOKEN is required`:** there is no saved registration in `/config/runner`, and no token was given.
- **Registration is rejected:** the token has expired or was already used. Generate a new one.
- **The runner appears twice or stays offline:** a stale runner is still registered. Remove it in GitHub, or set `RUNNER_REMOVE_ON_EXIT=true`.
- **`docker: permission denied`:** check that the socket is mounted and look for a warning in the container log. If `/var/run/docker.sock` can't be reached, use a privileged container instead.
