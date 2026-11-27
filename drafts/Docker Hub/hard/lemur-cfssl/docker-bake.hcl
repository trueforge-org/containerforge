target "docker-metadata-action" {}

variable "APP" {
  default = "lemur-cfssl"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=lemur versioning=pep440
  default = "1.9.3"
}

variable "CFSSL_VERSION" {
  // renovate: datasource=github-releases depName=cloudflare/cfssl versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.7.2"
}

variable "LICENSE" {
  default = "Apache-2.0 AND BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/Netflix/lemur"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CFSSL_VERSION = "${CFSSL_VERSION}"
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
