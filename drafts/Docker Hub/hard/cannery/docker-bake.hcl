target "docker-metadata-action" {}

variable "APP" {
  default = "cannery"
}

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=shibaobun/cannery versioning=semver
  default = "1.5.10"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://gitlab.com/shibaobun/cannery"
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
