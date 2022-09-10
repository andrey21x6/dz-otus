#!/bin/bash

declare logTest=""
declare -i ipMax=0
declare -i domainsMax=0
declare dateTimeOld=""
declare dateTimeIn=""
declare ipListMax=""
declare domainsListMax=""
declare errorList=""
declare httpList=""

logTest=`cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }'`

if [ -z "${logTest}" ]; then
	cat log.log | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > ip_list.txt
	cat log.log | grep -o -P "[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > domains_list.txt
	cat log.log | grep "error" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > error_list.txt
	cat log.log | grep -o -E " HTTP/1.(0|1)\" [0-9]{3,3} " | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > http_list.txt
	dateTimeOld="Первый запуск"
else
	cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > ip_list.txt
	cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -P "[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > domains_list.txt
	cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep "error" | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > error_list.txt
	cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep -o -E " HTTP/1.(0|1)\" [0-9]{3,3} " | sort -n | uniq -c | awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }' | sort -n > http_list.txt
	dateTimeOld=`cat log.log | awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep  '______' | cut -f 2 -d '*'`
	sed -i -e "s/___Start_Script_Send_Mail___/___OFF_Script_Send_Mail___/g" log.log
fi

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

echo "Диапазон времени:\n${dateTimeOld} - ${dateTimeIn}\n${ipListMax}\n${domainsListMax}\n${errorList}\n${httpList}" | mail -s "Отчёт по лог файлу" andrey@mail.ru

# Или можно прикрепить данные файлы, предварительно поместить их в архив и воспользоваться для этого утилитой Mutt

#zip log.zip ip_max.txt domains_max.txt error_list.txt http_list.txt
#echo "Логи в архиве" | mutt -s "Отчёт по лог файлу" -a /home/andrey/log.zip -- andrey21x6@mail.ru

