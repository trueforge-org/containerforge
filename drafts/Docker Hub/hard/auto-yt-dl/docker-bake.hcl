target "docker-metadata-action" {}

variable "APP" {
  default = "auto-yt-dl"
}

variable "VERSION" {
  // NOTE: no renovate annotation is possible: the fork has no tags or releases.
  // UNVERIFIED: 1.2.0 is the latest release of the original (now 404) xXGuhuXx/auto-yt-dl, per a web search; the fork commit below is assumed to match it.
  default = "1.2.0"
}

variable "COMMIT" {
  default = "32ee552af051c48fffc63fde973737ce93688684"
}

variable "SOURCE_SHA256" {
  // sha256 of https://github.com/CDeLeon94/auto-yt-dl/archive/<COMMIT>.tar.gz
  default = "0d745faab20f12561f426d3e845b1053c87c8e4b491f6c2d13506db9ea3f82e3"
}

variable "FLASK_VERSION" {
  // renovate: datasource=pypi depName=flask
  default = "3.1.3"
}

variable "PYTUBE_VERSION" {
  // renovate: datasource=pypi depName=pytube
  default = "15.0.0"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/CDeLeon94/auto-yt-dl"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    COMMIT = "${COMMIT}"
    SOURCE_SHA256 = "${SOURCE_SHA256}"
    FLASK_VERSION = "${FLASK_VERSION}"
    PYTUBE_VERSION = "${PYTUBE_VERSION}"
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
