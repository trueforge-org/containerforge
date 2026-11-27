target "docker-metadata-action" {}

variable "APP" {
  default = "starmade"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName; no machine-readable version feed found, resolve before merge
  default = "0.305.17"
}

variable "LICENSE" {
  // UNVERIFIED: license of the StarMade server not confirmed; set before merge
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.star-made.org/"
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
