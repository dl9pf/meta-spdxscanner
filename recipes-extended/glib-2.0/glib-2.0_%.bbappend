STATIC_LINK = "${@bb.utils.contains('PACKAGECONFIG', 'system-pcre', 'system-pcre', '', d)}"
