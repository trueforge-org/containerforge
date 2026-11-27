target "docker-metadata-action" {}

variable "APP" {
  default = "grafana-image-renderer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=grafana/grafana-image-renderer versioning=semver
  default = "5.12.11"
}

// UNVERIFIED: pin a released Playwright version. The build fails while this is empty.
variable "PLAYWRIGHT_VERSION" {
  // renovate: datasource=npm depName=playwright
  default = ""
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/grafana/grafana-image-renderer"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PLAYWRIGHT_VERSION = "${PLAYWRIGHT_VERSION}"
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
