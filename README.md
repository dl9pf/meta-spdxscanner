# meta-spdxscanner

meta-spdxscanner supports the following SPDX create tools.
1. fossdriver (Can work with fossology 3.5.0)
2. DoSOCSv2 (Scanner comes from fossology 3.4.0)

# This layer depends on:

1. fossdriver
- openembedded-core

2. DoSOCSv2
- openembedded-core
- meta-openembedded/meta-oe
- meta-openembedded/meta-python

# How to use

1.  fossdriver-host.bbclass
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "fossdriver-host"
```
Note
- If you want to use fossdriver-host.bbclass, you have to make sure that fossology server and fossdriver has been installed on your host and make sure it works well.
  Please reference to https://hub.docker.com/r/fossology/fossology/ and https://github.com/fossology/fossdriver.
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
  
2. dosocs.bbclass 
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "dosocs"
```
Note
- There is no necessary to install any OSS on host.
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
- Default, DoSOCSv2 uses SQLite for database, so dosocs.bbclass doesn't support multi tasks of do_spdx.
