# Управление процессами

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)

# **Содержание ДЗ**

Написать свою реализацию ps ax используя анализ /proc
Результат ДЗ - рабочий скрипт который можно запустить

# **Выполнение**

Написал скрипт на BASH proc.sh

### Описание работы скрипта

Заносит в переменную информацию о том, как долго система работала с момента последней перезагрузки (приводит к нормальному виду)
```
procUptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
```

Подготовка для поля TIME
```
clkTck=$(getconf CLK_TCK)
```

Вывод шапки таблицы
```
echo "PID  TTY  STAT TIME   COMMAND"
```

Ищет в каталоге proc список файлов, вытаскивает только названия с числами и сортирует по числам
```
find /proc -maxdepth 1 | grep -o -E "[0-9]*[0-9]$" | sort -n
```

Подготовка к выводу столбца TTY по PID
```
cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $7}
```

Подготовка к выводу столбца STAT по PID
```
stat=$(cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $3}')
```

Подготовка к выводу столбца TIME по PID
```
utime=$(cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $14}')
ttime=$((utime + stime))
time=$((ttime / clkTck))
```

Подготовка к выводу столбца COMMAND по PID
```
cmd=$(cat 2>/dev/null < /proc/"$pid"/cmdline | awk '{print $0}')
```

Вывод содержимого столбцов
```
printf "%-8s \n" "$pid    $tty    $stat    $time    $cmd" | column -t  -s '|'
```

Выводит информацию о том, как долго система работала с момента последней перезагрузки
```
echo "uptime:  $procUptime"
```

# **Результаты**

- Написал скрипт на BASH proc.sh. Проверил на https://www.shellcheck.net - No issues detected!

