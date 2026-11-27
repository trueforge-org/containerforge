target "docker-metadata-action" {}

variable "APP" {
  default = "steam-headless"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=Steam-Headless/docker-steam-headless versioning=loose
  default = "1.0.3"
}

variable "LICENSE" {
  // Wrapper scripts are GPL-2.0. The Steam client itself is under the Steam Subscriber Agreement.
  default = "LicenseRef-Steam-Subscriber-Agreement"
}

variable "SOURCE" {
  default = "https://github.com/Steam-Headless/docker-steam-headless"
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
  // Steam ships for x86-64 only.
  platforms = [
    "linux/amd64"
  ]
}
