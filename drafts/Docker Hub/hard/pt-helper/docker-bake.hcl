target "docker-metadata-action" {}

variable "APP" {
  default = "pt-helper"
}

variable "VERSION" {
  // NOTE: version taken from /bin/config/config.toml inside docker.io/crazyq/pt_helper (digest in the Dockerfile).
  // No renovate annotation: the vendor only publishes a `latest` tag and the image has been unchanged since 2023-09-07.
  default = "2.4.3"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://hub.docker.com/r/crazyq/pt_helper"
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
