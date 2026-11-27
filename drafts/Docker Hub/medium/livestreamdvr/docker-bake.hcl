target "docker-metadata-action" {}

variable "APP" {
  default = "livestreamdvr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MrBrax/LiveStreamDVR versioning=loose
  default = "LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1"
}

// UNVERIFIED: sha256 of the release zip for VERSION is not computed yet. Fill it in before building.
variable "LIVESTREAMDVR_SHA256" {
  default = ""
}

// TwitchDownloaderCLI version, from docker/fetch-tdl.sh (depName inferred from its download URL).
variable "TD_VERSION" {
  // renovate: datasource=github-releases depName=lay295/TwitchDownloader versioning=loose
  default = "1.54.9"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/MrBrax/LiveStreamDVR"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    LIVESTREAMDVR_SHA256 = "${LIVESTREAMDVR_SHA256}"
    TD_VERSION = "${TD_VERSION}"
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
