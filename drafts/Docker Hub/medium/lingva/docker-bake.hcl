target "docker-metadata-action" {}

variable "APP" {
  default = "lingva"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/TheDavidDelta/lingva-translate currentValue=main
  default = "0190ea5da9fbccba51e82184ca855c4ef5728fc7"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/TheDavidDelta/lingva-translate"
}

// build-time values for Next.js NEXT_PUBLIC_* (inlined at build, UNVERIFIED decision; see plan section 10)
variable "SITE_DOMAIN" {
  default = ""
}

variable "FORCE_DEFAULT_THEME" {
  default = ""
}

variable "DEFAULT_SOURCE_LANG" {
  default = "auto"
}

variable "DEFAULT_TARGET_LANG" {
  default = "en"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SITE_DOMAIN = "${SITE_DOMAIN}"
    FORCE_DEFAULT_THEME = "${FORCE_DEFAULT_THEME}"
    DEFAULT_SOURCE_LANG = "${DEFAULT_SOURCE_LANG}"
    DEFAULT_TARGET_LANG = "${DEFAULT_TARGET_LANG}"
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
