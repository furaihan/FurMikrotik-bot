/system script
add name=tg_cmd_help policy=read \
    source=":local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n\r\
    \n:local helpBody;\r\
    \n:set helpBody (\"Hi, \$from%0ALorem ipsum dolor sit amet, consectetur ad\
    ipisicing elit, sed do eiusmod tempor incididunt \\\r\
    \n                ut labore et dolore magna aliqua. Ut enim ad minim venia\
    m%0A%0AAvailable Commands:%0A\")\r\
    \n\r\
    \n:foreach script in=[/system script find where name~\"tg_cmd_\"] do={\r\
    \n    :local name [/system script get \$script name]\r\
    \n    :local command [:pick \$name 7 [:len \$name]]\r\
    \n    :set helpBody (\$helpBody.\"/\$command%0A\")\r\
    \n}\r\
    \n:set helpBody (\$helpBody.\"%0ANote:%0A> For detailed command help type:\
    \_<command> help%0A\\\r\
    \n                > *install* and *update* command is only available for b\
    ot admin\")\r\
    \n\$send chat=\$chatid text=\$helpBody mode=\"Markdown\";\r\
    \n"
add name=tg_cmd_ping policy=read \
    source=":local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n#ip address of api.telegram.org\r\
    \n:local address 149.154.167.220\r\
    \n\r\
    \n:if ([:typeof [:toip \$params]] = \"ip\" ) do={:set address \$params}\r\
    \n:local time\r\
    \n#flood-ping\r\
    \n/tool flood-ping \$address count=10 do={\r\
    \n    :set time \$\"avg-rtt\";\r\
    \n}\r\
    \n\$send chat=\$chatid text=(\"Pong \\F0\\9F\\8F\\93%0A\$time\\ ms\")"
add name=tg_cmd_update policy=read \
    source=":local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local tolower [:parse [/system script get func_lowercase source]]\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n:local config [\$fconfig]\r\
    \n\r\
    \n:local trusted [:toarray (\$config->\"trusted\")]\r\
    \n:local allowed ([:type [:find \$trusted \$chatid]] != \"nil\")\r\
    \n:if (!\$allowed) do={\r\
    \n :put \"Unknown sender, keep silence\"\r\
    \n :return -1\r\
    \n}\r\
    \n\r\
    \n:local paramsLower [\$tolower \$params];\r\
    \n:local fetchCommand ([/tool fetch url=\"https://raw.githubusercontent.co\
    m/furaihan/FurMikrotik-bot/master/util/availableCommand\" output=user as-v\
    alue]->\"data\")\r\
    \n:local availableCommand [:toarray \$fetchCommand]\r\
    \n\r\
    \n:local sendHelp do={\r\
    \n    :local send [:parse [/system script get tg_sendMessage source]]\r\
    \n    :local txt (\"Hi, \$from%0AUse this command to update your installed\
    \_script%0A\\\r\
    \n                *Usage:*%0A/update <command>%0A*Example:*%0A/update _jok\
    es_%0A\\\r\
    \n                *Note:*%0Ato see the available script just type /update \
    list\");\r\
    \n    \$send chat=\$chatid text=\$txt mode=\"Markdown\";\r\
    \n}\r\
    \n\r\
    \n:if (\$paramsLower = \"list\") do={\r\
    \n\t:local listScript (\"List of available script%0A%0A\")\r\
    \n\t:local number 0\r\
    \n\t:for i from=0 to=([:len \$availableCommand] - 1) do={\r\
    \n\t\t:local command [:pick \$availableCommand \$i]\r\
    \n\t\t:set number (\$number + 1)\r\
    \n\t\t:set listScript (\$listScript.\"\$number. \$command%0A\")\r\
    \n\t}\r\
    \n\t:set listScript (\$listScript.\"%0Ato update a command just type /upda\
    te <command>. For example%0A/update jokes\")\r\
    \n\t\$send chat=\$chatid text=\$listScript mode=\"Markdown\"; :return -1\r\
    \n}\r\
    \n:if (\$paramsLower = \"help\") do={\r\
    \n\t\$sendHelp from=\$from chatid=\$chatid; :return -1\r\
    \n}\r\
    \n\r\
    \n:if ([:len \$params] > 0) do={\r\
    \n    :local valid ([:typeof [:find \$availableCommand \$paramsLower]] != \
    \"nil\")\r\
    \n    :if (\$valid) do={\r\
    \n        :local scriptName (\"tg_cmd_\$paramsLower\")\r\
    \n        :if ([:len [/system script find where name=\$scriptName]] > 0) d\
    o={\r\
    \n            /system script remove \$scriptName;\r\
    \n            :local scriptUrlInstall (\"https://raw.githubusercontent.com\
    /furaihan/FurMikrotik-bot/master/script%20text/\$scriptName\")\r\
    \n            :do {\r\
    \n                :local scriptSource ([/tool fetch url=\$scriptUrlInstall\
    \_output=user as-value]->\"data\")\r\
    \n                /system script add name=\$scriptName policy=read source=\
    \$scriptSource\r\
    \n                \$send chat=\$chatid text=(\"Script \$scriptName updated\
    \_successfully\")\r\
    \n            } on-error={\r\
    \n                \$send chat=\$chatid text=(\"Failed to update script, pl\
    ease try again later\")\r\
    \n            }\t\r\
    \n        } else={\r\
    \n            \$send chat=\$chatid text=(\"\$scriptName is not installed, \
    please use /install \$paramsLower to install\")\r\
    \n        }\r\
    \n    } else={\r\
    \n        :if ([:typeof [:find \$params \" \"]] != \"num\" ) do={\r\
    \n            \$send chat=\$chatid text=(\"Unfortunately, \$params script \
    is not available yet, please type /update list to show you all of availabl\
    e scripts\")\r\
    \n            :return -1\r\
    \n\t    } else={\r\
    \n\t\t    \$sendHelp from=\$from chatid=\$chatid; :return -1\r\
    \n\t    }\r\
    \n    }\r\
    \n} else={\r\
    \n    \$sendHelp from=\$from chatid=\$chatid; :return -1\r\
    \n}"
