target "docker-metadata-action" {}

variable "APP" {
  default = "chromium"
}

variable "VERSION" {
  // renovate: datasource=repology depName=debian_13/chromium extractVersion=^(?<version>\d+\.\d+\.\d+\.\d+) versioning=loose
  default = "156.0.8078.108"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://chromium.googlesource.com/chromium/src"
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
