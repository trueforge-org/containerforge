target "docker-metadata-action" {}

variable "APP" {
  default = "node"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/node
  default = "22.20.0"
}

variable "YARN_VERSION"{
  // renovate: datasource=npm depName=yarn
  default = "1.22.22"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/node"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    YARN_VERSION = "${YARN_VERSION}"
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
