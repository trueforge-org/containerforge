target "docker-metadata-action" {}

variable "APP" {
  default = "thunderbird"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource (Mozilla release directory, no feed confirmed); pinned to 161.0
  default = "161.0"
}

variable "LICENSE" {
  // UNVERIFIED on a fetched page: Thunderbird is MPL-2.0 by common knowledge, confirm before merge
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://www.thunderbird.net/"
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
    "linux/amd64"
  ]
}
