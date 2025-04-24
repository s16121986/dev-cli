#!/bin/bash

function detect_postgres_port {
  echo "$(sudo su postgres -c "psql -c 'SHOW port;'" | grep -oE '[0-9]{4}')"
}

function detect_linux_distrib {
  echo "$(grep -ioP '^ID=\K.+' /etc/os-release)"
}

function is_locale_exists {
  [ -n "$(locale -a | grep "$1")" ] && return 0 || return 1
}

function is_wsl {
  [ -f "/etc/wsl.conf" ] && return 0 || return 1
}

function function_exists() {
  declare -F "$1" > /dev/null;
}

function subshell_call {
  local optional=0

  for i in "$@"; do
    case $i in
    --optional | -o)
      optional=1
      shift
      ;;
    esac
  done

  local source="$1"
  local fn="$2"
  shift
  shift

  if [ $optional == 1 ]; then
    # shellcheck disable=SC1090
    (unset "$fn" && source "$source" && ! function_exists "$fn" || eval "$fn $*") || return 1
  else
    # shellcheck disable=SC1090
    (unset "$fn" && source "$source" && eval "$fn $*") || return 1
  fi
}

function abort {
  local m="$1"
  local code="${2:-1}"

  io::error "$m"
  exit $code
}

function dd {
  for i in "$@"; do
    echo "$i"
  done
  exit 1
}
