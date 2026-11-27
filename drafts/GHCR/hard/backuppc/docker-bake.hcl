target "docker-metadata-action" {}

variable "APP" {
  default = "backuppc"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=backuppc/backuppc versioning=semver
  default = "4.4.0"
}

variable "LICENSE" {
  // GitHub reports GPL-3.0. UNVERIFIED: check the LICENSE header before committing.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/backuppc/backuppc"
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
