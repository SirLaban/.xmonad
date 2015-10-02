#! /bin/sh                                    

LIFE=$( sysctl -n hw.acpi.battery.life )
case $( sysctl -n hw.acpi.acline ) in
  (1)
    echo "AC/${LIFE}%"
    ;;
  (0)
    TIME=$( sysctl -n hw.acpi.battery.time )
    HOUR=$(( ${TIME} / 60 ))
    MINS=$(( ${TIME} % 60 ))
    [ ${MINS} -lt 10 ] && MINS="0${MINS}"
    echo "${HOUR}:${MINS}/${LIFE}%"
    ;;
esac

