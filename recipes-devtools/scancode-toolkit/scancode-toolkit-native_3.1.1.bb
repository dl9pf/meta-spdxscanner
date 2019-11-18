SUMMARY = "ScanCode toolkit"
DESCRIPTION = "A typical software project often reuses hundreds of third-party \
packages. License and origin information is not always easy to find and not \
normalized: ScanCode discovers and normalizes this data for you."
HOMEPAGE = "https://github.com/nexB/scancode-toolkit"
SECTION = "devel"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://NOTICE;md5=8aedb84647f637c585e71f8f2e96e5c8"

EXTRANATIVEPATH_remove = "python-native"

inherit setuptools pypi distutils native

DEPENDS = "python-setuptools-native xz-native zlib-native libxml2-native \
	   libxslt-native bzip2-native \
           "

SRC_URI = "git://github.com/nexB/scancode-toolkit;branch=master \
          "

SRCREV = "1af5ac8449cbb1ce98a0b461a6d9a5ad42a5d248"


S = "${WORKDIR}/git"

do_configure(){
	./scancode --help
}

do_install_append(){
	install -d ${D}${bindir}/bin
	install -d ${D}${bindir}/include
	install -d ${D}${bindir}/local

	install ${S}/scancode ${D}${bindir}/
	install ${S}/bin/* ${D}${bindir}/bin/
	mv ${S}/include/* ${D}${bindir}/include/
}

