#!/bin/bash

function pkg::supervisor::is_installed {
  command -v "supervisord" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::supervisor::install {
  if pkg::supervisor::is_installed; then
    io::line "Supervisor package already installed"
    return
  fi

  sudo apt -y -qq install supervisor
  sudo systemctl enable supervisor

  # configure
  sudo chgrp -R $GID "/etc/supervisor/conf.d"
  sudo chmod -R g+rw "/etc/supervisor/conf.d"

  pkg::installed_message "Supervisor"
}
