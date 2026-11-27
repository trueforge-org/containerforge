target "docker-metadata-action" {}

variable "APP" {
  default = "doublecommander"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=doublecmd/doublecmd versioning=semver
  default = "1.2.11"
}

variable "LICENSE" {
  // GitHub SPDX for doublecmd/doublecmd. Confirm against the tarball's license file.
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/doublecmd/doublecmd"
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
