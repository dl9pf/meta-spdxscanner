# meta-spdxscanner

meta-spdxscanner supports the following SPDX create tools.
1. fossology REST API (Can work with fossology after 3.5.0)
2. fossdriver (Can work with fossology)
3. scancode-toolkit
4. DoSOCSv2 (Scanner comes from fossology 3.4.0)

# This layer supplys invoking scanners as following:

1. fossology REST API
- openembedded-core

2. fossdriver
- openembedded-core

3. scancode-toolkit
- openembedded-core

4. DoSOCSv2
- openembedded-core
- meta-openembedded/meta-oe
- meta-openembedded/meta-python

# How to use

1.  fossology-rest.bbclass
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "fossology-rest"
  TOKEN = "eyJ0eXAiO..."
  FOSSOLOGY_SERVER = "http://xx.xx.xx.xx:8081/repo" //Optional,by default, it is http://127.0.0.1:8081/repo
  FOLDER_NAME = "xxxx" //Optional,by default, it is the top folder "Software Repository"(folderId=1).
```
Note
- If you want to use fossology-rest.bbclass, you have to make sure that fossology server on your host and make sure it works well.
  Please reference to https://hub.docker.com/r/fossology/fossology/.
- TOKEN can be created on fossology server after login by "Admin"->"Users"->"Edit user account"->"Create a new token".
- If you don't want to create spdx files for *-native, please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core.

2.  fossdriver-host.bbclass
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "fossdriver-host"
```
Note
- If you want to use fossdriver-host.bbclass, you have to make sure that fossology server and fossdriver has been installed on your host and make sure it works well.
  Please reference to https://hub.docker.com/r/fossology/fossology/ and https://github.com/fossology/fossdriver.
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
  
3.  scancode.bbclass
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "scancode-tk"
```
Note
- If you want to use scancode.bbclass, There is no need to install anything on your host.
- To aviod loop dependence,please use meta-spdxscanner/classes/nopackages.bbclass instead the file comes from oe-core.


4. dosocs.bbclass 
- inherit the folowing class in your conf/local.conf for all of recipes or
  in some recipes which you want.

```
  INHERIT += "dosocs"
```
Note
- There is no necessary to install any OSS on host.
- Please use meta-spdxscanner/classes/nopackages.bbclass instead of oe-core. Because there is no necessary to create spdx files for *-native.
- Default, DoSOCSv2 uses SQLite for database, so dosocs.bbclass doesn't support multi tasks of do_spdx.
