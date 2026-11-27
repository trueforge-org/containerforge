target "docker-metadata-action" {}

variable "APP" {
  default = "webtop"
}

// BLOCKED: no single version; the chart uses many webtop tags. UNVERIFIED pin.
variable "VERSION" {
  // renovate: UNVERIFIED datasource (image is a family of tags; choose after the variant decision)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/selkies-project/selkies"
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
