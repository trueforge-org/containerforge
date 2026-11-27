target "docker-metadata-action" {}

variable "APP" {
  default = "obs-ndi"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=DistroAV/DistroAV versioning=loose
  default = "6.2.2"
}

variable "OBS_VERSION" {
  // renovate: datasource=repology depName=ubuntu_26_04/obs-studio versioning=loose
  // UNVERIFIED: this lookup may not work in CI, otherwise bump by hand
  default = "32.1.0"
}

variable "OBS_PACKAGE_VERSION" {
  default = "32.1.0-0ubuntu3"
}

variable "DISTROAV_SHA256" {
  default = "d953385aa3082612899111801a05f63970163737cf3ab71128f56c58917bb826"
}

variable "LICENSE" {
  // UNVERIFIED: whether the source headers say "or later"
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/DistroAV/DistroAV"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    OBS_VERSION = "${OBS_VERSION}"
    OBS_PACKAGE_VERSION = "${OBS_PACKAGE_VERSION}"
    DISTROAV_SHA256 = "${DISTROAV_SHA256}"
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
  // DistroAV publishes no arm64 Linux build, so this image is amd64 only
  platforms = [
    "linux/amd64"
  ]
}
