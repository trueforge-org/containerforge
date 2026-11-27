target "docker-metadata-action" {}

variable "APP" {
  default = "zerotier"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=zerotier/ZeroTierOne versioning=semver
  default = "1.16.2"
}

variable "LICENSE" {
  // UNVERIFIED: which license applies to the packaged .deb (MPL-2.0 or the non-commercial
  // source-available license in nonfree/). Confirm with `zerotier-one -v` and the printed notice.
  default = "MPL-2.0 AND LicenseRef-ZeroTier-Source-Available-1.0"
}

variable "SOURCE" {
  default = "https://github.com/zerotier/ZeroTierOne/"
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