add name=tg_cmd_install policy=read \
    source=":local send [:parse [/system script get tg_sendMessage source]]\r\
    \n:local tolower [:parse [/system script get func_lowercase source]]\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n:local config [\$fconfig]\r\
    \n\r\
    \n:local trusted [:toarray (\$config->\"trusted\")]\r\
    \n:local allowed ([:type [:find \$trusted \$chatid]] != \"nil\")\r\
    \n:if (!\$allowed) do={\r\
    \n :put \"Unknown sender, keep silence\"\r\
    \n :return -1\r\
    \n}\r\
    \n\r\
    \n:local paramsLower [\$tolower \$params];\r\
    \n:local fetchCommand ([/tool fetch url=\"https://raw.githubusercontent.co\
    m/furaihan/FurMikrotik-bot/master/util/availableCommand\" output=user as-v\
    alue]->\"data\")\r\
    \n:local availableCommand [:toarray \$fetchCommand]\r\
    \n\r\
    \n:local sendHelp do={\r\
    \n\t:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n    :local txt (\"Hi, \$from%0AUse this command to install a script%0A\\\
    \r\
    \n                *Usage:*%0A/install <command>%0A*Example:*%0A/install _j\
    okes_%0A\\\r\
    \n                *Note:*%0Ato see the available script just type /install\
    \_list\");\r\
    \n    \$send chat=\$chatid text=\$txt mode=\"Markdown\";\r\
    \n}\r\
    \n\r\
    \n:if (\$paramsLower = \"list\") do={\r\
    \n\t:local listScript (\"List of available script%0A%0A\")\r\
    \n\t:local number 0\r\
    \n\t:for i from=0 to=([:len \$availableCommand] - 1) do={\r\
    \n\t\t:local command [:pick \$availableCommand \$i]\r\
    \n\t\t:set number (\$number + 1)\r\
    \n\t\t:set listScript (\$listScript.\"\$number. \$command%0A\")\r\
    \n\t}\r\
    \n\t:set listScript (\$listScript.\"%0Ato install a command just type /ins\
    tall <command>. For example%0A/install jokes\")\r\
    \n\t\$send chat=\$chatid text=\$listScript mode=\"Markdown\"; :return -1\r\
    \n}\r\
    \n\r\
    \n:if (\$paramsLower = \"help\") do={\r\
    \n\t\$sendHelp from=\$from chatid=\$chatid; :return -1\r\
    \n}\r\
    \n\r\
    \n:local valid ([:typeof [:find \$availableCommand \$paramsLower]] != \"ni\
    l\")\r\
    \n:if (\$valid) do={\r\
    \n\t:local scriptName (\"tg_cmd_\$paramsLower\")\r\
    \n\t:if ([:len [/system script find where name=\$scriptName]] > 0) do={\r\
    \n\t\t\$send chat=\$chatid text=(\"\$scriptName script has been installed,\
    \_if you want to update the script, use /update instead\");\r\
    \n\t\t:return -1\r\
    \n\t}\r\
    \n\t:local scriptUrlInstall (\"https://raw.githubusercontent.com/furaihan/\
    FurMikrotik-bot/master/script%20text/\$scriptName\")\r\
    \n\t:do {\r\
    \n\t\t:local scriptSource ([/tool fetch url=\$scriptUrlInstall output=user\
    \_as-value]->\"data\")\r\
    \n\t\t/system script add name=\$scriptName policy=read source=\$scriptSour\
    ce\r\
    \n\t\t\$send chat=\$chatid text=(\"Script \$scriptName installed successfu\
    lly\"); :return -1\r\
    \n\t} on-error={\r\
    \n\t\t\$send chat=\$chatid text=(\"Failed to install script\"); :return -1\
    \r\
    \n\t}\t\r\
    \n} else={\r\
    \n\t:if ([:typeof [:find \$params \" \"]] != \"num\" ) do={\r\
    \n\t\t\$send chat=\$chatid text=(\"Unfortunately, \$params script is not a\
    vailable yet, please type /install list to show you all of available scrip\
    ts\")\r\
    \n\t} else={\r\
    \n\t\t\$sendHelp from=\$from chatid=\$chatid; :return -1\r\
    \n\t}\r\
    \n\t\r\
    \n}"
