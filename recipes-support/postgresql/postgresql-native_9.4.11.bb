SUMMARY = "PostgreSQL is a powerful, open source relational database system."
DESCRIPTION = "\
    PostgreSQL is an advanced Object-Relational database management system \
    (DBMS) that supports almost all SQL constructs (including \
    transactions, subselects and user-defined types and functions). The \
    postgresql package includes the client programs and libraries that \
    you'll need to access a PostgreSQL DBMS server.  These PostgreSQL \
    client programs are programs that directly manipulate the internal \
    structure of PostgreSQL databases on a PostgreSQL server. These client \
    programs can be located on the same machine with the PostgreSQL \
    server, or may be on a remote machine which accesses a PostgreSQL \
    server over a network connection. This package contains the docs \
    in HTML for the whole package, as well as command-line utilities for \
    managing PostgreSQL databases on a PostgreSQL server. \
    \
    If you want to manipulate a PostgreSQL database on a local or remote \
    PostgreSQL server, you need this package. You also need to install \
    this package if you're installing the postgresql-server package. \
"
HOMEPAGE = "http://www.postgresql.com"
LICENSE = "BSD"
DEPENDS = "tcl-native libxml2-native libxslt-native perl-native"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=81b69ddb31a8be66baafd14a90146ee2"

SRC_URI[md5sum] = "2fee03f2034034dbfcb3321a0bb0f829"
SRC_URI[sha256sum] = "e3eb51d045c180b03d2de1f0c3af9356e10be49448e966ca01dfc2c6d1cc9d23"

SRC_URI = "http://ftp.postgresql.org/pub/source/v${PV}/${BP}.tar.bz2 \
    file://0001-Use-pkg-config-for-libxml2-detection.patch \
"

LEAD_SONAME = "libpq.so"

# LDFLAGS for shared libraries
export LDFLAGS_SL = "${LDFLAGS}"

inherit autotools-brokensep pkgconfig perlnative native python3-dir

CFLAGS += "-I${STAGING_INCDIR}/${PYTHON_DIR} -I${STAGING_INCDIR}/tcl8.6"

EXTRA_OECONF = " --with-tclconfig=${STAGING_LIBDIR_NATIVE} \
                 --with-includes=${STAGING_INCDIR_NATIVE}/tcl${TCL_VER} \	
"

EXTRA_OECONF_append = " \
	--with-tcl --with-openssl --with-perl \
	--with-libxml --with-libxslt \
	${COMMON_CONFIGURE_FLAGS} \
"

do_configure_append() {
    test -d build_py3 || mkdir build_py3
    cd build_py3
        ../configure --host=${HOST_SYS} \
        --build=${BUILD_SYS} \
        --target=${TARGET_SYS} \
        ${COMMON_CONFIGURE_FLAGS}
    cd ${S}
}

do_compile_append() {
    oe_runmake -C contrib all
    cd build_py3
    #cp ${S}/src/pl/plpython/*.o ${S}/build_py3/src/pl/plpython
    oe_runmake -C src/backend/ submake-errcodes
    oe_runmake -C src/pl/plpython
}

# server needs to configure user and group
usernum = "28"
groupnum = "28"
USERADD_PACKAGES = "${PN}"
USERADD_PARAM_${PN} = "-M -g postgres -o -r -d ${localstatedir}/lib/${BPN} \
    -s /bin/bash -c 'PostgreSQL Server' -u ${usernum} postgres"
GROUPADD_PARAM_${PN} = "-g ${groupnum} -o -r postgres"

do_install_append() {
    # Follow Deian, some files belong to /usr/bin
    install -d ${D}${bindir}
    oe_runmake -C ${S}/contrib install DESTDIR=${D}
    install -m 0644 ${S}/src/pl/plpython/plpython3u* \
        ${D}${datadir}/${MAJOR_VER}/extension/
    #install -m 0755 ${S}/build_py3/src/pl/plpython/plpython3.so ${D}${libdir}/${MAJOR_VER}/lib

    # Remove the the absolute path to sysroot
    sed -i -e "s|${STAGING_LIBDIR}|${libdir}|" \
        ${D}${libdir}/pkgconfig/*.pc
}

SSTATE_SCAN_FILES += "Makefile.global"
