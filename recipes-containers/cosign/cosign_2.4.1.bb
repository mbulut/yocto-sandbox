GO_IMPORT = "github.com/sigstore/cosign"
HOMEPAGE = "https://${GO_IMPORT}"
SUMMARY = "Code signing and transparency for containers and binaries"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI = "\
   git://${GO_IMPORT};branch=main;protocol=https \
   file://bump-go-version.patch \
"

SRCREV = "9a4cfe1aae777984c07ce373d97a65428bbff734"

GO_INSTALL = "${GO_IMPORT}"
do_compile[network] = "1"

GO_LINKSHARED = ""
GOBUILDFLAGS:remove = "-buildmode=pie"

inherit go-mod

FILES:${PN} += "/usr/local/bin"