add name=tg_cmd_ipcalc policy=read \
    source=":local send [:parse [/system script get tg_sendMessage source]];\r\
    \n:local tolower [:parse [/system script get func_lowercase source]];\r\
    \n\r\
    \n:local ipPrefix [:tostr \$params];\r\
    \n:local paramsLower [\$tolower \$params];\r\
    \n\r\
    \n:local sendHelp do={\r\
    \n    :local send [:parse [/system script get tg_sendMessage source]];\r\
    \n    :local txt (\"Hi \$from, use this command to calculate an ip address\
    \_(Max , Min, Network, and Broadcast Address)%0A%0A\\\r\
    \n                *Usage:*%0A/ipcalc <ip-prefix>%0A%0A*Example:*%0A/ipcalc\
    \_192.168.1.54/26\")\r\
    \n    \$send chat=\$chatid text=\$txt mode=\"Markdown\"\r\
    \n}\r\
    \n\r\
    \n#source: https://s.id/t5AP7\r\
    \n:if ((\$paramsLower = \"help\") or ([:len \$params] = 0)) do={\$sendHelp\
    \_from=\$from chatid=\$chatid; :return -1}\r\
    \n:local ipAddress [:toip [:pick \$ipPrefix 0 [:find \$ipPrefix \"/\"]]]\r\
    \n:if ([:typeof \$ipAddress] != \"ip\") do={ \$send chat=\$chatid text=(\"\
    Invalid Ip Address\"); :return -1}\r\
    \n:local subnetBits [:tonum [:pick \$ipPrefix ([:find \$ipPrefix \"/\"] + \
    1) [:len \$ipPrefix]]];\r\
    \n:local subnetMask ((255.255.255.255 << (32 - \$subnetBits)) & 255.255.25\
    5.255);\r\
    \n:if ([:len \$params] > 0) do={\r\
    \n    :local result (\"*\$params*%0A%0A\")\r\
    \n    :set result (\$result.\"Address: \$ipAddress%0A\")\r\
    \n    :set result (\$result.\"Subnet Mask: \$subnetMask%0A\")\r\
    \n    :set result (\$result.\"Network Address: \".(\$ipAddress & \$subnetM\
    ask).\"/\$subnetBits%0A\")\r\
    \n    :set result (\$result.\"Max Address: \".((\$ipAddress | ~\$subnetMas\
    k) ^ 0.0.0.1).\"%0A\")\r\
    \n    :set result (\$result.\"Min Address: \".((\$ipAddress & \$subnetMask\
    ) | 0.0.0.1).\"%0A\")\r\
    \n    :set result (\$result.\"Broadcast Address: \".(\$ipAddress | ~\$subn\
    etMask).\"%0A\")\r\
    \n    \$send chat=\$chatid text=\$result mode=\"Markdown\"\r\
    \n}"
