#!/bin/sh

rep=''
type=''
name=''
size=''
exe=''


# FONCTION testArg()
#
# Teste si la valeur existe
#
# Paramètre : valeur d'un argument
#
testArg() {
  if [ -z $1 ]; then
    echo "[Error] Argument doesn't have a value" 1>&2
    echo "[Usage] -arg [value]" 1>&2
    exit 3
  elif [ $(echo $1 | grep -E "^-[[:alpha:]]" | wc -l ) -eq 1 ]; then
    echo "[Error] Invalid argument value" 1>&2
    echo "[Usage] -arg [value]" 1>&2
    exit 3
  fi
  return 0
}


# FONCTION f[arg]()
#
# Exécute la fonctionnalité de [arg]
#
# Paramètre : chemin vers un fichier
#
fname() {
  arg=${1##*/}
  if [ "$(echo $arg | grep -E ^"$name"$)" ]; then
    return 0
  else
    argValide=false
    return 0
  fi
}

ftype() {
  if [ "$type" = "f" ]; then
    if [ -f $1 ]; then
      return 0
    else
      argValide=false
      return 0
    fi
  else
    if [ -d $1 ]; then
      return 0
    else
      argValide=false
      return 0
    fi
  fi
  return 0
}

fsize() {
      filesize=$(stat --printf='%s' $1)           #On utilise stat(1) qui permet de donner des statistiques sur le fichier (dont la taille)
      arg=$(echo $size | sed -E 's/[+,-]//')
      if [ $(echo $arg | grep -E '^[[:digit:]]+$' | wc -l) -ne 1 ];then
        echo "[Error] -size value has to be an integer" 1>&2
        echo "[Usage] -size (+/-)[int]" 1>&2
        exit 3
      fi
      pos=$(echo $size | grep -E '^[+]' | wc -l)
      neg=$(echo $size | grep -E '^[-]' | wc -l)
      if [ $pos -eq 1 ] ;then
          if [ $filesize -ge $arg ]; then
              return 0
          else
              argValide=false
              return 0
          fi
      elif [ $neg -eq 1 ] ; then
          if [ $filesize -le $arg ]; then
              return 0
          else
              argValide=false
              return 0
          fi
      else
          if [ $filesize -eq $arg ]; then
              return 0
          else
              argValide=false
              return 0
          fi
      fi
}

fexe() {
  cmd=$(echo $exe | sed -e "s|{}|${1}|g")
  exec=$(eval $cmd)
  if [ $? -ne 0 ];then
    echo "[Error] An error occured in the execution of the -exe argument" 1>&2
    echo "[Usage] ./find.sh -exe 'command {}' (the braces are replaced by files)" 1>&2
  fi
}

# FONCTION baladade()
#
# Permet de se balader récursivement dans tous les répertoires de rep
# et d'éxécuter les fonctions f et d'afficher les fichiers correspondant aux arguments transmis
# Paramètre : répertoire
#
baladade() {
  local I
  for I in $1/*; do
    argValide=true
    if [ "$name" != "" ] && [ $argValide = true ]; then
      fname $I
    fi
    if [ ! "$type" = "" ] && [ $argValide = true ]; then
      ftype $I
    fi
    if [ "$size" != "" ] && [ $argValide = true ]; then
      fsize $I
    fi
    if [ "$exe" != "" ] && [ $argValide = true ]; then
      fexe $I
    elif [ $argValide = true ]; then
      echo $I
    fi
    if [ -d $I ] ;then
        (baladade $I)
    fi
  done
  return 0
}

if [ "$1" = "--help" ];then
    echo "Usage : ./find.sh [DIR] [OPTION]...
    Search for files in a directory hierarchy DIR.
    If DIR is not specified, the search is performed in the current directory.
    OPTIONS
        --help             show help and exit
        -name PATTERN      Finding files whose name match the shell pattern PATTERN
                           The pattern must be a nonempty string with no white-space
                           characters
        -type {d|f}        Finding files that are directories (type d)
                           or regular files (type f)
        -size [+|-]SIZE    Finding files whose size is greater than or equal(+), or less
                           than or equal (-), or equal to SIZE
        -exe COMMAND       Run the command COMMAND for each file found instead of
                           displaying its pathIn the string COMMAND, each pair of braces {} will be replaced
                           by the path to the found file
                           The string COMMAND must contain at least one pair of braces {}"
    if [ $# -ne 1 ];then
      echo "[Error] --help must be alone" 1>&2
      echo "[Usage] ./find.sh --help" 1>&2
      exit 2
    fi
    exit 0
  else
    if [ "$#" -eq '0' ] || [ "$(echo $1 | grep -E "^-")" ]; then
      rep='./'
    else
      if [ ! -d $1 ]; then
        echo "[Error] $1 doesn’t exist or isn’t a directory" 1>&2
        echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
        exit 1
      else
        rep=$1
        shift
      fi
    fi
    while [ "$#" -gt '0' ]; do

      if [ -d $1 ]; then
        echo "[Error] Invalid argument" 1>&2
        echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
        exit 1
      fi

      case $1 in
        '-name')                                                         #Traitement des arguments et affectation des variables
          if [ "$name" != "" ]; then                                     #On utilise shift pour permettre le traitement des arguments quelles que soient leurs positions
          echo '[Error] -name argument is already assigned' 1>&2
          echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
          else
            shift
            testArg $1;
            name=$1
          fi
          ;;
        '-type')
          if [ ! "$type" = "" ]; then
            echo '[Error] -type argument is already assigned' 1>&2
            echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
            exit 3
          else
            shift
            testArg $1;
            if [ ! "$1" = "d" ] && [ ! "$1" = "f" ]; then
              echo[ '[Error] Invalid argument value' 1>&2
              echo '[Usage] -type {d|f}' 1>&2
              exit 3
            fi
            type=$1
          fi
          ;;
        '-size')
          if [ "$size" != "" ]; then
            echo '[Error] -size argument is already assigned' 1>&2
            echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
            exit 3
          else
            shift
            testArg $1;
            size=$1

          fi
          ;;
        '-exe')
          if [ "$exe" != "" ]; then
            echo '[Error] -exe argument is already assigned' 1>&2
            echo '[Usage] ./find.sh [DIR] [OPTIONS]' 1>&2
            exit 3
          else
            shift
            if [ $(echo $1 | grep '{}' | wc -l) -ne 1 ]; then
              echo '[Error] Invalid braces or no braces' 1>&2
              echo "[Usage] -exe 'cmd {}' (braces are replaced by files)" 1>&2
              exit 3
            fi
            testArg $1;
            exe=$1
          fi
          ;;

        '--help')
          echo '[Error] Inavlid argument' 1>&2
          echo '[Usage] ./find.sh --help' 1>&2
          exit 3
          ;;

      esac
      if [ "$#" -gt '0' ]; then
        shift
      fi
    done
fi

baladade $rep

exit 0
