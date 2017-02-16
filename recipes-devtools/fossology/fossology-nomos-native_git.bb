DESCRIPTION = "SPDX 2.0 document creation and storage"
HOMEPAGE = "https://github.com/DoSOCSv2/DoSOCSv2"
SECTION = "devel/python"
LICENSE = "GPLv2"

LIC_FILES_CHKSUM = "file://GenCodeCopyright;md5=7296ec131dbd040718b64fb843d63048"
DEPENDS = "glib-2.0-native"

SRCREV = "34467fd530b832f08c095936a72c22c40fa13278"
BRANCH = "release/${PV}/master"
SRC_URI = "git://github.com/fossology/fossology.git" 

S = "${WORKDIR}/git/src/nomos/agent"

inherit native

do_compile() {
	cp ${S}/Makefile.sa ${S}/Makefile -f
	make
}

do_install() {
        oe_runmake install \
                DESTDIR="${D}" \
                PREFIX="${prefix}" \
                SBINDIR="${D}${sbindir}"
}
