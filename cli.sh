#!/bin/bash

set -e

## Set common variables
CLI_TOOL_PATH=$(realpath $(dirname $([ -L $0 ] && readlink -f $0 || echo $0)))
PACKAGES_PATH="$CLI_TOOL_PATH/src"
CONFIG_PATH="$CLI_TOOL_PATH/config"
CLI_ALIAS="dev-cli"
GID=$(id -g)

## Import helpers
source "$PACKAGES_PATH/common/io.sh"
source "$PACKAGES_PATH/common/system.sh"
source "$PACKAGES_PATH/cli-tool/cli-main.sh"

cli::main "$@"

## Ensure .env configured
if [ ! -f "$CLI_TOOL_PATH/.env" ]; then
  io::error -n ".env file not found!"
  exit 1
fi

source "$CLI_TOOL_PATH/.env"

## Import common libraries
source "$PACKAGES_PATH/cli-tool/env-manager.sh"

## Parse input
while [[ "$#" -gt 0 ]]; do
  arg="$1"
  shift

  case $arg in

  --install | --remove)
    subshell_call "$PACKAGES_PATH/main.sh" "pkg::${arg#"--"}" "$@"
    ;;

  *)
    io::error "Unknown parameter passed: $arg"
    cli::usage
    exit 1
    ;;
  esac

  break
done
