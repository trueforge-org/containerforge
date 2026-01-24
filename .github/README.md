<div align="center">

## Containers

_An opinionated collection of container images_

</div>

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/trueforge-org/containerforge?style=for-the-badge)
![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/trueforge-org/containers/release.yaml?style=for-the-badge&label=Release)

---

[![docs](https://img.shields.io/badge/docs-rtfm-yellow?logo=gitbook&logoColor=white&style=for-the-badge)](https://truecharts.org/)
[![Discord](https://img.shields.io/badge/discord-chat-7289DA.svg?maxAge=60&style=for-the-badge)](https://discord.gg/Js6xv9nGuU)
[![GitHub last commit](https://img.shields.io/github/last-commit/truecharts/charts?color=brightgreen&logoColor=white&style=for-the-badge)](https://github.com/trueforge-org/truecharts/commits)

</div>

Welcome to our container images! If you are looking for a container, start by [browsing the GitHub Packages page for this repository's packages](https://github.com/orgs/trueforge-org/packages?repo_name=containers).

## Mission Statement

Our goal is to provide [semantically versioned](https://semver.org/), [rootless](https://rootlesscontaine.rs/), and [multi-architecture](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/) containers for various applications.

We adhere to the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle), logging to stdout, maintaining [one process per container](https://testdriven.io/tips/59de3279-4a2d-4556-9cd0-b444249ed31e/), avoiding tools like [s6-overlay](https://github.com/just-containers/s6-overlay), and building all images on top of [Alpine](https://hub.docker.com/_/alpine) or [Ubuntu](https://hub.docker.com/_/ubuntu).

We believe in not doing work twice without good reason. That is why we aim to follow the CI standards set by the [home-operations](https://github.com/home-operations) community [repository](https://github.com/home-operations/containers)

## Features

### Tag Immutability

Containers built here do not use immutable tags in the traditional sense, as seen with [linuxserver.io](https://fleet.linuxserver.io/) or [Bitnami](https://bitnami.com/stacks/containers). Instead, we insist on pinning to the `sha256` digest of the image. While this approach is less visually appealing, it ensures functionality and immutability.

| Container | Immutable |
|-----------------------|----|
| `ghcr.io/trueforge-org/home-assistant:rolling` | ❌ |
| `ghcr.io/trueforge-org/home-assistant:2025.5.1` | ❌ |
| `ghcr.io/trueforge-org/home-assistant:rolling@sha256:8053...` | ✅ |
| `ghcr.io/trueforge-org/home-assistant:2025.5.1@sha256:8053...` | ✅ |

_If pinning an image to the `sha256` digest, tools like [Renovate](https://github.com/renovatebot/renovate) can update containers based on digest or version changes._

### Rootless

By default the majority of our containers run as a non-root user (`65534:65534`), you are able to change the user/group by updating your configuration files.

### Standardised Base Images

We aim to base all our containers on-top of our standardised Ubuntu base image.
The following base images are available:

- Ubuntu
- Python
- Golang
- Node
- Java17
- Java21

*in some case-by-case basis, we might instead use an external base. Our aim will always be to replace those with ours in due time*

#### Docker Compose

```yaml
services:
  home-assistant:
    image: ghcr.io/trueforge-org/home-assistant:2025.5.1
    container_name: home-assistant
    user: 1000:1000 # The data volume permissions must match this user:group
    read_only: true # May require mounting in additional dirs as tmpfs
    tmpfs:
      - /tmp:rw
    # ...
```

#### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: home-assistant
# ...
spec:
  # ...
  template:
    # ...
    spec:
      containers:
        - name: home-assistant
          image: ghcr.io/trueforge-org/home-assistant:2025.5.1
          securityContext: # May require mounting in additional dirs as emptyDir
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            readOnlyRootFilesystem: true
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      # ...
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 65534 # (Requires CSI support)
        fsGroupChangePolicy: OnRootMismatch # (Requires CSI support)
      volumes:
        - name: tmp
          emptyDir: {}
      # ...
# ...
```

### Passing Arguments to Applications

Some applications only allow certain configurations via command-line arguments rather than environment variables. For such cases, refer to the Kubernetes documentation on [defining commands and arguments for a container](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/). Then, specify the desired arguments as shown below:

```yaml
args:
  - --port
  - "8080"
```

### Configuration Volume

For applications requiring persistent configuration data, the configuration volume is hardcoded to `/config` within the container, whenever reasonably possible. In most cases, this path cannot be changed.

However some applications might require other paths.

### Verify Image Signature

These container images are signed using the [attest-build-provenance](https://github.com/actions/attest-build-provenance) action.

To verify that the image was built by GitHub CI, use the following command:

```sh
gh attestation verify --repo trueforge-org/containers oci://ghcr.io/trueforge-org/${APP}:${TAG}
```

or by using [cosign](https://github.com/sigstore/cosign):

```sh
cosign verify-attestation --new-bundle-format --type slsaprovenance1 \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
    --certificate-identity-regexp "^https://github.com/trueforge-org/containers/.github/workflows/app-builder.yaml@refs/heads/main" \
    ghcr.io/trueforge-org/${APP}:${TAG}
```

### Eschewed Features

This repository does not support multiple "channels" for the same application. For example:

- **Prowlarr**, **Radarr**, and **Sonarr** only publish the **develop** branch, not the **master** (stable) branch.
- **Lidarr** only publishes the **plugins** branch
- **qBittorrent** is only published with **LibTorrent 2.x**.

This approach ensures consistency and focuses on streamlined builds.

## Contributing

We encourage contributions of any time. Contributing to this repository especially might make sense if:

- The upstream application is **actively maintained**.
- **And** one of the following applies:
  - No official upstream container exists.
  - The official image does not support **multi-architecture builds**.
  - The official image uses tools like **s6-overlay**, **gosu**, or other unconventional initialization mechanisms.

## Deprecations

Containers in this repository may be deprecated for the following reasons:

1. The upstream application is **no longer actively maintained** *and* failing build.
2. The **maintenance burden** is unsustainable, such as frequent build failures or instability.
3. The applicaitons cannot reasonably be made to fit the **Mission Statement**

**Note**: Deprecated containers will be announced with a release and remain available in the registry for as long as reasonably possible

## Difference with Home-Operations

Some might ask how our repository differs from [home-operations]https://github.com/home-operations), which we forked and follow. Our repository goals differ in the following areas:

- We aim to include any containers, even if a good upstream is available. Comparable with [linuxserver.io](https://www.linuxserver.io/)

- We keep applications even if an application is deprecated, as long as it keeps building. This ensures some updates to dependencies.

- We also host containers specifically designed for our community projects, such as [TrueCharts](https://truecharts.org)

Which repository should I follow? Whichever rocks your boat!


## Licence

[![License](https://img.shields.io/badge/license-AGPL--v3-blue.svg?style=for-the-badge)](https://github.com/trueforge-org/truecharts/blob/master/docs/LICENSE.BSD3)

---

Truecharts, is primarily based on a AGPL-v3 license, this ensures almost everyone can use and modify our charts.
Licences can vary on a per-Chart basis. This can easily be seen by the presence of a "LICENSE" file in said folder.

An exception to this, has been made for every document inside folders labeled as `docs` or `doc` and their subfolders: those folders are not licensed under AGPL-v3 and are considered "all rights reserved". Said content can be modified and changes submitted per PR, in accordance to the github End User License Agreement.

`SPDX-License-Identifier: AGPL-3.0`

## Credits

This repository draws inspiration and ideas from the [home-operations]https://github.com/home-operations), [hotio.dev](https://hotio.dev/), and [linuxserver.io](https://www.linuxserver.io/) contributors.
