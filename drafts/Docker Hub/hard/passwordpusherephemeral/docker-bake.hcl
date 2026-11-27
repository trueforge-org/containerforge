target "docker-metadata-action" {}

variable "APP" {
  default = "passwordpusher"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pglombardo/PasswordPusher versioning=semver extractVersion=^v(?<version>.+)$
  default = "2.17.4"
}

variable "RUBY_VERSION" {
  // tied to .ruby-version and Gemfile.lock of the app at VERSION; bump together with VERSION, no renovate
  default = "4.0.10"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/pglombardo/PasswordPusher"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    RUBY_VERSION = "${RUBY_VERSION}"
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
