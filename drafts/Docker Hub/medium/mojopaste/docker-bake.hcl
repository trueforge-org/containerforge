target "docker-metadata-action" {}

variable "APP" {
  default = "mojopaste"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=jhthorsen/app-mojopaste versioning=loose
  // UNVERIFIED: tag 1.05 is the plan's pick. Confirm it contains script/mojopaste and a cpanfile.
  default = "1.05"
}

variable "LICENSE" {
  // BLOCKED: set this to the confirmed upstream license before merge. The upstream license is unverified.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/jhthorsen/app-mojopaste"
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
