target "docker-metadata-action" {}

variable "APP" {
  default = "meshroom"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=alicevision/Meshroom versioning=loose extractVersion=^v(?<version>.+)$
  default = "2025.1.0"
}

variable "LICENSE" {
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/alicevision/Meshroom"
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
    "linux/amd64"
  ]
}
