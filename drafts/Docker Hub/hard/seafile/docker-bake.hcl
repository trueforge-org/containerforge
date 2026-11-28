target "docker-metadata-action" {}

variable "APP" {
  default = "seafile"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=haiwen/seafile-server versioning=loose extractVersion=^v(?<version>\d+\.\d+\.\d+)-server$
  default = "14.0.11"
}

// UNVERIFIED: AGPL-3.0-only vs AGPL-3.0-or-later; confirm against the repository license.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/haiwen/seafile-server"
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
