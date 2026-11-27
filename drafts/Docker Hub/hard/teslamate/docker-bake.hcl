target "docker-metadata-action" {}

variable "APP" {
  default = "teslamate"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=teslamate-org/teslamate versioning=semver
  default = "4.5.0"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0-only per GitHub API spdx_id; confirm whether the repo says "or later"
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/teslamate-org/teslamate"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