add name=func_fetch policy=read \
    source="#########################################################\r\
    \n# Wrapper for /tools fetch\r\
    \n#  Input:\r\
    \n#    mode\r\
    \n#    upload=yes/no\r\
    \n#    user\r\
    \n#    password\r\
    \n#    address\r\
    \n#    host\r\
    \n#    httpdata\r\
    \n#    httpmethod\r\
    \n#    check-certificate\r\
    \n#    src-path\r\
    \n#    dst-path\r\
    \n#    ascii=yes/no\r\
    \n#    url\r\
    \n#    resfile\r\
    \n\r\
    \n:local res \"fetchresult.txt\"\r\
    \n:if ([:len \$resfile]>0) do={:set res \$resfile}\r\
    \n#:put \$res\r\
    \n\r\
    \n:local cmd \"/tool fetch\"\r\
    \n:if ([:len \$mode]>0) do={:set cmd \"\$cmd mode=\$mode\"}\r\
    \n:if ([:len \$upload]>0) do={:set cmd \"\$cmd upload=\$upload\"}\r\
    \n:if ([:len \$user]>0) do={:set cmd \"\$cmd user=\\\"\$user\\\"\"}\r\
    \n:if ([:len \$password]>0) do={:set cmd \"\$cmd password=\\\"\$password\\\
    \"\"}\r\
    \n:if ([:len \$address]>0) do={:set cmd \"\$cmd address=\\\"\$address\\\"\
    \"}\r\
    \n:if ([:len \$host]>0) do={:set cmd \"\$cmd host=\\\"\$host\\\"\"}\r\
    \n:if ([:len \$\"http-data\"]>0) do={:set cmd \"\$cmd http-data=\\\"\$\"ht\
    tp-data\"\\\"\"}\r\
    \n:if ([:len \$\"http-method\"]>0) do={:set cmd \"\$cmd http-method=\\\"\$\
    \"http-method\"\\\"\"}\r\
    \n:if ([:len \$\"check-certificate\"]>0) do={:set cmd \"\$cmd check-certif\
    icate=\\\"\$\"check-certificate\"\\\"\"}\r\
    \n:if ([:len \$\"src-path\"]>0) do={:set cmd \"\$cmd src-path=\\\"\$\"src-\
    path\"\\\"\"}\r\
    \n:if ([:len \$\"dst-path\"]>0) do={:set cmd \"\$cmd dst-path=\\\"\$\"dst-\
    path\"\\\"\"}\r\
    \n:if ([:len \$ascii]>0) do={:set cmd \"\$cmd ascii=\\\"\$ascii\\\"\"}\r\
    \n:if ([:len \$url]>0) do={:set cmd \"\$cmd url=\\\"\$url\\\"\"}\r\
    \n\r\
    \n:put \">> \$cmd\"\r\
    \n\r\
    \n:global FETCHRESULT\r\
    \n:set FETCHRESULT \"none\"\r\
    \n\r\
    \n:local script \"\\\r\
    \n :global FETCHRESULT;\\\r\
    \n :do {\\\r\
    \n   \$cmd;\\\r\
    \n   :set FETCHRESULT \\\"success\\\";\\\r\
    \n } on-error={\\\r\
    \n  :set FETCHRESULT \\\"failed\\\";\\\r\
    \n }\\\r\
    \n\"\r\
    \n:execute script=\$script file=\$res\r\
    \n:local cnt 0\r\
    \n#:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n:while (\$cnt<100 and \$FETCHRESULT=\"none\") do={ \r\
    \n :delay 1s\r\
    \n :set \$cnt (\$cnt+1)\r\
    \n #:put \"\$cnt -> \$FETCHRESULT\"\r\
    \n}\r\
    \n:local content [/file get [find name=\$res] content]\r\
    \n#:put \$content\r\
    \nif (\$content~\"finished\") do={:return \"success\"}\r\
    \n:return \$FETCHRESULT"
