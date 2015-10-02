#! /bin/sh

date +"<fc=#AAAAAA>date:</fc> <fc=#EEEEEE>%Y/%m/%d/%A/%H:%M</fc>" | tr '[A-Z]' '[a-z]'

echo -n " <fc=#dd0000>|</fc> <fc=#aaaaaa>cpu:</fc> <fc=#eeeeee>"
top -b -o res | awk 'NR>8 { gsub(/%/,"",$0); CPU+=$11; } END { split(CPU,cpu,"."); print cpu[1]; }'
echo -n "%/"
sysctl -n dev.cpu.0.freq
echo -n "MHz/"
sysctl -n hw.acpi.thermal.tz0.temperature | awk -F '.' '{print $1}'

echo -n "</fc> <fc=#dd0000>|</fc> <fc=#aaaaaa>load:</fc> <fc=#eeeeee>"
sysctl -n vm.loadavg | awk '{ print substr($2,0,3) "/" substr($3,0,3) "/" substr($4,0,3) }'

BOOT=$( sysctl -n kern.boottime | awk 'match($0, / sec = [0-9]+/) { $0 = substr($0, RSTART, RLENGTH); print $3 }' )
DATE=$( date +%s )
echo -n " <fc=#dd0000>|</fc> <fc=#aaaaaa>uptime:</fc> <fc=#eeeeee>$( date -r $(( ${DATE} - ${BOOT} - 3600 )) +"%k:%M" | tr -d ' ' )</fc>"

echo -n "</fc> <fc=#dd0000>|</fc> <fc=#aaaaaa>ps:</fc> <fc=#eeeeee>"
sysctl -n vm.vmtotal | awk 'match($0, /Processes/) { gsub(/\)/,"",$11); print $3 "/" $6 "/" $9 "/" $11 }'

echo -n "</fc> <fc=#dd0000>|</fc> <fc=#aaaaaa>mem:</fc> <fc=#eeeeee>"
MEM_PAGE=$( sysctl -n hw.pagesize )
MEM_SIZE=$(( $( sysctl -n vm.stats.vm.v_page_count )     * ${MEM_PAGE} / 1024 / 1024 ))
MEM_INCT=$(( $( sysctl -n vm.stats.vm.v_inactive_count ) * ${MEM_PAGE} / 1024 / 1024 ))
MEM_FREE=$(( $( sysctl -n vm.stats.vm.v_free_count )     * ${MEM_PAGE} / 1024 / 1024 ))
MEM_USED=$(( ${MEM_SIZE} - ${MEM_FREE} - ${MEM_INCT} ))
echo -n "$(( 100 * ${MEM_USED} / ${MEM_SIZE} ))%/$(( ${MEM_USED} ))M"

echo -n "</fc> <fc=#dd0000>|</fc> <fc=#aaaaaa>ip:</fc> <fc=#eeeeee>$( ~/scripts/if_ip.sh )</fc>"

echo -n "<fc=#dd0000>|</fc> <fc=#aaaaaa>vol/pcm:</fc> <fc=#eeeeee>$( mixer -s vol | awk -F ':' '{printf("%s",$2)}' )/$( mixer -s pcm | awk -F ':' '{printf("%s",$2)}' )</fc> "

echo -n "<fc=#dd0000>|</fc> <fc=#aaaaaa>fs:</fc> <fc=#eeeeee>"
df -h /dev/ada0s3a | awk 'END{print $3 "/" $4}'

echo -n "</fc> <fc=#dd0000>|</fc> <fc=#aaaaaa>bat:</fc> <fc=#eeeeee>$( ~/scripts/battery.sh )</fc>"

