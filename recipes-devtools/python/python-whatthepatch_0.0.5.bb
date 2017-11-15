SUMMARY = "A patch parsing library"
DESCRIPTION = "What The Patch!? is a library for parsing patch files. \
Its only purpose is to read a patch file and get it into some usable form by other programs."
HOMEPAGE = "https://pypi.python.org/pypi/whatthepatch"
SECTION = "libs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup.py;md5=a6377e466f612f442bbc6bb2e91eee5d"

SRC_URI = "https://pypi.python.org/packages/64/1e/7a63cba8a0d70245b9ab1c03694dabe36476fa65ee546e6dff6c8660434c/whatthepatch-0.0.5.tar.gz \
          "

SRC_URI[md5sum] = "80d7c24de99ca9501f07b42e88d6f7c1"
SRC_URI[sha256sum] = "494a2ec6c05b80f9ed1bd773f5ac9411298e1af6f0385f179840b5d60d001aa6"

S="${WORKDIR}/whatthepatch-0.0.5"
PYTHON_INHERIT = "${@bb.utils.contains('PACKAGECONFIG', 'python2', 'pythonnative', '', d)}"
PYTHON_INHERIT = "${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3native', '', d)}"

inherit distutils ${PYTHON_INHERIT} setuptools python-dir

BBCLASSEXTEND = "native"
