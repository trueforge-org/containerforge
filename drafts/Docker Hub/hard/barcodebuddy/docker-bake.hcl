target "docker-metadata-action" {}

variable "APP" {
  default = "barcodebuddy"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Forceu/barcodebuddy versioning=loose
  default = "1.9.0.1"
}

// UNVERIFIED: README says "AGPL3+"; confirm -only or -or-later against the LICENSE.md header
variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/Forceu/barcodebuddy"
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
