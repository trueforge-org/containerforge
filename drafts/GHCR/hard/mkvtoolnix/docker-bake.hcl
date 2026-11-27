target "docker-metadata-action" {}

variable "APP" {
  default = "mkvtoolnix"
}

variable "VERSION" {
  // NOTE: the MKVToolNix version the apt package provides, not the jlesage wrapper tag.
  // UNVERIFIED: placeholder. Renovate datasource not confirmed (no apt tracker in this repo).
  default = "UNVERIFIED"
}

variable "PACKAGE_VERSION" {
  // UNVERIFIED: placeholder. Full apt version string from apt-cache policy mkvtoolnix on resolute.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // UNVERIFIED: placeholder. MKVToolNix upstream license not confirmed in this draft.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://mkvtoolnix.download/"
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
  // arm64 stays out until the arm64 apt line is proven
  platforms = [
    "linux/amd64"
  ]
}
