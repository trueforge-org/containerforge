target "docker-metadata-action" {}

variable "APP" {
  default = "unmanic"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=unmanic
  default = "0.4.1"
}

variable "LICENSE" {
  // UNVERIFIED: PyPI reports GPL-3.0-only, GitHub reports GPL-3.0. Confirm against the repo LICENSE file.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Unmanic/unmanic"
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
