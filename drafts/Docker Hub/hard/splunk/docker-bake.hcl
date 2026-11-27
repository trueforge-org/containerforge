target "docker-metadata-action" {}

variable "APP" {
  default = "splunk"
}

variable "VERSION" {
  // renovate: datasource=docker depName=splunk/splunk
  default = "10.6.2"
}

// Bump together with VERSION by hand: the build id is not derivable from the tag.
variable "SPLUNK_BUILD" {
  default = "10.6.2.5-b07ce3b48d58"
}

// UNVERIFIED placeholder: copy the sha512 value from the .sha512 file next to the tarball. The build fails while this is empty.
variable "SPLUNK_SHA512" {
  default = ""
}

// Proprietary Splunk General Terms. Redistribution in a public image is not confirmed (see drafts plan).
variable "LICENSE" {
  default = "LicenseRef-Splunk-General-Terms"
}

variable "SOURCE" {
  default = "https://www.splunk.com/en_us/download/splunk-enterprise.html"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SPLUNK_BUILD = "${SPLUNK_BUILD}"
    SPLUNK_SHA512 = "${SPLUNK_SHA512}"
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

// Splunk publishes no arm64 Linux build.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
