target "docker-metadata-action" {}

variable "APP" {
  default = "mediainfo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MediaArea/MediaInfo versioning=loose
  default = "26.10"
}

variable "MEDIAINFOLIB_VERSION" {
  // renovate: datasource=github-releases depName=MediaArea/MediaInfoLib versioning=loose
  default = "26.10"
}

variable "ZENLIB_VERSION" {
  // renovate: datasource=github-releases depName=MediaArea/ZenLib versioning=loose
  default = "0.4.41"
}

variable "LICENSE" {
  // UNVERIFIED: set the SPDX id once the MediaInfo licence is confirmed from the repository
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/MediaArea/MediaInfo"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION              = "${VERSION}"
    MEDIAINFOLIB_VERSION = "${MEDIAINFOLIB_VERSION}"
    ZENLIB_VERSION       = "${ZENLIB_VERSION}"
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
