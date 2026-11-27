target "docker-metadata-action" {}

variable "APP" {
  default = "ariang"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mayswind/AriaNg versioning=semver
  default = "1.3.15"
}

// sha256 of AriaNg-<VERSION>.zip, computed locally (upstream publishes no checksum). Confirm before merge.
variable "ARIANG_SHA256" {
  default = "d2317e441966ad31f1e342cb6a6cc1c51808fb0a10cf6e39cb30b0517b3e7823"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/mayswind/AriaNg"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ARIANG_SHA256 = "${ARIANG_SHA256}"
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
