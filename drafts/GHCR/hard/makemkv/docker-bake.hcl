target "docker-metadata-action" {}

variable "APP" {
  default = "makemkv"
}

variable "VERSION" {
  // renovate: UNVERIFIED no datasource for the MakeMKV version (vendor site lists only Windows and macOS 2.0.0).
  // Bump manually until a source is found. The jlesage container tag (v26.09.2) is NOT this version.
  default = "2.0.0"
}

// UNVERIFIED: MakeMKV license (makemkv-oss and closed makemkv-bin) not confirmed. Do not publish an SPDX id yet.
variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.makemkv.com/"
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
  // UNVERIFIED: vendor makemkv-bin architecture. Limited to amd64 until arm64 is confirmed.
  platforms = [
    "linux/amd64"
  ]
}
