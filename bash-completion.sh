#!/bin/bash

function _dev_cli {
  local cmd="${COMP_WORDS[$COMP_CWORD - 1]}"
  local words=""
  case "${cmd}" in
  dev-cli)
    words="list clone remove up down --install --remove --update --config"
    ;;
  clone | up | down | remove)
    words=$(find /usr/local/lib/dev-cli/projects -mindepth 1 -maxdepth 1 -type d -printf '%f ')
    ;;
  --install | --remove)
    words="composer docker git memcached mysql nginx php php8.3 postgres redis supervisor volta"
    ;;
  *) ;;

  esac

  COMPREPLY=($(compgen -W "$words" -- ${COMP_WORDS[$COMP_CWORD]}))
  return 0
}

complete -F _dev_cli dev-cli
