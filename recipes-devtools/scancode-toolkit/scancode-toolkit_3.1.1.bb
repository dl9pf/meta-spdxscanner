SUMMARY = "ScanCode toolkit"
DESCRIPTION = "A typical software project often reuses hundreds of third-party \
packages. License and origin information is not always easy to find and not \
normalized: ScanCode discovers and normalizes this data for you."
HOMEPAGE = "https://github.com/nexB/scancode-toolkit"
SECTION = "devel"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://NOTICE;md5=8aedb84647f637c585e71f8f2e96e5c8"

EXTRANATIVEPATH_remove = "python-native"

inherit setuptools pypi distutils

DEPENDS = "python-setuptools xz zlib libxml2 libxslt bzip2\
	   python-native \
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

	install ${S}/bin/* ${D}${bindir}/bin/
	mv ${S}/include/* ${D}${bindir}/include/
	#ln -sf ${S}/apache-2.0.LICENSE ${D}${bindir}/local/apache-2.0.LICENSE
	#ln -sf ${S}/appveyor.yml ${D}${bindir}/local/appveyor.yml
	#ln -sf ${S}/AUTHORS.rst ${D}${bindir}/local/AUTHORS.rst
	#ln -sf ${S}/azure-pipelines.yml ${D}${bindir}/local/azure-pipelines.yml
	#ln -sf ${S}/bin/ ${D}${bindir}/local/bin
	#ln -sf ${S}/.bumpversion.cfg ${D}${bindir}/local/.bumpversion.cfg
	#ln -sf ${S}/cc0-1.0.LICENSE ${D}${bindir}/local/cc0-1.0.LICENSE
	#ln -sf ${S}/CHANGELOG.rst ${D}${bindir}/local/CHANGELOG.rst
	#ln -sf ${S}/.cirrus.yml ${D}${bindir}/local/.cirrus.yml
	#ln -sf ${S}/codecov.yml ${D}${bindir}/local/codecov.yml
	#ln -sf ${S}/CODE_OF_CONDUCT.rst ${D}${bindir}/local/CODE_OF_CONDUCT.rst
	#ln -sf ${S}/configure ${D}${bindir}/local/configure
	#ln -sf ${S}/configure.bat ${D}${bindir}/local/configure.bat
	#ln -sf ${S}/conftest.py ${D}${bindir}/local/conftest.py
	#ln -sf ${S}/CONTRIBUTING.rst ${D}${bindir}/local/CONTRIBUTING.rst
	#ln -sf ${S}/.coveragerc ${D}${bindir}/local/.coveragerc
	##ln -sf ${S}/docs/ ${D}${bindir}/local/docs
	#ln -sf ${S}/etc/ ${D}${bindir}/local/etc
	#ln -sf ${S}/extractcode ${D}${bindir}/local/extractcode
	#ln -sf ${S}/extractcode.bat ${D}${bindir}/local/extractcode.bat
	#ln -sf ${S}/include/ ${D}${bindir}/local/include
	#ln -sf ${S}/ISSUE_TEMPLATE.md ${D}${bindir}/local/ISSUE_TEMPLATE.md
	#ln -sf ${S}/lib/ ${D}${bindir}/local/lib
	#ln -sf ${S}/MANIFEST.in ${D}${bindir}/local/MANIFEST.in
	#ln -sf ${S}/NOTICE ${D}${bindir}/local/NOTICE
	#ln -sf ${S}/plugins/ ${D}${bindir}/local/plugins
	#ln -sf ${S}/plugins-builtin/ ${D}${bindir}/local/plugins-builtin
	#ln -sf ${S}/README.rst ${D}${bindir}/local/README.rst
	#ln -sf ${S}/samples/ ${D}${bindir}/local/samples
	#ln -sf ${S}/scancode ${D}${bindir}/local/scancode
	#ln -sf ${S}/scancode.bat ${D}${bindir}/local/scancode.bat
	#ln -sf ${S}/scancode-toolkit.ABOUT ${D}${bindir}/local/scancode-toolkit.ABOUT
	#ln -sf ${S}/setup.cfg ${D}${bindir}/local/setup.cfg
	#ln -sf ${S}/setup.py ${D}${bindir}/local/setup.py
	#ln -sf ${S}/src/ ${D}${bindir}/local/src
	#ln -sf ${S}/tests ${D}${bindir}/local/tests
	#ln -sf ${S}/thirdparty/ ${D}${bindir}/local/thirdparty
	#ln -sf ${S}/.travis.yml ${D}${bindir}/local/.travis.yml
}

BBCLASSEXTEND = "native"
