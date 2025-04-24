#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
#LIGHT_RED='\033[1;31m'
#LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
#LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

#export RED
#export GREEN
#export GRAY
#export YELLOW
#export NC

function _str_pad_with_dot {
  local size=${#1}
  echo -en "${1} ${GRAY}"

  for ((i = size; i < 30; i++)); do
    echo -n "."
  done

  echo -en "${NC}"
}

function _echo_colorized {
  if [ "$1" == "-n" ]; then
    echo -en "${3}${2}${NC}"
  else
    echo -e "${3}${1}${NC}"
  fi
}

function io::dotted_line {
  #echo -n "  ${1}"
  #printf "%-20s" ${1}
  _str_pad_with_dot "${1}"
  echo -e " ${2}"
}

function io::line {
  _echo_colorized "$1" "$2" "${NC}"
}

function io::error {
  #  printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
  _echo_colorized "$1" "$2" "${RED}"
}

function io::warning {
  _echo_colorized "$1" "$2" "${YELLOW}"
}

function io::info {
  _echo_colorized "$1" "$2" "${BLUE}"
}

function io::success {
  _echo_colorized "$1" "$2" "${GREEN}"
}

function io::title {
  _echo_colorized "$1" "$2" "${YELLOW}"
}

function io::comment {
  _echo_colorized "$1" "$2" "${GRAY}"
}

function io::code {
  _echo_colorized "$1" "$2" "${GRAY}"
}

#function io::confirm {
#  local message="$1"
#  local default="${2}"
#  local prefix="Y/n"
#  if [ "$default" == "n" ]; then
#    prefix="y/N"
#  fi
#
#  echo -en "${YELLOW}${message}$NC ($prefix): "
#  read i
#
#  if [ -z "$i" ]; then
#    [ "$default" != "n" ] && return 0 || return 1
#  fi
#
#  case $i in
#  Y | y | yes | "")
#    return 0
#    ;;
#  *)
#    return 1
#    ;;
#  esac
#}

function io::log_success {
  local m="${2:-OK}"
  echo -e "$1: ${GREEN}$m$NC"
}

function io::log_skipped {
  local m="${2:-SKIPPED}"
  echo -e "$1: ${GRAY}$m$NC"
}
