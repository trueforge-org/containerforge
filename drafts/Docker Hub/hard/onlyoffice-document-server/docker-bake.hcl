target "docker-metadata-action" {}

variable "APP" {
  default = "onlyoffice-document-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ONLYOFFICE/DocumentServer versioning=semver extractVersion=^v(?<version>.+)$
  default = "10.0.0"
}

variable "ONLYOFFICE_SHA256_AMD64" {
  // UNVERIFIED: fill in with sha256sum of onlyoffice-documentserver_amd64.deb for VERSION
  default = ""
}

variable "ONLYOFFICE_SHA256_ARM64" {
  // UNVERIFIED: fill in with sha256sum of onlyoffice-documentserver_arm64.deb for VERSION
  default = ""
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/ONLYOFFICE/DocumentServer"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ONLYOFFICE_SHA256_AMD64 = "${ONLYOFFICE_SHA256_AMD64}"
    ONLYOFFICE_SHA256_ARM64 = "${ONLYOFFICE_SHA256_ARM64}"
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
