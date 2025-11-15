target "docker-metadata-action" {}

variable "APP" {
  default = "stash"
}

variable "VERSION" {
  default = "0.29.3"

}


variable "INTEL_CR_VERSION" {
  default = "25.40.35563.4"

}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/stashapp/stash"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    INTEL_CR_VERSION = "${INTEL_CR_VERSION}"
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
