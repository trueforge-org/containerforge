target "docker-metadata-action" {}

variable "APP" {
  default = "pinry"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pinry/pinry versioning=semver
  default = "2.1.14"
}

variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/pinry/pinry"
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
