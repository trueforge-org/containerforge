target "docker-metadata-action" {}

variable "APP" {
  default = "pihole"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/pi-hole/pihole versioning=docker
  default = "2026.11.0"
}

variable "FTL_VERSION" {
  // renovate: datasource=github-releases depName=pi-hole/FTL versioning=semver
  default = "v6.9"
}

// UNVERIFIED: the pi-hole core ref for this image is not confirmed. The build fails while this is empty.
variable "PIHOLE_CORE_REF" {
  default = ""
}

variable "LICENSE" {
  default = "EUPL-1.2"
}

variable "SOURCE" {
  default = "https://github.com/pi-hole/pi-hole"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    FTL_VERSION = "${FTL_VERSION}"
    PIHOLE_CORE_REF = "${PIHOLE_CORE_REF}"
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
