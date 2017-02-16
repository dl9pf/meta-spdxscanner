import os
import glob
import subprocess
import shutil
import multiprocessing
import re
import bb
import tempfile
import oe.utils
import string

class Dosocs2(PackageManager):
    def __init__(self):
        self.dosocs2_cmd = bb.utils.which(os.getenv('PATH'), "dosocs2")
        dosocs2_init_cmd = "%s dbinit --no-confirm" % (self.smart_cmd)
        bb.note(dosocs2_init_cmd)
        try:
            complementary_pkgs = subprocess.check_output(dosocs2_init_cmd,
                                                         stderr=subprocess.STDOUT,
                                                         shell=True)
            return
        except subprocess.CalledProcessError as e:
            bb.fatal("Could not invoke dosocs2 dbinit Command "
                     "'%s' returned %d:\n%s" % (dosocs2_init_cmd, e.returncode, e.output))

    def _invoke_dosocs2( self, spdx_file):
        cmd = "%s oneshot %s" % (self.smart_cmd, args)

        p = subprocess.Popen(cmd.split(),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        dosocs2_output, dosocs2_error = p.communicate()
        if p.returncode != 0:
            return None

        dosocs2_output = dosocs2_output.decode('utf-8')

        f = codecs.open(spdx_file,'w','utf-8')
        f.write(dosocs2_output)


