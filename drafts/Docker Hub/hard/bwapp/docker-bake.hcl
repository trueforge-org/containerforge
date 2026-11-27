target "docker-metadata-action" {}

variable "APP" {
  default = "bwapp"
}

variable "VERSION" {
  // no renovate datasource: SourceForge is not supported and the project is archived. Pin manually.
  default = "2.2"
}

variable "BWAPP_SHA256" {
  // UNVERIFIED: sha256 of bWAPPv2.2.zip, computed at implementation time (SourceForge shows none)
  default = ""
}

variable "LICENSE" {
  default = "CC-BY-NC-ND-4.0"
}

variable "SOURCE" {
  default = "https://www.itsecgames.com/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BWAPP_SHA256 = "${BWAPP_SHA256}"
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
