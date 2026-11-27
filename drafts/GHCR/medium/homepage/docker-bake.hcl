target "docker-metadata-action" {}

variable "APP" {
  default = "homepage"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gethomepage/homepage versioning=semver
  default = "v2.8.0"
}

variable "LICENSE" {
  // UNVERIFIED: plan says GPL-3.0 (GitHub SPDX); the Dockerfile LABEL in context says Apache-2.0. Confirm against the LICENSE file at the tag.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/gethomepage/homepage"
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
