target "docker-metadata-action" {}

variable "APP" {
  default = "ispy-agent-dvr"
}

// UNVERIFIED renovate: the vendor has no GitHub releases and no datasource. Bump by hand.
variable "VERSION" {
  default = "8.3.2.0"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.ispyconnect.com/"
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
