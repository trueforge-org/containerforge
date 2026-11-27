target "docker-metadata-action" {}

variable "APP" {
  default = "openra"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenRA/OpenRA versioning=loose
  default = "release-20250330"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/OpenRA/OpenRA"
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
  // amd64 only until the arm64 source build is written and verified.
  platforms = [
    "linux/amd64"
  ]
}
