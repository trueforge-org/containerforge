target "docker-metadata-action" {}

variable "APP" {
  default = "mongodb"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=mongodb/mongo extractVersion=^r(?<version>\d+\.\d+\.\d+)$
  default = "9.0.4"
}

variable "MONGOSH_VERSION" {
  // renovate: datasource=npm depName=mongosh
  default = "2.14.1"
}

variable "LICENSE" {
  default = "SSPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/mongodb/mongo"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MONGOSH_VERSION = "${MONGOSH_VERSION}"
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
