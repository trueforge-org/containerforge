target "docker-metadata-action" {}

variable "APP" {
  default = "papermerge"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=papermerge/papermerge-core versioning=semver
  default = "3.5.3"
}

// Must match the auth-server tag used at VERSION. Bump together with VERSION (no renovate annotation).
variable "AUTH_SERVER_VERSION" {
  default = "1.1.5"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/papermerge/papermerge-core"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    AUTH_SERVER_VERSION = "${AUTH_SERVER_VERSION}"
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
