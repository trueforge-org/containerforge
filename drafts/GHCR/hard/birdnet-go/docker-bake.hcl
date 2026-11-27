target "docker-metadata-action" {}

variable "APP" {
  default = "birdnet-go"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tphakala/birdnet-go versioning=loose
  default = "20261031"
}

// CC BY-NC-SA 4.0 is non-commercial and share-alike. The user must decide whether to ship it.
variable "LICENSE" {
  default = "CC-BY-NC-SA-4.0"
}

variable "SOURCE" {
  default = "https://github.com/tphakala/birdnet-go"
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
