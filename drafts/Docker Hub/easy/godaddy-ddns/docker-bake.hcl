target "docker-metadata-action" {}

variable "APP" {
  default = "godaddy-ddns"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/jwater7/docker-godaddy-publicip-updater versioning=loose
  default = "ab3b048"
}

// UNVERIFIED: upstream has no license (LICENSE returns 404). NOASSERTION until a maintainer decides.
variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/jwater7/docker-godaddy-publicip-updater"
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
