target "docker-metadata-action" {}

variable "APP" {
  default = "stirling-pdf"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Stirling-Tools/Stirling-PDF versioning=semver
  default = "v3.5.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION; repo LICENSE is MIT with carve-outs (app/proprietary, app/saas, engine). Confirm before shipping.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Stirling-Tools/Stirling-PDF"
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
