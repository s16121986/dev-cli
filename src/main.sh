#!/bin/bash

set -e

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
pkg_include_path="$script_dir"
pkg_packages_path="$pkg_include_path/package"
pkg_packages=(php nginx composer redis postgresql supervisor rabbitmq volta docker mysql memcached)

for file in "$pkg_packages_path"/*.sh; do
  # shellcheck disable=SC1090
  source "$file"
done

function pkg::is_package_exists {
  local package="$1"
  if [ -f "${pkg_packages_path}/$package.sh" ]; then
    return 0
  elif [ -f "${pkg_packages_path}/$(_pkg_get_alias "$package").sh" ]; then
    return 0
  else
    return 1
  fi
}

function pkg::is_package_installed {
  # shellcheck disable=SC2155
  local package=$(_pkg_get_alias "$1")
  pkg::${package}::is_installed && return 0 || return 1
}

function pkg::install_package {
  # shellcheck disable=SC2155
  local package=$(_pkg_get_alias "$1")
  if ! pkg::is_package_exists "$package"; then
    io::error "Package \"$package\" not found"
    return
  fi

  "pkg::${package}::install"
}

function pkg::run_installer {
  io::title "Allowed packages:"
  local n=1
  for i in "${pkg_packages[@]}"; do
    if pkg::is_package_installed "${i}"; then
      postfix=" ${GREEN}INSTALLED${NC}"
    else
      postfix=""
    fi

    io::dotted_line "$(printf %3s ${n})" "${i}${postfix}"
    n=$((n + 1))
  done

  read -p "Press <enter> to keep the current choice[*], or type selection number: " i
  if [ -z ${i} ]; then i=0; fi

  if [ $i -eq 0 ]; then
    :
  else
    pkg::install_package "${pkg_packages[$i - 1]}"
  fi
}

function pkg::usage {
  io::title "Usage:"
  io::line " $CLI_ALIAS --install [options] <package>"
  echo ""

  # Allowed installers
  #io::title "Allowed installers:"
  #io::dotted_line "  all" "Install all packages"
  #io::dotted_line "  lnmp" "Nginx + MySQL + PHP"
  #io::dotted_line "  wsl" "Init wsl"
  #echo ""

  # Allowed packages
  io::title "Allowed packages:"

  for i in "${pkg_packages[@]}"; do
    if pkg::is_package_installed "${i}"; then
      io::dotted_line "  ${i}" "${GREEN}INSTALLED${NC}"
    else
      io::dotted_line "  ${i}" "${RED}NOT INSTALLED${NC}"
    fi
  done
}

pkg::install() {
  ## If no arguments run auto-install
  if [ $# -eq 0 ]; then
    pkg::run_installer
    return
  fi

  while [ ! $# -eq 0 ]; do
    case "$1" in
    -h | --help | list)
      pkg::usage
      ;;
    *)
      pkg::install_package "${1}"
      ;;
    esac
    shift
  done
}

pkg::remove() {
  if [ $# -eq 0 ]; then
    #    pkg::run_installer
    return
  fi

  # shellcheck disable=SC2155
  local package=$(_pkg_get_alias "$1")
  if ! pkg::is_package_exists "$package"; then
    io::error "Package \"$package\" not found"
    return
  fi

  "pkg::${package}::remove"
}

function pkg::installed_message {
  io::success "${1} installed successful!"
}

function _pkg_get_alias {
  name="$1"
  case $name in
  postgres)
    echo "postgresql"
    ;;
  mariadb)
    echo "mysql"
    ;;
  php8.3)
    echo "php83"
    ;;
  *)
    echo "$name"
    ;;
  esac
}
