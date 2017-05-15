DESCRIPTION = "SPDX 2.0 document creation and storage"
HOMEPAGE = "https://github.com/DoSOCSv2/DoSOCSv2"
SECTION = "devel/python"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "python-docopt-native"
DEPENDS += "python-native"

SRC_URI = "https://github.com/DoSOCSv2/DoSOCSv2/archive/v0.16.1.tar.gz \
           file://0001-setup.py-delete-the-depends-install.patch \
          "

SRC_URI[md5sum] = "ecb3f47eb9f7cdd01f520e7843ef09b1"
SRC_URI[sha256sum] = "868e4c1658bd54546f6f65be9770a80ac98793da3dcb71120a52237b07a1a656"

S = "${WORKDIR}/DoSOCSv2-${PV}/"

inherit distutils native 

addtask do_dosocs2_init after do_populate_sysroot

DEPENDS += "python-jinja2-native \
            python-native \
            python-psycopg2-native \
            python-docopt-native \
            python-sqlalchemy-native \
            file-native \
            fossology-nomos-native \
            python-markupsafe-native \
            python-magic-native "

do_install_append() {
	sed -i "s|scanner_nomos_path = /usr/local/|scanner_nomos_path = ${STAGING_DIR_NATIVE}/usr/|g" ${D}${PYTHON_SITEPACKAGES_DIR}/dosocs2-0.16.1-py2.7.egg/dosocs2/configtools.py
}
python do_dosocs2_init() {

    import os
    import subprocess
    import bb
    import oe.utils
    import string

    dosocs2_init_cmd = "dosocs2 dbinit --no-confirm"
    bb.note(dosocs2_init_cmd)
    try:
        complementary_pkgs = subprocess.check_output(dosocs2_init_cmd,
                                                     stderr=subprocess.STDOUT,
                                                     shell=True)
        return
    except subprocess.CalledProcessError as e:
        bb.fatal("Could not invoke dosocs2 dbinit Command "
                 "'%s' returned %d:\n%s" % (dosocs2_init_cmd, e.returncode, e.output))
}
