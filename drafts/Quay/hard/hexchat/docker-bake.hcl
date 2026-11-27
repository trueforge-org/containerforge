target "docker-metadata-action" {}

variable "APP" {
  default = "hexchat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=hexchat/hexchat versioning=semver
  default = "2.16.2"
}

variable "LICENSE" {
  // UNVERIFIED: upstream COPYING is GPL v2 with an OpenSSL exception. GitHub reports GPL-2.0. Confirm the SPDX value.
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/hexchat/hexchat"
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
