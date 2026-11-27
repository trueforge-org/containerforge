target "docker-metadata-action" {}

variable "APP" {
  default = "muse"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=museofficial/muse versioning=semver
  default = "v2.12.0"
}

variable "YT_DLP_VERSION" {
  // renovate: datasource=pypi depName=yt-dlp versioning=pep440
  // UNVERIFIED: pin the current yt-dlp release before merge; empty installs the latest at build time
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/museofficial/muse"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    YT_DLP_VERSION = "${YT_DLP_VERSION}"
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
