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
# 1) Make sure fossdriver has beed installed in your host
# 2) By default,spdx files will be output to the path which is defined as[SPDX_DEPLOY_DIR] 
#    in ./meta/conf/spdx-dosocs.conf.
inherit spdx-common
FOSSOLOGY_SERVER ?= "http://127.0.0.1:8081/repo"

#upload OSS into No.1 folder of fossology
FOLDER_ID = "1"

HOSTTOOLS_NONFATAL += "curl"

CREATOR_TOOL = "fossology-rest.bbclass in meta-spdxscanner"

# If ${S} isn't actually the top-level source directory, set SPDX_S to point at
# the real top-level directory.
SPDX_S ?= "${S}"

python do_spdx () {
    import os, sys, shutil

    pn = d.getVar('PN')
    assume_provided = (d.getVar("ASSUME_PROVIDED") or "").split()
    if pn in assume_provided:
        for p in d.getVar("PROVIDES").split():
            if p != pn:
                pn = p
                break
    if d.getVar('BPN') in ['gcc', 'libgcc']:
        bb.debug(1, 'spdx: There is bug in scan of %s is, do nothing' % pn)
        return

    # The following: do_fetch, do_unpack and do_patch tasks have been deleted,
    # so avoid archiving do_spdx here.
    if pn.startswith('glibc-locale'):
        return
    if (d.getVar('PN') == "libtool-cross"):
        return
    if (d.getVar('PN') == "libgcc-initial"):
        return
    if (d.getVar('PN') == "shadow-sysroot"):
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
    info['token'] = (d.getVar('TOKEN', True) or "")
    
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
    #    shutil.rmtree(spdx_temp_dir)
    d.setVar('WORKDIR', spdx_workdir)
    info['sourcedir'] = spdx_workdir
    git_path = "%s/git/.git" % info['sourcedir']
    if os.path.exists(git_path):
        remove_dir_tree(git_path)
    tar_name = spdx_create_tarball(d, d.getVar('WORKDIR'), 'patched', spdx_outdir)

    ## get everything from cache.  use it to decide if 
    ## something needs to be rerun
    if not os.path.exists(spdx_outdir):
        bb.utils.mkdirhier(spdx_outdir)
    cur_ver_code = get_ver_code(spdx_workdir).split()[0] 
    ## Get spdx file
    bb.note(' run fossology rest api ...... ')
    if not os.path.isfile(tar_name):
        bb.warn(info['pn'] + "has no source, do nothing")
        return
    folder_id = (d.getVar('FOLDER_ID', True) or "")
    if invoke_rest_api(d, tar_name, sstatefile, folder_id) == False:
        bb.warn(info['pn'] + ": Get spdx file fail, please check your fossology.")
        remove_file(tar_name)
        return False
    if get_cached_spdx(sstatefile) != None:
        write_cached_spdx( info,sstatefile,cur_ver_code )
        ## CREATE MANIFEST(write to outfile )
        create_manifest(info,sstatefile)
    else:
        bb.warn(info['pn'] + ': Can\'t get the spdx file ' + '. Please check your.')
    remove_file(tar_name)
}

def has_upload(d, tar_file, folder_id):
    import os
    import subprocess
    
    (work_dir, file_name) = os.path.split(tar_file) 

    server_url = (d.getVar('FOSSOLOGY_SERVER', True) or "")
    if server_url == "":
        bb.note("Please set fossology server URL by setting FOSSOLOGY_SERVER!\n")
        raise OSError(errno.ENOENT, "No setting of  FOSSOLOGY_SERVER")

    token = (d.getVar('TOKEN', True) or "")
    if token == "":
        bb.note("Please set token of fossology server by setting TOKEN!\n" + srcPath)
        raise OSError(errno.ENOENT, "No setting of TOKEN comes from fossology server.")

    rest_api_cmd = "curl -k -s -S -X GET " + server_url + "/api/v1/uploads" \
                   + " -H \"Authorization: Bearer " + token + "\"" \
                   + " --noproxy 127.0.0.1"
    bb.note("Invoke rest_api_cmd = " + rest_api_cmd )
        
    try:
        upload_output = subprocess.check_output(rest_api_cmd, stderr=subprocess.STDOUT, shell=True)
    except subprocess.CalledProcessError as e:
        bb.error("curl failed: \n%s" % e.output.decode("utf-8"))
        return False

    upload_output = str(upload_output, encoding = "utf-8")
    upload_output = eval(upload_output)
    bb.note("upload_output = ")
    print(upload_output)
    bb.note("len of upload_output = ")
    bb.note(str(len(upload_output)))
    if len(upload_output) == 0:
        bb.note("The upload of fossology is 0.")
        return False
    bb.note("upload_output[0][uploadname] = ")
    bb.note(upload_output[0]["uploadname"])
    bb.note("len of upload_output = ")
    bb.note(str(len(upload_output)))
    for i in range(0, len(upload_output)):
        if upload_output[i]["uploadname"] == file_name:
            if str(os.path.getsize(tar_file)) == str(upload_output[i]["filesize"]) and str(upload_output[i]["folderid"]) == str(folder_id):
                bb.warn("Find " + file_name + "in fossology server \"Software Repository\" folder. So, will not upload again.")
                return upload_output[i]["id"]
    return False

