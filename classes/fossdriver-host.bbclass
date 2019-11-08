# This class integrates real-time license scanning, generation of SPDX standard
# output and verifiying license info during the building process.
# It is a combination of efforts from the OE-Core, SPDX and fossology projects.
#
# For more information on fossology REST API:
#   https://www.fossology.org/get-started/basic-rest-api-calls/
#
# For more information on SPDX:
#   http://www.spdx.org
#
# Note:
# 1) Make sure fossology (after 3.5.0)(https://hub.docker.com/r/fossology/fossology/) has beed started on your host
# 2) spdx files will be output to the path which is defined as[SPDX_DEPLOY_DIR].
#    By default, SPDX_DEPLOY_DIR is tmp/deploy/
# 3) Added TOKEN has been set in conf/local.conf
#

inherit spdx-common

CREATOR_TOOL = "fossdriver-host.bbclass in meta-spdxscanner"

# If ${S} isn't actually the top-level source directory, set SPDX_S to point at
# the real top-level directory.
SPDX_S ?= "${S}"

python do_spdx () {
    import os, sys, json, shutil

    pn = d.getVar('PN')
    assume_provided = (d.getVar("ASSUME_PROVIDED") or "").split()
    if pn in assume_provided:
        for p in d.getVar("PROVIDES").split():
            if p != pn:
                pn = p
                break

    # glibc-locale: do_fetch, do_unpack and do_patch tasks have been deleted,
    # so avoid archiving source here.
    if pn.startswith('glibc-locale'):
        return
    if (d.getVar('BPN') == "linux-yocto"):
        return
    if (d.getVar('PN') == "libtool-cross"):
        return
    if (d.getVar('PN') == "libgcc-initial"):
        return
    if (d.getVar('PN') == "shadow-sysroot"):
        return


    # We just archive gcc-source for all the gcc related recipes
    if d.getVar('BPN') in ['gcc', 'libgcc']:
        bb.debug(1, 'spdx: There is bug in scan of %s is, do nothing' % pn)
        return

    spdx_outdir = d.getVar('SPDX_OUTDIR')
    spdx_workdir = d.getVar('SPDX_WORKDIR')
    spdx_temp_dir = os.path.join(spdx_workdir, "temp")
    temp_dir = os.path.join(d.getVar('WORKDIR'), "temp")
    
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
    info['package_static_link'] = (d.getVar('STATIC_LINK', True) or "")
    info['modified'] = "false"
    srcuri = d.getVar("SRC_URI", False).split()
    length = len("file://")
    for item in srcuri:
        if item.startswith("file://"):
            item = item[length:]
            if item.endswith(".patch") or item.endswith(".diff"):
                info['modified'] = "true"

    manifest_dir = (d.getVar('SPDX_DEPLOY_DIR', True) or "")
    if not os.path.exists( manifest_dir ):
        bb.utils.mkdirhier( manifest_dir )

    info['outfile'] = os.path.join(manifest_dir, info['pn'] + "-" + info['pv'] + ".spdx" )
    sstatefile = os.path.join(spdx_outdir, info['pn'] + "-" + info['pv'] + ".spdx" )
    
    # if spdx has been exist
    if os.path.exists(info['outfile']):
        bb.note(info['pn'] + "spdx file has been exist, do nothing")
        return
    if os.path.exists( sstatefile ):
        bb.note(info['pn'] + "spdx file has been exist, do nothing")
        create_manifest(info,sstatefile)
        return

    spdx_get_src(d)

    bb.note('SPDX: Archiving the patched source...')
    if os.path.isdir(spdx_temp_dir):
        for f_dir, f in list_files(spdx_temp_dir):
            temp_file = os.path.join(spdx_temp_dir,f_dir,f)
            shutil.copy(temp_file, temp_dir)
        shutil.rmtree(spdx_temp_dir)
    d.setVar('WORKDIR', spdx_workdir)
    tar_name = spdx_create_tarball(d, d.getVar('WORKDIR'), 'patched', spdx_outdir)
    ## get everything from cache.  use it to decide if 
    ## something needs to be rerun
    if not os.path.exists(spdx_outdir):
        bb.utils.mkdirhier(spdx_outdir)
    cur_ver_code = get_ver_code(spdx_workdir).split()[0] 
    ## Get spdx file
    bb.note(' run fossdriver ...... ')
    if not os.path.isfile(tar_name):
        bb.warn(info['pn'] + "has no source, do nothing")
        return
    invoke_fossdriver(tar_name,sstatefile)
    if get_cached_spdx(sstatefile) != None:
        write_cached_spdx( info,sstatefile,cur_ver_code )
        ## CREATE MANIFEST(write to outfile )
        create_manifest(info,sstatefile)
    else:
        bb.warn('Can\'t get the spdx file ' + info['pn'] + '. Please check your.')
}


def invoke_fossdriver(tar_file, spdx_file):
    import os
    import time
    delaytime = 20
    
    import logging
    
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logging.basicConfig(level=logging.INFO)
    
    (work_dir, tar_file) = os.path.split(tar_file)
    os.chdir(work_dir)

    from fossdriver.config import FossConfig
    from fossdriver.server import FossServer
    from fossdriver.tasks import (CreateFolder, Upload, Scanners, Copyright, Reuse, BulkTextMatch, SPDXTV)
    if 'http_proxy' in os.environ:
        del os.environ['http_proxy']
    config = FossConfig()
    configPath = os.path.join(os.path.expanduser('~'),".fossdriverrc")
    config.configure(configPath)
    server = FossServer(config)
    server.Login()
    bb.note("invoke_fossdriver : tar_file = %s " % tar_file)
    if (Reuse(server, tar_file, "Software Repository", tar_file, "Software Repository").run()  != True):
        bb.note("This OSS has not been scanned. So upload it to fossology server.")
        i = 0
        while i < 5:
            if (Upload(server, tar_file, "Software Repository").run() != True):
                bb.warn("%s Upload failed, try again!" %  tar_file)
                time.sleep(delaytime)
                i += 1
            else:
                i = 0
                while i < 10:                
                    if (Scanners(server, tar_file, "Software Repository").run() != True):
                        bb.warn("%s Scanners failed, try again!" % tar_file)
                        time.sleep(delaytime)
                        i+= 1
                    else:
                        i = 0
                        while i < 10:
                            Copyright(server, tar_file, "Software Repository").run()
                            if (SPDXTV(server, tar_file, "Software Repository", spdx_file).run() == False):
                                bb.warn("%s SPDXTV failed, try again!" % tar_file)
                                time.sleep(delaytime)
                                i += 1
                            else:
                                return True
                        bb.warn("%s SPDXTV failed, Please check your fossology server." % tar_file)
                        return False
                bb.warn("%s Scanners failed, Please check your fossology server." % tar_file)
                return False
        bb.warn("%s  Upload fail.Please check your fossology server." % tar_file)
        return False
    else:
        i = 0
        while i < 10:
            if (SPDXTV(server, tar_file, "Software Repository", spdx_file).run() == False):
                time.sleep(1)
                bb.warn("%s SPDXTV failed, try again!" % tar_file)
                i += 1
                time.sleep(delaytime)
            else:
                return True
        bb.warn("%s SPDXTV failed, Please check your fossology server." % tar_file)
        return False

EXPORT_FUNCTIONS do_spdx
