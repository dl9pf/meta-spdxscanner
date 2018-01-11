DESCRIPTION = "Python documentation generator"
HOMEPAGE = "http://sphinx-doc.org/"
SECTION = "devel/python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bdf5e5254e389241208655de56611028"

PR = "r0"
SRCNAME = "sphinx"

SRC_URI = "https://github.com/sphinx-doc/sphinx/archive/${PV}.tar.gz"

SRC_URI[md5sum] = "4cb791d4ec15c0116940e7f6c27d7aef"
SRC_URI[sha256sum] = "0707b2a8a47462c06b0107426b8512a68332232241e414384b6b86cce9b7f60f"

S = "${WORKDIR}/${SRCNAME}-${PV}"

inherit setuptools3 native python3native

