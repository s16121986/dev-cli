#!/bin/bash

version="8.4"
phpKey="php$version"

function pkg::php84::is_installed {
  command -v "$phpKey" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::php84::install {
  if pkg::php84::is_installed; then
    io::line "PHP$version package already installed"
    return
  fi

  install_php "8.4"

  pkg::installed_message "PHP $version"
}

function pkg::php84::remove {
  remove_php "php8.4"
}



#function boot_xdebug {
#  local ini=$(cat )
#  cp "" "/etc/php/$version/mods-available/xdebug.ini"
#}
