SUMMARY = "File classification tool: python-magic"
DESCRIPTION = "File attempts to classify files depending \
on their contents and prints a description if a match is found."
HOMEPAGE = "http://www.darwinsys.com/file/"
SECTION = "console/utils"

# two clause BSD
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://setup.py;md5=1cf0577ca152455b257b815fcc8517de"

SRC_URI = "ftp://ftp.astron.com/pub/file/file-${PV}.tar.gz \
           file://0001-Modified-the-magic.py-for-dosocs2-to-fix-the-error-a.patch \
          "

SRC_URI[md5sum] = "e6a972d4e10d9e76407a432f4a63cd4c"
SRC_URI[sha256sum] = "3735381563f69fb4239470b8c51b876a80425348b8285a7cded8b61d6b890eca"

S="${WORKDIR}/file-${PV}/python"

inherit setuptools3 python3-dir

BBCLASSEXTEND = "native"

do_install_append(){
    install -d ${D}${datadir}/misc/
    install -m 644 ${WORKDIR}/file-${PV}/magic/Magdir/magic ${D}${datadir}/misc/magic
}
