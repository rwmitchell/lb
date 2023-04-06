# -*- sh -*-

# 2022-03-16 change from autoload to plugin
# printf "Initializing lb\n"

compdef lb=which

if [[ $TERM_PROGRAM == *iTerm* ]]; then

  # Argument to line functions specifies line thickness
  function __lb_yline() {
    [ $1 ] && ht=$1 || ht=1;
    printf "\e]1337;File=name=eWVsbG93;size=113;inline=1;width=100%%;height=%dpx;preserveAspectRatio=no:iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEX//wCKxvRFAAAACklEQVQI12NgAAAAAgAB4iG8MwAAAABJRU5ErkJggg==\a\n" "$ht"
  }

  function __lb_rline() {
    [ $1 ] && ht=$1 || ht=1;
    printf "\e]1337;File=name=cmVk;size=113;inline=1;width=100%%;height=%dpx;preserveAspectRatio=no:iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEX/AAAZ4gk3AAAACklEQVQI12NgAAAAAgAB4iG8MwAAAABJRU5ErkJggg==\a\n" "$ht"
    }

  function __lb_cline {
    [ $1 ] && ht=$1 || ht=1;
    printf "\e]1337;File=name=Y3lhbg==;size=113;inline=1;width=100%%;height=%dpx;preserveAspectRatio=no:iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUA//8ZXC8lAAAACklEQVQI12NgAAAAAgAB4iG8MwAAAABJRU5ErkJggg==\a\n" "$ht"
  }

else
  # Argument is ignored as a repeating number is ugly
  function __lb_yline () { local S='-'; printf -v _hr "[1;33m%*s[m" $(tput cols) && echo ${_hr// /${S--}} }
  function __lb_rline () { local S='-'; printf -v _hr "[1;31m%*s[m" $(tput cols) && echo ${_hr// /${S--}} }
  function __lb_cline () { local S='-'; printf -v _hr "[1;36m%*s[m" $(tput cols) && echo ${_hr// /${S--}} }
fi

function _lb_ident () {
  local cmd pad

  for cmd in $@; do
    printf "%b%s\n" $pad "$cmd"
    strings $cmd | command egrep '^ *\$.*\$$|^@\(#\)' | sed 's/^/  /'
    pad="\n"
  done
}

function lb__l {
  type els > /dev/null
  [[ $? == 1 ]] && /bin/ls -l $* || els +T^NY-M-DT +G~Atp~ugsmnL $*  # l
}
function lb_ls {
  type els > /dev/null
  [[ $? == 1 ]] && /bin/ls $*    || els +T^NY-M-DT +G~At~smn $*      # ll
}

function lb_hl {                   # hl -I -g $cmd
  while IFS= read -r; do
    GREP_COLOR="07;32" egrep --color=always "$1|\$" <<< "$REPLY"
  done
}

function lb_ccol {                 # ccol -y 4 -g -s 6 20
  local ccols=( 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 )
  local cmd

  on="[01;33m"                   # yellow bold
  off="[m"
  cmd="sed 's/[^[:blank:]]\{1,\}/${on}&${off}/4; "    # set first cmd

  on="[01;32m"                   # green bold

  for col in $ccols; do
    cmd="$cmd s/[^[:blank:]]\{1,\}/${on}&${off}/$col;"
  done
  cmd="$cmd '"

  while read -r line; do
    echo "$line" | ( eval $cmd )
  done
}

function lb_prism {                # prism -F:;
  local cmd

  on="[38;2;255;000;090m"        # red normal
  off="[m"

  cmd="sed 's/[^:]\{1,\}/${on}&${off}/1;"             # set first cmd

  on="[01;31m"                   # red bold

  cmd="$cmd s/[^:]\{1,\}/${on}&${off}/2 '"

  while read -r line; do
    echo "$line" | ( eval $cmd )
  done

}

function lb_exe {
  local l_cmd cmd txt flg
  if (( lb_long )); then
    l_cmd=lb__l
  else
    l_cmd=lb_ls
  fi


  cmd=$( type $1 )
  flg=$2

  a_cmd=$(type $1 | egrep -v "alias |shell " | sed 's/^.* \([^ ][^ ]\)/\1/g')
  [[ $a_cmd == "" ]] && a_cmd=$cmd && printf "\n"

  if [[ $flg == 1 ]]; then           # executable
    if (( lb_verb )) || (( lb_file )); then
      txt=$( file $a_cmd )
      printf "%s\n" $txt | lb_prism
    fi
  fi

  $l_cmd $(\type -a $1 | egrep -v "alias|shell" | sed 's/^.* \([^ ][^ ]\)/\1/g') | lb_hl $a_cmd

  if (( lb_verb )); then
    echo $txt | grep -q text;
    if ! (( $? )); then
      __lb_cline 5
      $cat $a_cmd
      __lb_cline 5
    fi
  fi

  if (( lb_ident )); then
    __lb_yline 2
    _lb_ident $(\type -a $1 | egrep -v "alias|shell" | sed 's/^.* \([^ ][^ ]\)/\1/g') | lb_hl $a_cmd
    __lb_yline 2
  fi
}

function lb_help {
  printf "%s -%s CMD [CMD]\n\n" $0 $myopts
  printf "Find location of executable, function, or alias\n"
  printf "  -C: colorize source\n"
  printf "  -f: show 'file' output for executables\n"
  printf "  -i: show 'ident' information\n"
  printf "  -l: long ls output\n"
  printf "  -r: reload function\n"
  printf "  -e: edit function\n"
  printf "  -v: show script and function source\n"
  printf "\n"
}

function lb {
  local cat=cat;
  local lb_file=0;
  local lb_long=0;
  local lb_verb=0;
  local lb_ident=0;
  local lb_rload=0;           # resource file containing function
  local lb_edit=0;

  local myopts="Cefilrvh"
  while getopts $myopts opt; do
    case $opt in
      C) cat=colorize_less;;  # colorize_cat uses default tab stops
      f) lb_file=1;;
      i) lb_ident=1;;
      l) lb_long=1;;
      r) lb_rload=1;;
      e) lb_edit=1;;
      v) lb_verb=1;;
      ?) lb_help;
         ;;
    esac
  done
  shift $((OPTIND -1))

  while test "$#" -gt 0; do
    cmd="$1"; shift;
    x=$( whence -v $cmd )
    a=("${(@s/ /)x}")
    c=$( type -a $cmd | wc -l )

    if [[ $a[2] == "not" ]]; then
      printf "%s\n" $x
    elif [[ $#a -eq 3 ]]; then           # executable
      lb_exe $cmd 1
    else                                 # alias or shell function
      printf "%s\n" $x | lb_ccol

      if [[ $a[4] == "shell" ]]; then
        if (( lb_verb )); then
          printf "\n"
          __lb_yline 5
          which $cmd | $cat # --         # -- borked: lb -C -v gp
          printf "\n"
          __lb_rline 5
        fi

        if (( lb_rload )); then
          printf "Reload from: %s" $a[7]
          [[ -e $a[7] ]] && source $a[7]
          [[ $? ]] && printf " - \e[01;32mSuccess\e[m\n" || printf " - \e[01;31mFAIL]e[m\n"
        fi

        if (( lb_edit )); then
          type zed 2>&1 > /dev/null || autoload zed
          zed -f $cmd
        fi

      fi
      if [[ $c -gt 1 ]] lb_exe $cmd 0
    fi

    if [[ $# -gt 0 ]]; then
      printf "\n"
    fi
  done
}


# This is only for an autoload function
# lb $*
