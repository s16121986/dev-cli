#!/bin/bash

function pkg::redis::is_installed {
  command -v "redis-cli" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::redis::install {
  if pkg::redis::is_installed; then
    io::line "Redis package already installed"
    return
  fi

  sudo apt -y install redis
  sudo systemctl enable redis-server

  pkg::installed_message "Redis"
}

function pkg::redis::remove {
  sudo apt-get purge -y --auto-remove redis-server
}
