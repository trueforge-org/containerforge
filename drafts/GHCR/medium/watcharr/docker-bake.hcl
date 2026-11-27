target "docker-metadata-action" {}

variable "APP" {
  default = "watcharr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sbondCo/Watcharr versioning=semver
  default = "4.4.0"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/sbondCo/Watcharr"
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
