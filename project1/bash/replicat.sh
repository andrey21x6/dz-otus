#!/bin/bash

STR=`mysql -h 127.0.0.1 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $STR | sed 's:^:V1=":; /Position: / s::";V2=": ;s:$:":')
STR=`mysql -h 127.0.0.1 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $STR | sed 's:^:V3=":; /File: / s::";V4=": ;s:$:":')
mysql -h 192.168.90.14 -u root -p123456 -e 'change master to master_host = "192.168.90.15", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V4'", master_log_pos = '$V2''
mysql -h 192.168.90.14 -u root -p123456 -e 'start slave'
STR=`mysql -h 192.168.90.14 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'Position';` ; eval $(echo $STR | sed 's:^:V1=":; /Position: / s::";V2=": ;s:$:":')
STR=`mysql -h 192.168.90.14 -u root -p123456 -e 'SHOW MASTER STATUS \G' | grep 'File';` ; eval $(echo $STR | sed 's:^:V3=":; /File: / s::";V4=": ;s:$:":')
mysql -h 127.0.0.1 -u root -p123456 -e 'change master to master_host = "192.168.90.14", master_user = "replicatuser", master_password = "passuser", master_log_file = "'$V4'", master_log_pos = '$V2''
mysql -h 127.0.0.1 -u root -p123456 -e 'start slave'



#mysql -h 127.0.0.1 -u root -p123456 -e 'stop slave'
