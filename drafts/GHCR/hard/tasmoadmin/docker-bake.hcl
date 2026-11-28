target "docker-metadata-action" {}

variable "APP" {
  default = "tasmoadmin"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=TasmoAdmin/TasmoAdmin versioning=semver
  default = "5.1.1"
}

// UNVERIFIED: no upstream checksum is published. Set this from the first verified download. The build fails while it is empty.
variable "TASMOADMIN_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/TasmoAdmin/TasmoAdmin"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TASMOADMIN_SHA256 = "${TASMOADMIN_SHA256}"
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
