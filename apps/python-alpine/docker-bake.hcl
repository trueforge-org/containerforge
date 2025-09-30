target "docker-metadata-action" {}

variable "APP" {
  default = "python-alpine"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/python
  default = "3.13.7"
}

variable "ALPINE_VERSION" {
  // renovate: datasource=docker depName=ghcri.io/trueforge-org/alpine
  default = "3.22.1"
}

variable "ALPINE_VERSION_STRIPPED" {
  // renovate: datasource=docker depName=ghcri.io/trueforge-org/alpine
  default = "3.22"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/python"
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
