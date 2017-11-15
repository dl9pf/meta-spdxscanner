# This class integrates real-time license scanning, generation of SPDX standard
# output and verifiying license info during the building process.
# It is a combination of efforts from the OE-Core, SPDX and DoSOCSv2 projects.
#
# For more information on DoSOCSv2:
#   https://github.com/DoSOCSv2
#
# For more information on SPDX:
#   http://www.spdx.org
#
# Note:
# 1) Make sure DoSOCSv2 has beed installed in your host
# 2) By default,spdx files will be output to the path which is defined as[SPDX_DEPLOY_DIR] 
#    in ./meta/conf/spdx-dosocs.conf.

PYTHON_INHERIT = "${@bb.utils.contains('PN', '-native', '', 'python3-dir', d)}"
PYTHON_INHERIT .= "${@bb.utils.contains('PACKAGECONFIG', 'python3', 'python3native', '', d)}"

inherit ${PYTHON_INHERIT} python3-dir

PYTHON = "${@bb.utils.contains('PN', '-native', '${STAGING_BINDIR_NATIVE}/${PYTHON_PN}-native/${PYTHON_PN}', '', d)}" 
EXTRANATIVEPATH += "${PYTHON_PN}-native"

# python-config and other scripts are using distutils modules
# which we patch to access these variables
export STAGING_INCDIR
export STAGING_LIBDIR

# autoconf macros will use their internal default preference otherwise
export PYTHON

#do_spdx[depends] += "python3-dosocs2-init-native:do_dosocs2_init"
do_lid_scan[depends] += "python-lid-native:do_populate_sysroot"

LIDOUTPUTDIR = "${WORKDIR}/lid_output_dir"
LIDSSTATEDIR = "${WORKDIR}/lid_sstate_dir"

# If ${S} isn't actually the top-level source directory, set SPDX_S to point at
# the real top-level directory.

LID_S ?= "${S}"

python do_lid_scan () {
    import os, sys
    import json

    pn = d.getVar("PN")
    depends = d.getVar("DEPENDS")
    ## gcc is too big to get spdx file.
    if 'gcc' in d.getVar('PN', True):
        return None
    info = {}
    info['workdir'] = (d.getVar('WORKDIR', True) or "")
    info['pn'] = (d.getVar( 'PN', True ) or "")
    info['pv'] = (d.getVar( 'PV', True ) or "")
    info['package_download_location'] = (d.getVar( 'SRC_URI', True ) or "")
    if info['package_download_location'] != "":
        info['package_download_location'] = info['package_download_location'].split()[0]
    info['spdx_version'] = (d.getVar('SPDX_VERSION', True) or '')
    info['data_license'] = (d.getVar('DATA_LICENSE', True) or '')
    info['creator'] = {}
    info['creator']['Tool'] = (d.getVar('CREATOR_TOOL', True) or '')
    info['license_list_version'] = (d.getVar('LICENSELISTVERSION', True) or '')
    info['package_homepage'] = (d.getVar('HOMEPAGE', True) or "")
    info['package_summary'] = (d.getVar('SUMMARY', True) or "")
    info['package_summary'] = info['package_summary'].replace("\n","")
    info['package_summary'] = info['package_summary'].replace("'"," ")
    info['package_contains'] = (d.getVar('CONTAINED', True) or "")

    lid_sstate_dir = (d.getVar('LIDSSTATEDIR', True) or "")
    manifest_dir = (d.getVar('LID_DEPLOY_DIR', True) or "")
    info['outfile'] = os.path.join(manifest_dir, info['pn'] + "-" + info['pv'] + ".smpkg" )
    sstatefile = os.path.join(lid_sstate_dir,
        info['pn'] + "-" + info['pv'] + ".smpkg" )

    ## something needs to be rerun
    if not os.path.exists( lid_sstate_dir ):
        bb.utils.mkdirhier( lid_sstate_dir )

    #d.setVar('WORKDIR', d.getVar('LIDOUTPUTDIR', True))
    info['sourcedir'] = (d.getVar('LID_S', True) or "")
    cur_ver_code = get_ver_code( info['sourcedir'] ).split()[0]
    cache_cur = False

    def get_lid_s() :
        import shutil

        # Forcibly expand the sysroot paths as we're about to change WORKDIR
        d.setVar('RECIPE_SYSROOT', d.getVar('RECIPE_SYSROOT'))
        d.setVar('RECIPE_SYSROOT_NATIVE', d.getVar('RECIPE_SYSROOT_NATIVE'))

        ar_outdir = d.getVar('LIDOUTPUTDIR')
        bb.note('Archiving the configured source...')

        # task, so we need to run "do_preconfigure" instead
        if pn.startswith("gcc-source-"):
            d.setVar('WORKDIR', d.getVar('ARCHIVER_WORKDIR'))
            bb.build.exec_func('do_preconfigure', d)

        # Change the WORKDIR to make do_configure run in another dir.
        if bb.data.inherits_class('kernel-yocto', d):
            bb.build.exec_func('do_kernel_configme', d)
        if bb.data.inherits_class('cmake', d):
            bb.build.exec_func('do_generate_toolchain_file', d)
        bb.build.exec_func('do_unpack', d)
 
    #get source-code for scan
    get_lid_s()
    
    if os.path.exists( sstatefile ):
        ## cache for this package exists. read it in
        cached_lid = get_cached_lid( sstatefile )
        if cached_lid:
            cached_lid = cached_lid.split()[0]
        if (cached_lid == cur_ver_code):
            bb.warn(info['pn'] + "'s ver code same as cache's. do nothing")
            cache_cur = True
            create_manifest(info,sstatefile)
    if not cache_cur:
        git_path = "%s/.git" % info['sourcedir']
        if os.path.exists(git_path):
            remove_dir_tree(git_path)

        ## Get lid scan result file
        #bb.warn(' run_dosocs2 ...... ')
        invoke_lid(info['sourcedir'],sstatefile)
        if get_cached_lid( sstatefile ) != None:
            write_cached_lid( info,sstatefile,cur_ver_code )
            ## CREATE MANIFEST(write to outfile )
            create_manifest(info,sstatefile)
        else:
            bb.warn('Can\'t get the lid result file ' + info['pn'] + '. Please check your lid.')
    d.setVar('WORKDIR', info['workdir'])
}

