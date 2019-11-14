DESCRIPTION = "Python documentation generator"
HOMEPAGE = "http://sphinx-doc.org/"
SECTION = "devel/python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d5575c977f2e4659ece47f731f2b8319"

PR = "r0"
SRCNAME = "sphinx"

SRC_URI = "git://github.com/sphinx-doc/sphinx.git"

SRCREV = "739022730295c4968ecc212bbb80b03981eeced3"
S = "${WORKDIR}/git"

inherit setuptools3 native python3native

