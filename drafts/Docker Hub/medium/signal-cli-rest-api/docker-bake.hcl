target "docker-metadata-action" {}

variable "APP" {
  default = "signal-cli-rest-api"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bbernhard/signal-cli-rest-api versioning=semver
  // UNVERIFIED: 0.101 matches the draft and the reviewed Dockerfile. 0.102 is the latest release (no assets); decide before the first build.
  default = "0.101"
}

variable "SIGNAL_CLI_VERSION" {
  // renovate: datasource=github-releases depName=AsamK/signal-cli versioning=semver
  // Parity with upstream 0.101 (0.14.8). Latest upstream is 0.14.10.
  default = "0.14.8"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/bbernhard/signal-cli-rest-api"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SIGNAL_CLI_VERSION = "${SIGNAL_CLI_VERSION}"
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
