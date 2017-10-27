DESCRIPTION = "Python-PostgreSQL Database Adapter"
HOMEPAGE = "http://initd.org/psycopg/"
SECTION = "devel/python"
LICENSE = "GPLv3+"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c9872d13fa571e7ba6de95055da1fe2"

PR = "r0"
SRCNAME = "psycopg2"

DEPENDS += "postgresql-native"

inherit native python3native

SRC_URI = "https://pypi.python.org/packages/source/p/${SRCNAME}/${SRCNAME}-${PV}.tar.gz \
          "

SRC_URI[md5sum] = "842b44f8c95517ed5b792081a2370da1"
SRC_URI[sha256sum] = "6acf9abbbe757ef75dc2ecd9d91ba749547941abaffbe69ff2086a9e37d4904c"

S = "${WORKDIR}/${SRCNAME}-${PV}"

inherit distutils3

