target "docker-metadata-action" {}

variable "APP" {
  default = "ubuntu"
}

variable "VERSION" {
  default = "24.04"
}

variable "NEO_VER" {
  // renovate: datasource=github-releases depName=intel/compute-runtime  versioning=loose
  default = "25.35.35096.9"
}

variable "IGC2_VER" {
  // renovate: datasource=github-releases depName=intel/intel-graphics-compiler
  default = "2.20.3"
}

// Fixed Legacy value
variable "IGC1_LEGACY_VER" {
  default = "1.0.17537.24"
}

// Fixed Legacy value
variable "NEO_LEGACY_VER" {
  default = "24.35.30872.36"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/ubuntu"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NEO_VER = "${NEO_VER}"
    IGC2_VER = "${IGC2_VER}"
    IGC1_LEGACY_VER = "${IGC1_LEGACY_VER}"
    NEO_LEGACY_VER = "${NEO_LEGACY_VER}"
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
