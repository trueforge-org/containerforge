target "docker-metadata-action" {}

variable "APP" {
  default = "restic-rest-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=restic/rest-server versioning=semver
  default = "0.15.0"
}

variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/restic/rest-server"
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
