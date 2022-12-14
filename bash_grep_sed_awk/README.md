# Bash, grep, sed, awk и другие

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)
- flock from util-linux 2.34
- mail (GNU Mailutils) 3.7
- postfix 3.14.13
- (или Mutt 1.13.2 (2019-12-18))

# **Содержание ДЗ**

Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
Необходимая информация в письме:

* Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
* Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
* Ошибки веб-сервера/приложения c момента последнего запуска
* Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
* Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения
* В письме должен быть прописан обрабатываемый временной диапазон

# **Выполнение**

Написал скрипт для планировщика cron на BASH send_email.sh

В планировщике прописал запуск скрипта каждый час с блокировкой повторного запуска с помощью утилиты flock и файла send_email.lock
```
crontab -e

  0 * * * * /usr/bin/flock -xn /var/lock/send_email.lock -c 'sh /root/send_email.sh'
```

### Описание работы скрипта

Ищет строку, где есть запись ___Start_Script_Send_Mail___ и выбирает всё, что идёт после нее
```
awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }'
```

Проверяет на пустоту (при первом запуске сканирует весь файл)
```
logTest=$(< log.log awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }')
if [ -z "${logTest}" ]; then
  .........
  .........
```

Регулярное выражение для IP адреса, ключ -о вытаскивает только IP адреса
```
grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
```

Числовая сортировка
```
sort -n
```

Ищет одинаковые строки и в начале каждой строки выводит число, которое обозначает количество повторов
```
uniq -c
```

Убирает пустоты первого столбца
```
awk '{gsub(/^[ \t]+| [ \t]+$/,""); print $0 }'
```

Регулярное выражение для домена, ключ -о вытаскивает только домены
```
grep -o -P "[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+"
```

Команда вытаскивает строки по ключевому слову
```
grep "error"
```

Регулярное выражение по шаблону, вытаскивает коды HTTP ответов
```
grep -o -E " HTTP/1.(0|1)\" [0-9]{3,3} "
```

Вытаскивает запись даты и времени предыдущего запуска скрипта
```
dateTimeOld=$(< log.log awk 'go { print } $0 == "___Start_Script_Send_Mail___" { go = 1 }' | grep  '______' | cut -f 2 -d '*')
  Чт 08 сен 2022 19:36:43 +05
```

Меняет в строке запись ___Start_Script_Send_Mail___ на ___OFF_Script_Send_Mail___ в лог-файле
```
sed -i -e "s/___Start_Script_Send_Mail___/___OFF_Script_Send_Mail___/g" log.log
```

Вставляет в конец лог-файла строку ___Start_Script_Send_Mail___
```
echo "___Start_Script_Send_Mail___" >> log.log
```

Вставляет в конец лог-файла дату и время окончания работы скрипта
```
dateTimeIn=$(date)
echo "______*${dateTimeIn}*______" >> log.log
```

Вычисляет максимальное число в первом столбце файла ip_list.txt и заносит в переменную ipMax
```
ipMax=$(awk '{if(max<$1){max=$1;line=$1}}END{print line}' ip_list.txt)
```

Записывает в файл ip_max.txt строки, которые содержат максимальное число (переменная $ipMax) в первом столбце файла ip_list.txt
```
< ip_list.txt grep "^${ipMax} " > ip_max.txt
```

Вычисляет максимальное число в первом столбце файла domains_list.txt и заносит в переменную domainsMax
```
domainsMax=$(awk '{if(max<$1){max=$1;line=$1}}END{print line}' domains_list.txt)
```

Записывает в файл domains_max.txt строки, которые содержат максимальное число (переменная $domainsMax) в первом столбце файла domains_list.txt
```
< domains_list.txt grep "^${domainsMax} " > domains_max.txt
```

Присваиваем значения переменным для отправки Email
```
ipListMax=$(cat ip_max.txt)
domainsListMax=$(cat domains_max.txt)
errorList=$(cat error_list.txt)
httpList=$(cat http_list.txt)
```

Устанавка утилиты для отправке писем (почтовый сервер postfix при этом тоже устанавливается)
```
apt install mailutils
```

Отправка почты
```
printf 'Диапазон времени:\t%s\n' "${dateTimeOld}" '- ' "${dateTimeIn}" '\t%s\n' "${ipListMax}" '\t%s\n' "${domainsListMax}" '\t%s\n' "${errorList}" '\t%s\n' "${httpList}" | mail -s "Отчёт по лог файлу" andrey@mail.ru
```

Или можно прикрепить данные файлы к письму, предварительно поместить их в архив, воспользоваться можно утилитой Mutt
```
zip log.zip ip_max.txt domains_max.txt error_list.txt http_list.txt
echo "Логи в архиве" | mutt -s "Отчёт по лог файлу" -a /home/andrey/log.zip -- andrey@mail.ru
```

# **Результаты**

- Написал скрипт для планировщика cron на BASH. Проверил на https://www.shellcheck.net - No issues detected!
- В планировщике прописал запуск скрипта каждый час с блокировкой повторного запуска
- Скрипт (файл лога тоже для примера) https://github.com/andrey21x6/dz-otus/blob/main/bash_grep_sed_awk/send_email.sh