add name=func_lowercase policy=read \
    source=":local alphabet {\"A\"=\"a\";\"B\"=\"b\";\"C\"=\"c\";\"D\"=\"d\";\
    \"E\"=\"e\";\"F\"=\"f\";\"G\"=\"g\";\"H\"=\"h\";\"I\"=\"i\";\"J\"=\"j\";\"\
    K\"=\"k\";\"L\"=\"l\";\"M\"=\"m\";\"N\"=\"n\";\"O\"=\"o\";\"P\"=\"p\";\"Q\
    \"=\"q\";\"R\"=\"r\";\"S\"=\"s\";\"T\"=\"t\";\"U\"=\"u\";\"V\"=\"v\";\"X\"\
    =\"x\";\"Z\"=\"z\";\"Y\"=\"y\";\"W\"=\"w\"};\r\
    \n:local result\r\
    \n:local character\r\
    \n:for strings from=0 to=([:len \$1] - 1) do={\r\
    \n\t:local single [:pick \$1 \$strings]\r\
    \n\t:set character (\$alphabet->\$single)\r\
    \n\t:if ([:typeof \$character] = \"str\") do={set single \$character}\r\
    \n\t:set result (\$result.\$single)\r\
    \n}\r\
    \n:return \$result\r\
    \n"
add name=func_uppercase policy=read \
    source=":local alphabet {\"a\"=\"A\";\"b\"=\"B\";\"c\"=\"C\";\"d\"=\"D\";\
    \"e\"=\"E\";\"f\"=\"F\";\"g\"=\"G\";\"h\"=\"H\";\"i\"=\"I\";\"j\"=\"J\";\"\
    k\"=\"K\";\"l\"=\"L\";\"m\"=\"M\";\"n\"=\"N\";\"o\"=\"O\";\"p\"=\"P\";\"q\
    \"=\"Q\";\"r\"=\"R\";\"s\"=\"S\";\"t\"=\"T\";\"u\"=\"U\";\"v\"=\"V\";\"x\"\
    =\"X\";\"z\"=\"Z\";\"y\"=\"Y\";\"w\"=\"W\"};\r\
    \n:local result\r\
    \n:local character\r\
    \n:for strings from=0 to=([:len \$1] - 1) do={\r\
    \n    :local single [:pick \$1 \$strings]\r\
    \n    :set character (\$alphabet->\$single)\r\
    \n    :if ([:typeof \$character] = \"str\") do={set single \$character}\r\
    \n    :set result (\$result.\$single)\r\
    \n}\r\
    \n:return \$result"
add name=tg_config policy=read \
    source="######################################\r\
    \n# Telegram bot API, VVS/BlackVS 2017\r\
    \n#                                Config file\r\
    \n######################################\r\
    \n:log info \"telegram configuration file has been loaded\";\r\
    \n\r\
    \n# to use config insert next lines:\r\
    \n#:local fconfig [:parse [/system script get tg_config source]]\r\
    \n#:local config [\$fconfig]\r\
    \n#:put \$config\r\
    \n\r\
    \n######################################\r\
    \n# Common parameters\r\
    \n######################################\r\
    \n\r\
    \n:local config {\r\
    \n\"Command\"=\"telegram\";\r\
    \n\t\"botAPI\"=\"xxxxxxxxxxxxxx:xxxxxxxxxx\";\r\
    \n\t\"defaultChatID\"=\"xxxxxxxxxx\";\r\
    \n\t\"trusted\"=\"xxxxxxx, xxxxxxxx, xxxxxxxx\";\r\
    \n\t\"storage\"=\"\";\r\
    \n\t\"timeout\"=5;\r\
    \n\t\"refresh_active\"=15;\r\
    \n\t\"refresh_standby\"=300;\r\
    \n\t\"available_for_public\"=true;\r\
    \n}\r\
    \nreturn \$config\r\
    \n"
