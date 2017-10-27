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

SRC_URI[md5sum] = "8fb13e5259fe447e02c4a37bc7225add"
SRC_URI[sha256sum] = "c4e3a8e44cb888c5e4b476e738503e37fb9de3b25a38c143e214bfc12109fc0b"

S="${WORKDIR}/file-${PV}/python"

inherit setuptools3 python3-dir

BBCLASSEXTEND = "native"
