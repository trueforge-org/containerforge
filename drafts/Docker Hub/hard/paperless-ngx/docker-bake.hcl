target "docker-metadata-action" {}

variable "APP" {
  default = "gotenberg"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gotenberg/gotenberg versioning=semver extractVersion=^v(?<version>.+)$
  default = "9.10.0"
}

variable "LOK_VERSION" {
  // renovate: datasource=github-releases depName=gotenberg/lok versioning=semver extractVersion=^v(?<version>.+)$
  default = "0.0.8"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/gotenberg/gotenberg"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    LOK_VERSION = "${LOK_VERSION}"
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