def upload(d, tar_file, folder):
    import os
    import subprocess
    delaytime = 50
    i = 0
 
    server_url = (d.getVar('FOSSOLOGY_SERVER', True) or "")
    if server_url == "":
        bb.note("Please set fossology server URL by setting FOSSOLOGY_SERVER!\n")
        raise OSError(errno.ENOENT, "No setting of  FOSSOLOGY_SERVER")

    token = (d.getVar('TOKEN', True) or "")
    if token == "":
        bb.note("Please set token of fossology server by setting TOKEN!\n" + srcPath)
        raise OSError(errno.ENOENT, "No setting of TOKEN comes from fossology server.")
    
    rest_api_cmd = "curl -k -s -S -X POST " + server_url + "/api/v1/uploads" \ 
                    + " -H \"folderId: " + folder + "\"" \
                    + " -H \"Authorization: Bearer " + token + "\"" \
                    + " -H \'uploadDescription: created by REST\'" \
                    + " -H \'public: public\'"  \
                    + " -H \'Content-Type: multipart/form-data\'"  \
                    + " -F \'fileInput=@\"" + tar_file + "\";type=application/octet-stream\'" \
                    + " --noproxy 127.0.0.1"
    bb.note("Upload : Invoke rest_api_cmd = " + rest_api_cmd )
    while i < 10:
        time.sleep(delaytime)
        try:
            upload = subprocess.check_output(rest_api_cmd, stderr=subprocess.STDOUT, shell=True)
        except subprocess.CalledProcessError as e:
            bb.error(d.getVar('PN', True) + ": Upload failed: \n%s" % e.output.decode("utf-8"))
            return False
        upload = str(upload, encoding = "utf-8")
        bb.note("Upload = ")
        bb.note(upload)
        upload = eval(upload)
        if str(upload["code"]) == "201":
            return upload["message"]
        i += 1
    bb.warn(d.getVar('PN', True) + ": Upload is fail, please check your fossology server.")
    return False

def analysis(d, folder_id, upload_id):
    import os
    import subprocess
    delaytime = 50
    i = 0

    server_url = (d.getVar('FOSSOLOGY_SERVER', True) or "")
    if server_url == "":
        bb.note("Please set fossology server URL by setting FOSSOLOGY_SERVER!\n")
        raise OSError(errno.ENOENT, "No setting of  FOSSOLOGY_SERVER")

    token = (d.getVar('TOKEN', True) or "")
    if token == "":
        bb.note("Please set token of fossology server by setting TOKEN!\n" + srcPath)
        raise OSError(errno.ENOENT, "No setting of TOKEN comes from fossology server.")

    rest_api_cmd = "curl -k -s -S -X POST " + server_url + "/api/v1/jobs" \
                    + " -H \"folderId: " + str(folder_id) + "\"" \
                    + " -H \"uploadId: " + str(upload_id) + "\"" \
                    + " -H \"Authorization: Bearer " + token + "\"" \
                    + " -H \'Content-Type: application/json\'" \
                    + " --data \'{\"analysis\": {\"bucket\": true,\"copyright_email_author\": true,\"ecc\": true, \"keyword\": true,\"mime\": true,\"monk\": true,\"nomos\": true,\"package\": true},\"decider\": {\"nomos_monk\": true,\"bulk_reused\": true,\"new_scanner\": true}}\'" \
                    + " --noproxy 127.0.0.1"
    bb.note("Analysis : Invoke rest_api_cmd = " + rest_api_cmd )
    while i < 10:
        try:
            time.sleep(delaytime)
            analysis = subprocess.check_output(rest_api_cmd, stderr=subprocess.STDOUT, shell=True)
        except subprocess.CalledProcessError as e:
            bb.error("Analysis failed: \n%s" % e.output.decode("utf-8"))
            return False
        time.sleep(delaytime)
        analysis = str(analysis, encoding = "utf-8")
        bb.note("analysis  = ")
        bb.note(analysis)
        analysis = eval(analysis)
        if str(analysis["code"]) == "201":
            return analysis["message"]
        elif str(analysis["code"]) == "404":
            bb.warn(d.getVar('PN', True) + ": analysis is still not complete.")
            time.sleep(delaytime*2)
        else:
            return False
        i += 1
        bb.warn(d.getVar('PN', True) + ": Analysis is fail, will try again.")
    bb.warn(d.getVar('PN', True) + ": Analysis is fail, please check your fossology server.")
    return False

