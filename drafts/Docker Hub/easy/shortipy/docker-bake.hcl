target "docker-metadata-action" {}

variable "APP" {
  default = "shortipy"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/maschhoff/shortipy currentValue=master
  default = "52afd093cbca282d834bf389023a0bdc69055aae"
}

// UNVERIFIED: "or later" is not stated upstream; LICENSE.md is GPL v3.
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/maschhoff/shortipy/"
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
