#!/bin/bash

version="8.3"
phpKey="php$version"

function pkg::php83::is_installed {
  command -v "$phpKey" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::php83::install {
  if pkg::php83::is_installed; then
    io::line "PHP$version package already installed"
    return
  fi

  install_php "8.3"

  pkg::installed_message "PHP $version"
}

function pkg::php83::remove {
  remove_php "php8.3"
}



#function boot_xdebug {
#  local ini=$(cat )
#  cp "" "/etc/php/$version/mods-available/xdebug.ini"
#}
