DESCRIPTION = "is a library for parsing patch files.Its only purpose is to \
read a patch file and get it into some usable form by other programs."
HOMEPAGE = "https://github.com/cscorley/whatthepatch"
SECTION = "devel/python"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRCREV = "39c8edd34ef30d409d367ffc548d0f0fc5545a18"
BRANCH = "master"
PV = "0.0.5"

SRC_URI = "git://github.com/cscorley/whatthepatch.git;protocol=https;branch=${BRANCH} \
           "
S = "${WORKDIR}/git"

PYTHON_INHERIT = "${@bb.utils.contains('PACKAGECONFIG', 'python2', 'pythonnative', '', d)}"
PYTHON_INHERIT = "${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3native', '', d)}"

inherit distutils3 ${PYTHON_INHERIT} setuptools3 python3-dir

BBCLASSEXTEND = "native"

