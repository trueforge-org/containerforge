target "docker-metadata-action" {}

variable "APP" {
  default = "cryptofolio"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Xtrendence/Cryptofolio versioning=regex:^V\.(?<major>\d+)\.(?<minor>\d+)$
  // UNVERIFIED: this regex versioning has not been checked with a Renovate dry run.
  default = "V.2.2"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Xtrendence/Cryptofolio"
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
