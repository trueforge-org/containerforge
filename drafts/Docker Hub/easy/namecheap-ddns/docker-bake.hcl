target "docker-metadata-action" {}

variable "APP" {
  default = "namecheap-ddns"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/EdwardChamberlain/namecheap_ddns currentValue=main
  default = "421a554e5267e6405850f0fe302ff95600dc8539"
}

// UNVERIFIED: README/license state AGPL-3.0; "or later" not confirmed from LICENSE.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/EdwardChamberlain/namecheap_ddns"
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
