DESCRIPTION = "Identify OS licenses and OS license text in source code."
HOMEPAGE = "https://source.codeaurora.org/external/qostg/lid/"
SECTION = "devel/python"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=3dd6f349067c9c1c473ae3f54efeb2e0"

SRC_URI = "git://source.codeaurora.org/external/qostg/lid;protocol=https \
          "

S = "${WORKDIR}/git"

SRCREV = "d4ec360b51f34e8e73dcad7b0539fc0029eb7a20"
BRANCH = "master"
PV = "1"

inherit distutils pythonnative setuptools python-dir  

DEPENDS += "python-pyyaml-native \
            python-future-native \
            python-nltk-native \
            python-six-native \
            python-chardet \
           "

BBCLASSEXTEND = "native"
