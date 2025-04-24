#!/bin/bash

function pkg::nginx::is_installed {
  [ -x /usr/sbin/nginx ] && return 0 || return 1
}

function pkg::nginx::install {
  if pkg::nginx::is_installed; then
    io::line "Nginx package already installed"
    return
  fi

  # shellcheck disable=SC2153
  local config_path="$CONFIG_PATH/nginx"

  sudo apt -y install nginx

  # configure
  sudo chgrp "$GID" /etc/nginx/nginx.conf
  sudo chmod g+rw /etc/nginx/nginx.conf
  local folders=(conf.d sites-available sites-enabled snippets)
  for i in "${folders[@]}"; do
    sudo mkdir -p "/etc/nginx/${i}"
  done

  sudo rm /etc/nginx/nginx.conf
  sudo cp "$config_path/nginx.conf" /etc/nginx/nginx.conf
  sudo rm -f "/etc/nginx/sites-available/default"
  sudo ln -sf "$config_path/default" "/etc/nginx/sites-enabled/default"
#  sudo ln -sf "$config_path/conf.d"/* "/etc/nginx/conf.d"
  sudo ln -sf "$CONFIG_PATH/nginx/snippets"/* "/etc/nginx/snippets"

  sudo systemctl enable nginx

#  pkg::php::manage_nginx_upstreams

  pkg::installed_message "Nginx"

  io::warning "ПРЕДУПРЕЖДЕНИЕ! Для корректной работы Nginx необходимо выполнить перезапуск системы"
}

function pkg::nginx::remove {
  sudo systemctl stop nginx
  sudo apt-get -y remove nginx nginx-common
  sudo apt-get -y purge nginx nginx-common
  sudo apt -y autoremove
  sudo rm -rf /etc/nginx/
  sudo rm -rf /var/log/nginx/
}
