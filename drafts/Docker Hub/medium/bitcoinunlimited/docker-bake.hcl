target "docker-metadata-action" {}

variable "APP" {
  default = "bitcoinunlimited"
}

variable "VERSION" {
  // renovate: datasource=gitlab-releases depName=bitcoinunlimited/BCHUnlimited extractVersion=^BCHunlimited(?<version>.+)$ versioning=loose
  default = "2.1.0.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://gitlab.com/bitcoinunlimited/BCHUnlimited"
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
