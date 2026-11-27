target "docker-metadata-action" {}

variable "APP" {
  default = "crypto-exchanges-gateway"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=aloysius-pgast/crypto-exchanges-gateway versioning=semver
  default = "1.13.2"
}

variable "LICENSE" {
  default = "ISC"
}

variable "SOURCE" {
  default = "https://github.com/aloysius-pgast/crypto-exchanges-gateway"
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
