#!/bin/bash
res=0


factoriel(){
  if [ $# -ne 1 ]; then
    echo "Error : The number of arguments isn’t correct"
    echo "Usage : ./factoriel.sh [dir]"
    exit
  fi
  if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    if [ $1 -eq 0 ]; then
      return
    elif [ $res -eq 0 ]; then
      res=$1
      next=$(($1-1))
      factoriel $next
    else
      res=$(($1*res))
      next=$(($1-1))
      factoriel $next
    fi
  else
    echo 'Is not a number'
    res='-1'
  fi
}

factoriel $*
if [ $res -ne -1 ]; then
  echo "!$1 = $res"
fi

exit 0
