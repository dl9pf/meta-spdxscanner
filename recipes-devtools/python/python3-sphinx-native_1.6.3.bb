DESCRIPTION = "Python documentation generator"
HOMEPAGE = "http://sphinx-doc.org/"
SECTION = "devel/python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6dd095eaa1e7a662b279daf80ecad7e6"

PR = "r0"
SRCNAME = "Sphinx"

SRC_URI = "http://pypi.python.org/packages/source/S/${SRCNAME}/${SRCNAME}-${PV}.tar.gz"

SRC_URI[md5sum] = "c5ad61f4e0974375ca2c2b58ef8d5411"
SRC_URI[sha256sum] = "ceb2e0d763e0c626f7afd7e3272a5bb76dd06eed1f0b908270ea31984062"

S = "${WORKDIR}/${SRCNAME}-${PV}"

inherit setuptools3 native python3native