add name=tg_getUpdates policy=\
    reboot,read,write,policy,test,sniff,sensitive,romon source=":global TGLAST\
    MSGID\r\
    \n:global TGLASTUPDID\r\
    \n\r\
    \n:local fconfig [:parse [/system script get tg_config source]]\r\
    \n:local http [:parse [/system script get func_fetch source]]\r\
    \n:local gkey [:parse [/system script get tg_getkey source]]\r\
    \n:local send [:parse [/system script get tg_sendMessage source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local trusted [:toarray (\$cfg->\"trusted\")]\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n:local timeout (\$cfg->\"timeout\")\r\
    \n:local availableForPublic [:tobool (\$cfg->\"available_for_public\")]\r\
    \n\r\
    \n:put \"cfg=\$cfg\"\r\
    \n:put \"trusted=\$trusted\"\r\
    \n:put \"botID=\$botID\"\r\
    \n:put \"storage=\$storage\"\r\
    \n:put \"timeout=\$timeout\"\r\
    \n\r\
    \n:local file (\$storage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$storage.\"tg_fetch_log.txt\")\r\
    \n#get 1 message per time\r\
    \n:local url (\"https://api.telegram.org/bot\".\$botID.\"/getUpdates\?time\
    out=\$timeout&limit=1\")\r\
    \n:if ([:len \$TGLASTUPDID]>0) do={\r\
    \n  :set url \"\$url&offset=\$(\$TGLASTUPDID+1)\"\r\
    \n}\r\
    \n\r\
    \n:put \"Reading updates...\"\r\
    \n:local res [\$http dst-path=\$file url=\$url resfile=\$logfile]\r\
    \n:if (\$res!=\"success\") do={\r\
    \n  :put \"Error getting updates\"\r\
    \n  return \"Failed get updates\"\r\
    \n}\r\
    \n:put \"Finished to read updates.\"\r\
    \n\r\
    \n:local content [/file get [/file find name=\$file] contents]\r\
    \n\r\
    \n:local msgid [\$gkey key=\"message_id\" text=\$content]\r\
    \n:if (\$msgid=\"\") do={ \r\
    \n :put \"No new updates\"\r\
    \n :return 0 \r\
    \n}\r\
    \n:set TGLASTMSGID \$msgid\r\
    \n\r\
    \n:local updid [\$gkey key=\"update_id\" text=\$content]\r\
    \n:set TGLASTUPDID \$updid\r\
    \n\r\
    \n:local fromid [\$gkey block=\"from\" key=\"id\" text=\$content]\r\
    \n:local username [\$gkey block=\"from\" key=\"username\" text=\$content]\
    \r\
    \n:local firstname [\$gkey block=\"from\" key=\"first_name\" text=\$conten\
    t]\r\
    \n:local lastname [\$gkey block=\"from\" key=\"last_name\" text=\$content]\
    \r\
    \n:local chatid [\$gkey block=\"chat\" key=\"id\" text=\$content]\r\
    \n:local chattext [\$gkey block=\"chat\" key=\"text\" text=\$content]\r\
    \n\r\
    \n:put \"message id=\$msgid\"\r\
    \n:put \"update id=\$updid\"\r\
    \n:put \"from id=\$fromid\"\r\
    \n:put \"first name=\$firstname\"\r\
    \n:put \"last name=\$lastname\"\r\
    \n:put \"username=\$username\"\r\
    \n:local name \"\$firstname \$lastname\"\r\
    \n:if ([:len \$name]<2) do {\r\
    \n :set name \$username\r\
    \n}\r\
    \n\r\
    \n:put \"in chat=\$chatid\"\r\
    \n:put \"command=\$chattext\"\r\
    \n\r\
    \n:if (!\$availableForPublic) do={\r\
    \n  :local allowed ( [:type [:find \$trusted \$fromid]]!=\"nil\" or [:type\
    \_[:find \$trusted \$chatid]]!=\"nil\")\r\
    \n  :if (!\$allowed) do={\r\
    \n  :put \"Unknown sender, keep silence\"\r\
    \n  :return -1\r\
    \n  }  \r\
    \n}\r\
    \n\r\
    \n\r\
    \n:local cmd \"\"\r\
    \n:local params \"\"\r\
    \n:local ltext [:len \$chattext]\r\
    \n\r\
    \n:local pos [:find \$chattext \" \"]\r\
    \n:if ([:type \$pos]=\"nil\") do={\r\
    \n :set cmd [:pick \$chattext 1 \$ltext]\r\
    \n} else={\r\
    \n :set cmd [:pick \$chattext 1 \$pos]\r\
    \n :set params [:pick \$chattext (\$pos+1) \$ltext]\r\
    \n}\r\
    \n\r\
    \n:local pos [:find \$cmd \"@\"]\r\
    \n:if ([:type \$pos]!=\"nil\") do={\r\
    \n :set cmd [:pick \$cmd 0 \$pos]\r\
    \n}\r\
    \n\r\
    \n:put \"cmd=<\$cmd>\"\r\
    \n:put \"params=<\$params>\"\r\
    \n\r\
    \n:local alternativeCommand {\"hi\"=\"help\"; \"start\"=\"help\"; \"hello\
    \"=\"help\"; \"support\"=\"help\"; \"assistance\"=\"help\"}\r\
    \n:if ([:typeof (\$alternativeCommand -> \$cmd)] = \"str\") do={:set cmd (\
    \$alternativeCommand -> \$cmd); :put \"cmd=<\$cmd>\"}\r\
    \n\r\
    \n:global TGLASTCMD \$cmd\r\
    \n\r\
    \n:put \"Try to invoke external script tg_cmd_\$cmd\"\r\
    \n:local script [:parse [/system script get \"tg_cmd_\$cmd\" source]]\r\
    \n\$script params=\$params chatid=\$chatid from=\$name"
