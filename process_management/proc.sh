#!/usr/bin/env bash

procUptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)

clkTck=$(getconf CLK_TCK)

echo "PID  TTY  STAT TIME   COMMAND"

for pid in $(find /proc -maxdepth 1 | grep -o -E "[0-9]*[0-9]$" | sort -n);
do
	tty=$(cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $7}')
	stat=$(cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $3}')
	utime=$(cat 2>/dev/null < /proc/"$pid"/stat | awk '{print $14}')
	stime=$(cat  2>/dev/null < /proc/"$pid"/stat | awk '{print $17}')
	cmd=$(cat 2>/dev/null < /proc/"$pid"/cmdline | awk '{print $0}')
	ttime=$((utime + stime))
	time=$((ttime / clkTck))
	printf "%-8s \n" "$pid    $tty    $stat    $time    $cmd" | column -t  -s '|'
done

echo "uptime:  $procUptime"
