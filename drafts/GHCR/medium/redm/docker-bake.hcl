target "docker-metadata-action" {}

variable "APP" {
  default = "redm"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName (no versioned runtime artifact identified; placeholder until a pin is decided)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // UNVERIFIED: NOASSERTION on GitHub; set an SPDX id only after the upstream license is read.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/citizenfx/fivem"
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
  // amd64 only, deliberately: no arm64 runtime is confirmed.
  platforms = [
    "linux/amd64"
  ]
}
