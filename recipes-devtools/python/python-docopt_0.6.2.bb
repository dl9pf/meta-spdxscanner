DESCRIPTION = "Pythonic command line arguments parser, that will make you smile http://docopt.org"
HOMEPAGE = "http://docopt.org"
SECTION = "devel/python"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE-MIT;md5=2c9872d13fa571e7ba6de95055da1fe2"

SRC_NAME = "docopt"
SRC_URI = "https://github.com/docopt/docopt/archive/${PV}.tar.gz;downloadfilename=${SRC_NAME}-${PV}.tar.gz"

S = "${WORKDIR}/${SRC_NAME}-${PV}/"

SRC_URI[md5sum] = "842b44f8c95517ed5b792081a2370da1"
SRC_URI[sha256sum] = "6acf9abbbe757ef75dc2ecd9d91ba749547941abaffbe69ff2086a9e37d4904c"

inherit distutils

BBCLASSEXTEND = "native"