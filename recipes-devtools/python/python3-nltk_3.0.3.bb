SUMMARY = "Natural Language Toolkit"
DESCRIPTION = "NLTK is a leading platform for building Python programs \
to work with human language data."
HOMEPAGE = "http://www.nltk.org/"
SECTION = "libs"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=dda944de6d6a9ad8f6bb436dffdade1b"

SRC_URI = "https://pypi.python.org/packages/source/n/nltk/nltk-${PV}.tar.gz \
          "

SRC_URI[md5sum] = "7bda53f59051337554d243bef904a5e9"
SRC_URI[sha256sum] = "28d6175984445b9cdcc719f36701f034320edbecb78b69a37d1edc876843ea93"

inherit distutils pythonnative setuptools python-dir

S="${WORKDIR}/nltk-3.0.3"

BBCLASSEXTEND = "native"


