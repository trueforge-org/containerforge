target "docker-metadata-action" {}

variable "APP" {
  default = "mediaelch"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Komet/MediaElch versioning=semver
  default = "2.12.0"
}

variable "APPIMAGE_DATE" {
  // Part of the amd64 AppImage file name. Renovate cannot update it, so bumps are manual.
  default = "2024-10-13"
}

variable "APPIMAGE_GIT" {
  // Part of the amd64 AppImage file name. Renovate cannot update it, so bumps are manual.
  default = "8032465"
}

variable "APPIMAGE_SHA256" {
  // UNVERIFIED: not computed yet. The amd64 build fails until this is set to the sha256 of the AppImage.
  default = ""
}

variable "LICENSE" {
  default = "LGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Komet/MediaElch"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    APPIMAGE_DATE = "${APPIMAGE_DATE}"
    APPIMAGE_GIT = "${APPIMAGE_GIT}"
    APPIMAGE_SHA256 = "${APPIMAGE_SHA256}"
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
