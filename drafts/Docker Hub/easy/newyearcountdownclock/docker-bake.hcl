target "docker-metadata-action" {}

variable "APP" {
  default = "newyearcountdownclock"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/modem7/Docker-NewYearCountdown currentValue=master
  // Commit SHA of master HEAD (2026-11-14). Upstream has no releases.
  default = "393458057f1380dd0f83bed447c6ac740e342a08"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/modem7/Docker-NewYearCountdown"
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
