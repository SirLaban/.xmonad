#! /bin/sh

case $( ifconfig | grep -c "inet " ) in
  (1)
    echo -n "none "
    exit 0
    ;;
  (*)
    for I in $( ifconfig -l | sed s/lo0//g )
    do
      ifconfig ${I} | awk -v INTERFACE=${I} 'match($0, /inet /) { printf("%s/%s ",INTERFACE,$2) }'
    done
    ;;
esac

