DESCRIPTION = "SPDX 2.0 document creation and storage"
HOMEPAGE = "https://github.com/DoSOCSv2/DoSOCSv2"
SECTION = "devel/python"
LICENSE = "GPLv2"

SRCREV = "97140a1fc2905ca646220dace1692e0ede475e3e"
BRANCH = "master"
PV = "0.16.1"

addtask do_dosocs2_init before do_populate_sysroot

do_dosocs2_init[depends] += "python3-dosocs2-native:do_populate_sysroot"

DEPENDS = "python3-dosocs2-native"

BBCLASSEXTEND = "native"

inherit distutils3 python3native setuptools3 python3-dir

python do_dosocs2_init() {

    import os
    import subprocess
    import bb
    import oe.utils
    import oe.path
    import string
    
    path = os.getenv('PATH')    
    dosocs2_cmd = bb.utils.which(os.getenv('PATH'), "dosocs2")
    dosocs2_init_cmd = dosocs2_cmd + " dbinit --no-confirm"
    #dosocs2_init_cmd = dosocs2_cmd + " --help"
    bb.note("lmh test PATH = %s " % path)
    bb.note("lmh test dosocs2_init_cmd = %s " % dosocs2_init_cmd)
    try:
        complementary_pkgs = subprocess.check_output(dosocs2_init_cmd,
                                                     stderr=subprocess.STDOUT,
                                                     shell=True)
        return
    except subprocess.CalledProcessError as e:
        bb.fatal("Could not invoke dosocs2 dbinit Command "
                 "'%s' returned %d:\n%s" % (dosocs2_init_cmd, e.returncode, e.output))
}
deltask do_fetch
deltask do_unpack
deltask do_patch
deltask do_configure
deltask do_compile
deltask do_install
