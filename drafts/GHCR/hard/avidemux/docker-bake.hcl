target "docker-metadata-action" {}

variable "APP" {
  default = "avidemux"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jlesage/docker-avidemux versioning=loose
  // UNVERIFIED: tracks the upstream container tag from the plan; chart uses v26.11.2. Maintainer to choose.
  default = "v26.09.1"
}

// UNVERIFIED: Avidemux app license not read yet. Set the SPDX id before publishing.
variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://avidemux.org/"
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
