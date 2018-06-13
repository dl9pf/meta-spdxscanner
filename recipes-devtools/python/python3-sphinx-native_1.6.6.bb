DESCRIPTION = "Python documentation generator"
HOMEPAGE = "http://sphinx-doc.org/"
SECTION = "devel/python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d5575c977f2e4659ece47f731f2b8319"

PR = "r0"
SRCNAME = "sphinx"

SRC_URI = "https://github.com/sphinx-doc/sphinx/archive/${PV}.tar.gz"

SRC_URI[md5sum] = "567457f488771643ea4d8adffacc6b2a"
SRC_URI[sha256sum] = "1ce2041ef4538eba0dc8394a5add4a97fbfa54f026322ae4a7e6fb2c2ea51ae7"

S = "${WORKDIR}/${SRCNAME}-${PV}"

inherit setuptools3 native python3native

