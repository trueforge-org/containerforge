target "docker-metadata-action" {}

variable "APP" {
  default = "ring-mqtt"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tsightler/ring-mqtt versioning=semver
  default = "5.9.3"
}

variable "GO2RTC_VERSION" {
  // renovate: datasource=github-releases depName=AlexxIT/go2rtc versioning=semver
  default = "1.9.15"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/tsightler/ring-mqtt/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    GO2RTC_VERSION = "${GO2RTC_VERSION}"
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
