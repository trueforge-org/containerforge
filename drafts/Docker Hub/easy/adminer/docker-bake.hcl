target "docker-metadata-action" {}

variable "APP" {
  default = "adminer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=vrana/adminer versioning=semver
  default = "6.3.1"
}

variable "LICENSE" {
  default = "Apache-2.0 OR GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/vrana/adminer"
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
