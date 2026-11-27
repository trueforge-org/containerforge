target "docker-metadata-action" {}

variable "APP" {
  default = "portainer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=portainer/portainer versioning=semver
  default = "2.45.4"
}

// UNVERIFIED: Zlib is the GitHub SPDX value. The repo LICENSE file was not read.
variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/portainer/portainer"
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
