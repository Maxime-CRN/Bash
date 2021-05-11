#!/bin/bash
randval=$(hexdump -n 2 -e '/2 "%u"' /dev/urandom)
MAX=100
randval=$(($randval%$MAX))
echo $randval

echo "The computer has chosen a value between 1 and 100."

for I in $(seq 0 5); do
  echo "What do you propose ?"
  read RES
  if [ $RES -lt $randval ]; then
    echo "The value is greater."
  elif [ $RES -gt $randval ]; then
    echo "The value is lower."
  else
    echo "Win ! you have found in $I attempts"
    exit 0
  fi
done

echo "lost ! The secret number was: $randval"
exit 0
