# meta-spdxscanner
1. fossdriver support (recommend)

# This layer depends on:

- openembedded-core
- meta-openembedded/meta-oe
- meta-openembedded/meta-python

# How to use
1.  Install fossology (<= 3.5). Docker image is recommended.
    Please reference to https://hub.docker.com/r/fossology/fossology/ .

2.  Install fossdriver on your build host and config to make sure it works well.
    Please reference to https://github.com/fossology/fossdriver.

3.  fossdriver-host.class 
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "fossdriver-host"
  SPDX_DEPLOY_DIR = "${SPDX_DEST_DIR}"
```
Note
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
