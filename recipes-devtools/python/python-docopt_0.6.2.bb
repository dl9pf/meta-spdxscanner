DESCRIPTION = "Pythonic command line arguments parser, that will make you smile http://docopt.org"
HOMEPAGE = "http://docopt.org"
SECTION = "devel/python"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE-MIT;md5=09b77fb74986791a3d4a0e746a37d88f"

SRC_NAME = "docopt"
SRC_URI = "https://github.com/docopt/docopt/archive/${PV}.tar.gz;downloadfilename=${SRC_NAME}-${PV}.tar.gz"

S = "${WORKDIR}/${SRC_NAME}-${PV}/"

SRC_URI[md5sum] = "a6c44155426fd0f7def8b2551d02fef6"
SRC_URI[sha256sum] = "2113eed1e7fbbcd43fb7ee6a977fb02d0b482753586c9dc1a8e3b7d541426e99"

inherit setuptools python-dir

BBCLASSEXTEND = "native"
