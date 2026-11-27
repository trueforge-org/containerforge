target "docker-metadata-action" {}

variable "APP" {
  default = "leaf2mqtt"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mitsumaui/leaf2mqtt versioning=loose
  // UNVERIFIED: renovate will not bump an archived repository, which is expected.
  default = "v0.6"
}

// UNVERIFIED: Dart 2.x SDK version (pubspec needs sdk <3.0.0). No renovate tracking. Fill in before the first build.
variable "DART_SDK_VERSION" {
  default = ""
}

// UNVERIFIED: sha256 of the Dart SDK zip for DART_SDK_VERSION, per arch. Fill in before the first build.
variable "DART_SDK_SHA256" {
  default = ""
}

// UNVERIFIED: sha256 of the v0.6 source tarball. Fill in before the first build.
variable "LEAF2MQTT_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/mitsumaui/leaf2mqtt"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    DART_SDK_VERSION = "${DART_SDK_VERSION}"
    DART_SDK_SHA256 = "${DART_SDK_SHA256}"
    LEAF2MQTT_SHA256 = "${LEAF2MQTT_SHA256}"
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