python () {
    pn = d.getVar("PN")
    depends = d.getVar("DEPENDS")

    if pn.find("-native") == -1:
        depends = "%s python-lid-native" % depends
        d.setVar("DEPENDS", depends)
        bb.build.addtask('do_lid_scan','do_package', 'do_patch', d)
}

def invoke_lid( OSS_src_dir, lid_result):
    import subprocess
    import string
    import json
    import codecs

    path = os.getenv('PATH')
    lid_cmd = bb.utils.which(os.getenv('PATH'), "license-identifier")
    lid_scan_cmd = lid_cmd + " -I " + OSS_src_dir
    print(lid_scan_cmd)
    try:
        lid_output = subprocess.check_output(lid_scan_cmd,
                                                 stderr=subprocess.STDOUT,
                                                 shell=True)
    except subprocess.CalledProcessError as e:
        bb.fatal("Could not invoke lid Command "
                 "'%s' returned %d:\n%s" % (lid_scan_cmd, e.returncode, e.output))
    lid_output = lid_output.decode('utf-8')

    f = codecs.open(lid_result,'w','utf-8')
    f.write(lid_output)

def create_manifest(info,sstatefile):
    import shutil
    shutil.copyfile(sstatefile,info['outfile'])

def get_cached_lid( sstatefile ):
    import subprocess

    if not os.path.exists( sstatefile ):
        return None
    
    try:
        output = subprocess.check_output(['grep', "PackageVerificationCode", sstatefile])
    except subprocess.CalledProcessError as e:
        #bb.error("Index creation command '%s' failed with return code %d:\n%s" % (e.cmd, e.returncode, e.output))
        return None
    cached_lid_info=output.decode('utf-8').split(': ')
    return cached_lid_info[1]

## Add necessary information into spdx file
def write_cached_lid( info,sstatefile, ver_code ):
    import subprocess

    def sed_replace(dest_sed_cmd,key_word,replace_info):
        dest_sed_cmd = dest_sed_cmd + "-e 's#^" + key_word + ".*#" + \
            key_word + replace_info + "#' "
        return dest_sed_cmd

    def sed_insert(dest_sed_cmd,key_word,new_line):
        dest_sed_cmd = dest_sed_cmd + "-e '/^" + key_word \
            + r"/a\\" + new_line + "' "
        return dest_sed_cmd

    ## Document level information
    sed_cmd = r"sed -i -e 's#\r$##g' " 
    spdx_DocumentComment = "<text>SPDX for " + info['pn'] + " version " \ 
        + info['pv'] + "</text>"
    insrt_line = "DocumentComment" + spdx_DocumentComment + " \n"
    insrt_line += "CreatorComment: " + " \n"
    insrt_line += "LicenseListVersion: " + info['license_list_version'] + " \n"
    insrt_line += "PackageName: " + info['pn'] + " \n" 
    insrt_line += "PackageDownloadLocation: " + info['package_download_location'] + " \n"
    insrt_line += "PackageHomePage: " + info['package_homepage'] + " \n"
    insrt_line += "PackageSummary: " + "<text>" + info['package_summary'] + "</text>" + " \n"
    insrt_line += "PackageVerificationCode: " + ver_code + " \n" 
    insrt_line += "PackageDescription: " + "<text>" + info['pn'] + " version " + info['pv'] + "</text>" + " \n"
 
    sed_cmd += "-e '1i" + insrt_line + "'"
    bb.note("lmh test sed cmd  = %s " % sed_cmd)
    
    sed_cmd = sed_cmd + sstatefile
    bb.note("lmh test1 sed cmd  = %s " % sed_cmd)
    subprocess.call("%s" % sed_cmd, shell=True)

def remove_dir_tree( dir_name ):
    import shutil
    try:
        shutil.rmtree( dir_name )
    except:
        pass

def remove_file( file_name ):
    try:
        os.remove( file_name )
    except OSError as e:
        pass

def list_files( dir ):
    for root, subFolders, files in os.walk( dir ):
        for f in files:
            rel_root = os.path.relpath( root, dir )
            yield rel_root, f
    return

def hash_file( file_name ):
    """
    Return the hex string representation of the SHA1 checksum of the filename
    """
    try:
        import hashlib
    except ImportError:
        return None
    
    sha1 = hashlib.sha1()
    with open( file_name, "rb" ) as f:
        for line in f:
            sha1.update(line)
    return sha1.hexdigest()

def hash_string( data ):
    import hashlib
    sha1 = hashlib.sha1()
    sha1.update( data.encode('utf-8') )
    return sha1.hexdigest()

def get_ver_code( dirname ):
    chksums = []
    for f_dir, f in list_files( dirname ):
        try:
            stats = os.stat(os.path.join(dirname,f_dir,f))
        except OSError as e:
            bb.warn( "Stat failed" + str(e) + "\n")
            continue
        chksums.append(hash_file(os.path.join(dirname,f_dir,f)))
    ver_code_string = ''.join( chksums ).lower()
    ver_code = hash_string( ver_code_string )
    return ver_code

