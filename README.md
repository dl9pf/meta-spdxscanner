# meta-spdxscanner
SPDX scanner(DoSOCSv2) support

# This layer depends on:

- openembedded-core
- meta-openembedded/meta-oe
- meta-openembedded/meta-python

# How to use

- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.
  inherit spdx-dosocs

- Redefine SPDX_DEPLOY_DIR in conf/local.conf:
  SPDX_DEPLOY_DIR = "$PATH_DEST/$SPDX_DESTDIR"