def trigger(d, folder_id, upload_id):
    import os
    import subprocess
    delaytime = 50
    i = 0

    server_url = (d.getVar('FOSSOLOGY_SERVER', True) or "")
    if server_url == "":
        bb.note("Please set fossology server URL by setting FOSSOLOGY_SERVER!\n")
        raise OSError(errno.ENOENT, "No setting of  FOSSOLOGY_SERVER")

    token = (d.getVar('TOKEN', True) or "")
    if token == "":
        bb.note("Please set token of fossology server by setting TOKEN!\n" + srcPath)
        raise OSError(errno.ENOENT, "No setting of TOKEN comes from fossology server.")

    rest_api_cmd = "curl -k -s -S -X GET " + server_url + "/api/v1/report" \
                    + " -H \"Authorization: Bearer " + token + "\"" \
                    + " -H \"uploadId: " + str(upload_id) + "\"" \
                    + " -H \'reportFormat: spdx2tv\'" \
                    + " --noproxy 127.0.0.1"
    bb.note("trigger : Invoke rest_api_cmd = " + rest_api_cmd )
    while i < 10:
        time.sleep(delaytime)
        try:
            trigger = subprocess.check_output(rest_api_cmd, stderr=subprocess.STDOUT, shell=True)
        except subprocess.CalledProcessError as e:
            bb.error(d.getVar('PN', True) + ": Trigger failed: \n%s" % e.output.decode("utf-8"))
            return False
        time.sleep(delaytime)
        trigger = str(trigger, encoding = "utf-8")
        trigger = eval(trigger)
        bb.note("trigger id = ")
        bb.note(str(trigger["message"]))
        if str(trigger["code"]) == "201":
            return trigger["message"].split("/")[-1]
        i += 1
        time.sleep(delaytime * 2)
        bb.warn(d.getVar('PN', True) + ": Trigger is fail, will try again.")
    bb.warn(d.getVar('PN', True) + ": Trigger is fail, please check your fossology server.")
    return False

def get_spdx(d, report_id, spdx_file):
    import os
    import subprocess
    import time
    delaytime = 50
    empty = True
    i = 0

    server_url = (d.getVar('FOSSOLOGY_SERVER', True) or "")
    if server_url == "":
        bb.note("Please set fossology server URL by setting FOSSOLOGY_SERVER!\n")
        raise OSError(errno.ENOENT, "No setting of  FOSSOLOGY_SERVER")

    token = (d.getVar('TOKEN', True) or "")
    if token == "":
        bb.note("Please set token of fossology server by setting TOKEN!\n" + srcPath)
        raise OSError(errno.ENOENT, "No setting of TOKEN comes from fossology server.")
    rest_api_cmd = "curl -k -s -S -X GET " + server_url + "/api/v1/report/" + report_id \
                    + " -H \'accept: text/plain\'" \
                    + " -H \"Authorization: Bearer " + token + "\"" \
                    + " --noproxy 127.0.0.1"
    bb.note("get_spdx : Invoke rest_api_cmd = " + rest_api_cmd )
    while i < 3:
        time.sleep(delaytime)
        file = open(spdx_file,'wt')
        try:
            p = subprocess.Popen(rest_api_cmd, shell=True, universal_newlines=True, stdout=file)
        except subprocess.CalledProcessError as e:
            bb.error("Get spdx failed: \n%s" % e.output.decode("utf-8"))
            return False
        ret_code = p.wait()
        file.flush()
        time.sleep(delaytime)
        file.close()
        file = open(spdx_file,'r+')
        first_line = file.readline()
        if "SPDXVersion" in first_line:
            line = file.readline()
            while line:
                if "LicenseID:" in line:
                    empty = False
                    break
                line = file.readline()
            file.close()
            if empty == True:
                bb.warn("Hasn't get license info.")
                return False
            else:
                return True
        else:
            bb.warn(d.getVar('PN', True) + ": Get the first line is " + first_line)
            bb.warn(d.getVar('PN', True) + ": spdx is not correct, will try again.")
            file.close()
            os.remove(spdx_file)
        i += 1
        time.sleep(delaytime*2)
    bb.warn(d.getVar('PN', True) + ": Get spdx failed, Please check your fossology server.")

def invoke_rest_api(d, tar_file, spdx_file, folder_id):
    import os
    import time
    i = 0
        
    bb.note("invoke fossology REST API : tar_file = %s " % tar_file)
    upload_id = has_upload(d, tar_file, folder_id)
    if upload_id == False:
        bb.note("This OSS has not been scanned. So upload it to fossology server.")
        upload_id = upload(d, tar_file, folder_id)
        if upload_id == False:
            return False
    
    if analysis(d, folder_id, upload_id) == False:
        return False
    while i < 10:
        i += 1
        report_id = trigger(d, folder_id, upload_id)
        if report_id == False:
            return False
        spdx2tv = get_spdx(d, report_id, spdx_file)
        if spdx2tv == False:
            bb.warn(d.getVar('PN', True) + ": get_spdx is unnormal. Will try again!")
        else:
            return True

    bb.warn("get_spdx of %s is unnormal. Please confirm!")
    return False
