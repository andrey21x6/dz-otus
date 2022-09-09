#!/bin/bash

#====================================================================================

#max=`awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print a}' 1.txt`
#max=`awk '{if(max<$1){max=$1;line=$1}}END{print line}' 1.txt`
#max=`awk '$1 > max { max = $1; output = $1 } END { print output }' 1.txt`
#max=`awk  '{if (max == "") max=$1 ; else if ($1 > max) max=$1}END{print max}' 1.txt`
#max=`sort -k1 -n 1.txt | tail -1 | awk '{print $1}'`
#max=`sort -r 1.txt | head -n1 | awk '{print $1}'`
#max=`sort -nrk1,1 1.txt | head -1 |awk '{print $1}'`

# 0 * * * * /usr/bin/flock -xn /var/lock/import.lock -c 'sh /root/import.sh'

#====================================================================================

declare -i ipMax=0
declare -i domainsMax=0
declare dateTimeOld=""
declare dateTimeIn=""
declare ipListMax=""
declare domainsListMax=""
declare errorList=""
declare httpList=""



cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > ip_list.txt
cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -P "[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > domains_list.txt
cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep "error" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > error_list.txt
cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -E " HTTP/1.(0|1)\" [0-9]{3,3} " | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > http_list.txt
dateTimeOld=`cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep  '______' | cut -f 2 -d '*'`

sed -i -e "s/___Start_Script_Send_Mail___/___OFF_Script_Send_Mail___/g" log.log
echo ___Start_Script_Send_Mail___ >> log.log

dateTimeIn=$(date)
echo ______*${dateTimeIn}*______ >> log.log

ipMax=`awk '{if(max<$1){max=$1;line=$1}}END{print line}' ip_list.txt`
cat ip_list.txt | grep "^${ipMax} " > ip_max.txt

domainsMax=`awk '{if(max<$1){max=$1;line=$1}}END{print line}' domains_list.txt`
cat domains_list.txt | grep "^${domainsMax} " > domains_max.txt

ipListMax=`cat ip_max.txt`
domainsListMax=`cat domains_max.txt`
errorList=`cat error_list.txt`
httpList=`cat http_list.txt`

echo "\n${ipListMax}\n${domainsListMax}\n${errorList}\n${httpList}" | mail -s "Отчёт по лог файлу" andrey@mail.ru





echo
echo ============================================
echo
echo $dateTimeOld
echo
echo $dateTimeIn
echo
echo $ipListMax
echo
echo $domainsListMax
echo
echo $errorList
echo
echo $httpList
echo
