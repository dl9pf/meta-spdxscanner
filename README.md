# meta-spdxscanner

meta-spdxscanner supports the following SPDX create tools.
1. fossdriver (recommend)
2. DoSOCSv2 (Not recommended)

# This layer depends on:

- openembedded-core
- meta-openembedded/meta-oe
- meta-openembedded/meta-python

# How to use

1.  fossdriver-host.bbclass(recommend) 
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "fossdriver-host"
  SPDX_DEPLOY_DIR = "${SPDX_DEST_DIR}"
```
Note
- If you want to use fossdriver-host.bbclass, you have to make sure that fossology server and fossdriver has been installed on your host and make sure it works well.
  Please reference to https://hub.docker.com/r/fossology/fossology/ and https://github.com/fossology/fossdriver.
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
  
2. dosocs-host.bbclass (Not recommended)
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "dosocs-host"
  SPDX_DEPLOY_DIR = "${SPDX_DEST_DIR}"
```

Note
  - If you want to use dosocs-host.bbclass, you have to make sure that DoSOCSv2 has been installed on your host and it works wekk.
    Please reference to https://github.com/DoSOCSv2/DoSOCSv2.
  - To make DoSOCSv2 support multi task, Add PostgreSQL configuration for DoSOCSv2.
  
3. dosocs.bbclass (Not recommended)
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "dosocs"
  SPDX_DEPLOY_DIR = "${SPDX_DEST_DIR}"
```

Note 
  - Default, DoSOCSv2 uses SQLite for database, so dosocs.bbclass doesn't support multi tasks of do_spdx.
