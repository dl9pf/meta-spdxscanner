DESCRIPTION = "SPDX 2.0 document creation and storage"
HOMEPAGE = "https://github.com/DoSOCSv2/DoSOCSv2"
SECTION = "devel/python"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/DoSOCSv2/DoSOCSv2.git;branch=dev \
           file://0001-setup-py-delete-the-depends-install.patch \
           file://0001-Fix-bugs-because-python-from-2.x-to-3.x.patch \
          "

S = "${WORKDIR}/git"

SRCREV = "aa84166694913bf1d2cce416f1c2bff120c3ba3b"
BRANCH = "dev"
PV = "0.16.1"

inherit distutils3 python3native setuptools3 python3-dir  

DEPENDS += "python3-jinja2-native \
            python3-psycopg2-native \
            python3-docopt-native \
            python3-sqlalchemy-native \
            file-native \
            fossology-nomos-native \
            python3-markupsafe-native \
            python3-magic-native "

do_install_append() {
	sed -i "s|scanner_nomos_path = /usr/local/|scanner_nomos_path = ${STAGING_DIR_NATIVE}/usr/|g" ${D}${PYTHON_SITEPACKAGES_DIR}/dosocs2/configtools.py
}

BBCLASSEXTEND = "native"
