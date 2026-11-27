target "docker-metadata-action" {}

variable "APP" {
  default = "goaccess-npm-logs"
}

variable "VERSION" {
  // NOTE: Ubuntu package version, tied to the base image in the Dockerfile.
  // TODO: renovate datasource disabled until an apt datasource is confirmed for this package.
  // repologydepName=ubuntu_26_04/goaccess versioning=loose
  default = "1.9.4"
}

variable "PACKAGE_VERSION" {
  default = "1:1.9.4-1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://goaccess.io"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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

// UNVERIFIED: arm64 availability of the pinned package not yet checked with a build.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
