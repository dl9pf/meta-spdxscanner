# This class supplys common functions.


SPDXEPENDENCY += "${PATCHTOOL}-native:do_populate_sysroot"
SPDXEPENDENCY += " wget-native:do_populate_sysroot"
SPDXEPENDENCY += " subversion-native:do_populate_sysroot"
SPDXEPENDENCY += " git-native:do_populate_sysroot"
SPDXEPENDENCY += " lz4-native:do_populate_sysroot"
SPDXEPENDENCY += " lzip-native:do_populate_sysroot"
SPDXEPENDENCY += " xz-native:do_populate_sysroot"
SPDXEPENDENCY += " unzip-native:do_populate_sysroot"
SPDXEPENDENCY += " xz-native:do_populate_sysroot"
SPDXEPENDENCY += " nodejs-native:do_populate_sysroot"
SPDXEPENDENCY += " quilt-native:do_populate_sysroot"
SPDXEPENDENCY += " tar-native:do_populate_sysroot"

SPDX_DEPLOY_DIR ??= "${DEPLOY_DIR}/spdx"
SPDX_TOPDIR ?= "${WORKDIR}/spdx_sstate_dir"
SPDX_OUTDIR = "${SPDX_TOPDIR}/${TARGET_SYS}/${PF}/"
SPDX_WORKDIR = "${WORKDIR}/spdx_temp/"

do_spdx[dirs] = "${WORKDIR}"

LICENSELISTVERSION = "2.6"

# If ${S} isn't actually the top-level source directory, set SPDX_S to point at
# the real top-level directory.
SPDX_S ?= "${S}"

addtask do_spdx before do_unpack after do_fetch

def spdx_create_tarball(d, srcdir, suffix, ar_outdir):
    """
    create the tarball from srcdir
    """
    import tarfile, shutil
    # Make sure we are only creating a single tarball for gcc sources
    #if (d.getVar('SRC_URI') == ""):
    #    return

    # For the kernel archive, srcdir may just be a link to the
    # work-shared location. Use os.path.realpath to make sure
    # that we archive the actual directory and not just the link.
    srcdir = os.path.realpath(srcdir)
    build_dir = os.path.join(srcdir, "build")
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    bb.utils.mkdirhier(ar_outdir)
    if suffix:
        filename = '%s-%s.tar.gz' % (d.getVar('PF'), suffix)
    else:
        filename = '%s.tar.gz' % d.getVar('PF')
    tarname = os.path.join(ar_outdir, filename)

    bb.note('Creating %s' % tarname)
    tar = tarfile.open(tarname, 'w:gz')
    tar.add(srcdir, arcname=os.path.basename(srcdir))
    tar.close()
    shutil.rmtree(srcdir)
    return tarname

# Run do_unpack and do_patch
def spdx_get_src(d):
    import shutil
    spdx_workdir = d.getVar('SPDX_WORKDIR')
    spdx_sysroot_native = d.getVar('STAGING_DIR_NATIVE')
    pn = d.getVar('PN')

    # We just archive gcc-source for all the gcc related recipes
    if d.getVar('BPN') in ['gcc', 'libgcc']:
        bb.debug(1, 'spdx: There is bug in scan of %s is, do nothing' % pn)
        return

    # The kernel class functions require it to be on work-shared, so we dont change WORKDIR
    if not is_work_shared(d):
        # Change the WORKDIR to make do_unpack do_patch run in another dir.
        d.setVar('WORKDIR', spdx_workdir)
        # Restore the original path to recipe's native sysroot (it's relative to WORKDIR).
        d.setVar('STAGING_DIR_NATIVE', spdx_sysroot_native)

        # The changed 'WORKDIR' also caused 'B' changed, create dir 'B' for the
        # possibly requiring of the following tasks (such as some recipes's
        # do_patch required 'B' existed).
        bb.utils.mkdirhier(d.getVar('B'))

        bb.build.exec_func('do_unpack', d)

    # Make sure gcc and kernel sources are patched only once
    if not (d.getVar('SRC_URI') == "" or is_work_shared(d)):
        bb.build.exec_func('do_patch', d)
    # Some userland has no source.
    if not os.path.exists( spdx_workdir ):
        bb.utils.mkdirhier(spdx_workdir)

