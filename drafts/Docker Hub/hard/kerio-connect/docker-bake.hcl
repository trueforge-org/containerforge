target "docker-metadata-action" {}

variable "APP" {
  default = "kerio-connect"
}

// No renovate datasource exists for the vendor download: bump VERSION, PATCH and BUILD by hand.
variable "VERSION" {
  default = "10.0.9"
}

variable "PATCH" {
  default = "p2"
}

variable "BUILD" {
  default = "10320"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.kerio.com/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PATCH = "${PATCH}"
    BUILD = "${BUILD}"
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
  // The vendor package is amd64 only.
  platforms = [
    "linux/amd64"
  ]
}