add name=tg_sendMessage policy=read \
    source=":local fconfig [:parse [/system script get tg_config source]]\r\
    \n\r\
    \n:local cfg [\$fconfig]\r\
    \n:local chatID (\$cfg->\"defaultChatID\")\r\
    \n:local botID (\$cfg->\"botAPI\")\r\
    \n:local storage (\$cfg->\"storage\")\r\
    \n\r\
    \n:if ([:len \$chat]>0) do={:set chatID \$chat}\r\
    \n\r\
    \n:local url \"https://api.telegram.org/bot\$botID/sendmessage\?chat_id=\$\
    chatID&text=\$text\"\r\
    \n:if ([:len \$mode]>0) do={:set url (\$url.\"&parse_mode=\$mode\")}\r\
    \n\r\
    \n:local file (\$tgStorage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$tgStorage.\"tg_fetch_log.txt\")\r\
    \n\r\
    \n/tool fetch url=\$url keep-result=no"
add name=tg_getkey policy=read \
    source=":local cur 0\r\
    \n:local lkey [:len \$key]\r\
    \n:local res \"\"\r\
    \n:local p\r\
    \n\r\
    \n:if ([:len \$block]>0) do={\r\
    \n :set p [:find \$text \$block \$cur]\r\
    \n :if ([:type \$p]=\"nil\") do={\r\
    \n  :return \$res\r\
    \n }\r\
    \n :set cur (\$p+[:len \$block]+2)\r\
    \n}\r\
    \n\r\
    \n:set p [:find \$text \$key \$cur]\r\
    \n:if ([:type \$p]!=\"nil\") do={\r\
    \n :set cur (\$p+lkey+2)\r\
    \n :set p [:find \$text \",\" \$cur]\r\
    \n :if ([:type \$p]!=\"nil\") do={\r\
    \n   if ([:pick \$text \$cur]=\"\\\"\") do={\r\
    \n    :set res [:pick \$text (\$cur+1) (\$p-1)]\r\
    \n   } else={\r\
    \n    :set res [:pick \$text \$cur \$p]\r\
    \n   }\r\
    \n } \r\
    \n}\r\
    \n:return \$res"
add name=tg_sendAudio policy=read \
    source=":local configuration [:parse [/system script get tg_config source]\
    ]\r\
    \n:local conf [\$configuration]\r\
    \n:local chatID (\$conf->\"defaultChatID\")\r\
    \n:local botID (\$conf->\"botAPI\")\r\
    \n:local storage (\$conf->\"storage\")\r\
    \n\r\
    \n:if ([:len \$chat]>0) do={:set chatID \$chat}\r\
    \n:local url \"https://api.telegram.org/bot\$botID/sendAudio\?chat_id=\$ch\
    atID&audio=\$audio\"\r\
    \n\r\
    \n:local file (\$tgStorage.\"tg_get_updates.txt\")\r\
    \n:local logfile (\$tgStorage.\"tg_fetch_log.txt\")\r\
    \n:put \$url\r\
    \n\r\
    \n/tool fetch url=\$url keep-result=no\r\
    \n"
/system scheduler
add interval=10s name=Telegram-bot on-event="/system script run tg_getUpdates" \
    policy=reboot,read,write,policy,test,sniff,sensitive,romon \
    start-time=startup