def create_manifest(info,sstatefile):
    import shutil
    shutil.copyfile(sstatefile,info['outfile'])

def get_cached_spdx( sstatefile ):
    import subprocess

    if not os.path.exists( sstatefile ):
        return None
    
    try:
        output = subprocess.check_output(['grep', "PackageVerificationCode", sstatefile])
    except subprocess.CalledProcessError as e:
        bb.error("Index creation command '%s' failed with return code %d:\n%s" % (e.cmd, e.returncode, e.output))
        return None
    cached_spdx_info=output.decode('utf-8').split(': ')
    return cached_spdx_info[1]

## Add necessary information into spdx file
def write_cached_spdx( info,sstatefile, ver_code ):
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
    sed_cmd = sed_replace(sed_cmd,"DocumentComment",spdx_DocumentComment)
    
    ## Creator information
    sed_cmd = sed_replace(sed_cmd,"Creator: ",info['creator']['Tool'])

    ## Package level information
    sed_cmd = sed_replace(sed_cmd, "PackageName: ", info['pn'])
    sed_cmd = sed_insert(sed_cmd, "PackageName: ", "PackageVersion: " + info['pv'])
    sed_cmd = sed_replace(sed_cmd, "PackageDownloadLocation: ",info['package_download_location'])
    sed_cmd = sed_insert(sed_cmd, "PackageDownloadLocation: ", "PackageHomePage: " + info['package_homepage'])
    sed_cmd = sed_insert(sed_cmd, "PackageDownloadLocation: ", "PackageSummary: " + "<text>" + info['package_summary'] + "</text>")
    sed_cmd = sed_insert(sed_cmd, "PackageCopyrightText: ", "PackageComment: <text>\\nmodification record : " + info['modified'] + "\\n</text>")
    sed_cmd = sed_replace(sed_cmd, "PackageVerificationCode: ",ver_code)
    sed_cmd = sed_insert(sed_cmd, "PackageVerificationCode: ", "PackageDescription: " + 
        "<text>" + info['pn'] + " version " + info['pv'] + "</text>")
    for contain in info['package_contains'].split( ):
        sed_cmd = sed_insert(sed_cmd, "PackageComment:"," \\n\\n## Relationships\\nRelationship: " + info['pn'] + " CONTAINS " + contain)
    for static_link in info['package_static_link'].split( ):
        sed_cmd = sed_insert(sed_cmd, "PackageComment:"," \\n\\n## Relationships\\nRelationship: " + info['pn'] + " STATIC_LINK " + static_link)
    sed_cmd = sed_cmd + sstatefile

    subprocess.call("%s" % sed_cmd, shell=True)

def is_work_shared(d):
    pn = d.getVar('PN')
    return bb.data.inherits_class('kernel', d) or pn.startswith('gcc-source')

def remove_dir_tree(dir_name):
    import shutil
    try:
        shutil.rmtree(dir_name)
    except:
        pass

def remove_file(file_name):
    try:
        os.remove(file_name)
    except OSError as e:
        pass

def list_files(dir ):
    for root, subFolders, files in os.walk(dir):
        for f in files:
            rel_root = os.path.relpath(root, dir)
            yield rel_root, f
    return

def hash_file(file_name):
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

def hash_string(data):
    import hashlib
    sha1 = hashlib.sha1()
    sha1.update(data.encode('utf-8'))
    return sha1.hexdigest()

def get_ver_code(dirname):
    chksums = []
    for f_dir, f in list_files(dirname):
        try:
            stats = os.stat(os.path.join(dirname,f_dir,f))
        except OSError as e:
            bb.warn( "Stat failed" + str(e) + "\n")
            continue
        chksums.append(hash_file(os.path.join(dirname,f_dir,f)))
    ver_code_string = ''.join(chksums).lower()
    ver_code = hash_string(ver_code_string)
    return ver_code

do_spdx[depends] = "${SPDXEPENDENCY}"

