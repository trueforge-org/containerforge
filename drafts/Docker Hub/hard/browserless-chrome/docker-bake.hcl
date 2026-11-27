target "docker-metadata-action" {}

variable "APP" {
  default = "browserless-chrome"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=browserless/browserless versioning=semver
  default = "2.64.4"
}

variable "LICENSE" {
  // Dual license: SSPL-1.0 OR Browserless Commercial License. Commercial use needs the commercial license; confirm a public image is permitted.
  default = "SSPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/browserless/browserless"
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
