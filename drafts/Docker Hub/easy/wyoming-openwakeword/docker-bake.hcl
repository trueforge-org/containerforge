target "docker-metadata-action" {}

variable "APP" {
  default = "wyoming-openwakeword"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=rhasspy/wyoming-openwakeword extractVersion=^v(?<version>.+)$ versioning=semver
  default = "2.1.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/rhasspy/wyoming-openwakeword"
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
