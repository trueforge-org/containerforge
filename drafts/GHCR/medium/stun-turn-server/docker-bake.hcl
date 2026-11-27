target "docker-metadata-action" {}

variable "APP" {
  default = "stun-turn-server"
}

variable "VERSION" {
  // renovate: datasource=deb depName=coturn versioning=deb
  // UNVERIFIED: deb datasource for the Ubuntu archive. If renovate cannot track it, bump by hand.
  default = "4.6.1"
}

// Ubuntu archive pin for coturn in resolute (26.04). Must match VERSION.
variable "PACKAGE_VERSION" {
  default = "4.6.1-2build2"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/coturn/coturn"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
