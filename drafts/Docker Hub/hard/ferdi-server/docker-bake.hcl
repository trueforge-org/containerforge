target "docker-metadata-action" {}

variable "APP" {
  default = "ferdi-server"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=ferdium/ferdium-server versioning=semver extractVersion=^v(?<version>.+)$
  default = "2.0.14"
}

// sha256 of https://github.com/ferdium/ferdium-server/archive/refs/tags/v${VERSION}.tar.gz, computed locally (upstream publishes none)
variable "SOURCE_SHA256" {
  default = "1a02739fc05297d224ae55a33a7645f0b4bffb5f28594ae25d1e1d715663517d"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ferdium/ferdium-server"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SOURCE_SHA256 = "${SOURCE_SHA256}"
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
