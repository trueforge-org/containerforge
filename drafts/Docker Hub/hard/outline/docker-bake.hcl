target "docker-metadata-action" {}

variable "APP" {
  default = "outline"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=outline/outline versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.13.0"
}

// BUSL-1.1 is source-available, not open source (Additional Use Grant, Change Date 2030-11-15 to Apache-2.0).
variable "LICENSE" {
  default = "BUSL-1.1"
}

variable "SOURCE" {
  default = "https://github.com/outline/outline"
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
