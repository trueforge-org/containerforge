target "docker-metadata-action" {}

variable "APP" {
  default = "booklore"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=booklore-app/booklore versioning=semver
  default = "v2.4.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports AGPL-3.0, but the upstream Dockerfile label says GPL-3.0. Confirm against the repo LICENSE file.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/booklore-app/booklore"
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
