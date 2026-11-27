target "docker-metadata-action" {}

variable "APP" {
  default = "dockovpn"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=dockovpn/dockovpn versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.14.0"
}

variable "LICENSE" {
  // UNVERIFIED: "or later" not confirmed from the LICENSE file alone
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/dockovpn/dockovpn"
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
