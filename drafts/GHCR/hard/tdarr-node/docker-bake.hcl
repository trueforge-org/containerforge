target "docker-metadata-action" {}

variable "APP" {
  default = "tdarr-node"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=HaveAGitGat/Tdarr versioning=loose
  default = "3.10.00"
}

variable "DATE" {
  // UNVERIFIED: build date suffix of the node zip, not resolved yet. Set it before building.
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION. Set the SPDX id from the repository LICENSE file.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/HaveAGitGat/Tdarr"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    DATE    = "${DATE}"
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
