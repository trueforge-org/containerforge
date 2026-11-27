target "docker-metadata-action" {}

variable "APP" {
  default = "kapowarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Casvt/Kapowarr versioning=loose
  // Tags carry a "V" prefix (V1.3.2); renovate handling of that prefix is UNVERIFIED (may need extractVersion).
  default = "1.3.2"
}

variable "LICENSE" {
  // Root LICENSE is GNU GPL v3 (plan section 1). "or later" clause not checked.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Casvt/Kapowarr"
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
