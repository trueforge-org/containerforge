target "docker-metadata-action" {}

variable "APP" {
  default = "mymediaforalexa"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/bizmodeller/mymediaforalexa versioning=loose
  default = "1.3.156.0"
}

variable "LICENSE" {
  // UNVERIFIED: placeholder. The vendor's license name is not confirmed; replace it once known.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.mymediaalexa.com/"
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
