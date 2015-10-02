#! /bin/sh

#

while sleep 2
do
  echo -n ' '
  ~/.xmonad/scripts/xmobar.sh | tr -d '\n'
  echo
done | xmobar ~/.xmonad/rcfiles/.xmobarrc &

