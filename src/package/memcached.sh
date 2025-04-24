#!/bin/bash

function pkg::memcached::is_installed {
  command -v "memcached" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::memcached::install {
  if pkg::memcached::is_installed; then
    io::line "Memcached package already installed"
    return
  fi

  sudo apt -y install memcached

  sudo systemctl enable memcached
}
