target "docker-metadata-action" {}

variable "APP" {
  default = "wisemapping"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=wisemapping/wisemapping-frontend versioning=loose
  default = "6.0.11"
}

variable "BACKEND_REF" {
  // Pinned develop commit of wisemapping-open-source (no 6.x tags exist); bump manually. UNVERIFIED mapping to VERSION
  default = "5099d14e6290138a97f599079eaf42daa2d2ad3c"
}

variable "LICENSE" {
  default = "LicenseRef-WiseMapping-WPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/wisemapping/wisemapping-open-source/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BACKEND_REF = "${BACKEND_REF}"
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
