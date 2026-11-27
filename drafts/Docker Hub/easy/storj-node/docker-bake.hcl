target "docker-metadata-action" {}

variable "APP" {
  default = "storj-node"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=storj/storj versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.166.4"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0-only (repo LICENSE); "or later" not confirmed
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/storj/storj/"
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
