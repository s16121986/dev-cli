#!/bin/bash

pkg::php::is_installed() {
  # shellcheck disable=SC2046
  command -v "php" >/dev/null 2>&1 && return 0 || return 1
}

pkg::php::install() {
  local versions=("8.3")

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


pkg::init_php_repository() {
  # shellcheck disable=SC2155
  local distrib=$(detect_linux_distrib)
  case "$distrib" in
  "debian")
    if [ -f /etc/apt/sources.list.d/php.list ]; then
      return 0
    fi

    sudo apt -y install apt-transport-https lsb-release ca-certificates wget
    local php_proxy="https://ftp.mpi-inf.mpg.de/mirrors/linux/mirror/deb.sury.org/repositories/php/"
    sudo cp "$CONFIG_PATH/php/apt.gpg" /etc/apt/trusted.gpg.d/php.gpg
    echo "deb $php_proxy $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
    #sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    #sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
    ;;
  "ubuntu")
    if [ ! -z "$(apt-cache policy | grep "ondrej/php")" ]; then
      return 0
    fi

    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt -yqq update
    ;;
  esac

  sudo apt update

  return 0
}

#pkg::php::manage_nginx_upstreams() {
#  if ! pkg::nginx::is_installed; then
#    return 0
#  fi
#
#  if pkg::php83::is_installed; then
#    _write_nginx_upstream "php8.3"
#  else
#    rm -f /etc/nginx/conf.d/php8.3-upstream
#  fi
#}
#
#function _write_nginx_upstream {
#  local version="$1"
#    sudo tee -a "/etc/nginx/conf.d/$version-upstream" > /dev/null <<EOT
#upstream $version-upstream {
#    server unix:/var/run/php/$version-fpm.sock;
#}
#EOT
#}
