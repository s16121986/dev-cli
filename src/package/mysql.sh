#!/bin/bash

function pkg::mysql::is_installed {
  command -v "mariadb" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::mysql::install {
  if pkg::mysql::is_installed; then
    io::line "Mysql package already installed"
    return
  fi

  sudo apt -y install mariadb-server
  sudo systemctl enable mariadb
  sudo systemctl start mariadb
  sudo mysql -e "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';"
  sudo mysql -e "GRANT ALL PRIVILEGES ON * . * TO '$MARIADB_USER'@'%';"
}
