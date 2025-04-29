#!/bin/bash

source "$PACKAGES_PATH/common/io.sh"

pkg::php::is_installed() {
  # shellcheck disable=SC2046
  command -v "php" >/dev/null 2>&1 && return 0 || return 1
}

pkg::php::install() {
  local versions=("8.3", "8.4")

  io::title "Choose PHP version to install:"

  local n=0
  for i in "${versions[@]}"; do
    if [ $n -eq 0 ]; then
      io::dotted_line "* ${n}" "${i}"
    else
      io::dotted_line "  ${n}" "${i}"
    fi
    n=$((n + 1))
  done

  read -p "Press <enter> to keep the current choice[*], or type selection number: " v

  if [ -z "$v" ]; then
    v=0
  fi

  # shellcheck disable=SC2155
  local n=$(sed "s/\.//g" <<<"${versions[v]}")

  pkg::install_package "php${n}"
}
