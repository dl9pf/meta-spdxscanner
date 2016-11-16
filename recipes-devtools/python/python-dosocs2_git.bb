DESCRIPTION = "SPDX 2.0 document creation and storage"
HOMEPAGE = "https://github.com/DoSOCSv2/DoSOCSv2"
SECTION = "devel/python"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c9872d13fa571e7ba6de95055da1fe2"

DEPENDS += "python"
DEPENDS += "python-docopt"
DEPENDS_class-native += "python-docopt-native"
DEPENDS_class-native += "python-native"

SRC_URI = "git://github.com/DoSOCSv2/DoSOCSv2.git;protocol=https"

S = "${WORKDIR}/git/"

inherit distutils

RDEPENDS += "postgresql python-jinja2 python python-psycopg2 python-docopt"
RDEPENDS_class-native += "postgresql-native python-jinja2-native python-native"
RDEPENDS_class-native += "python-psycopg2-native python-docopt-native"

BBCLASSEXTEND = "native"
