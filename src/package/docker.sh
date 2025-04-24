#!/bin/bash

function pkg::docker::is_installed {
  docker -v > /dev/null 2>&1 && return 0 || return 1
}

function pkg::docker::install {
  if pkg::docker::is_installed; then
    io::line "Docker package already installed"
    return
  fi

  # shellcheck disable=SC2155
  local distrib=$(detect_linux_distrib)

  # Add Docker's official GPG key:
  sudo apt-get -yqq update
  sudo apt-get -y install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL "https://download.docker.com/linux/$distrib/gpg" -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$distrib \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get -yqq update

  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if [ -z "$(getent group docker)" ]; then
    sudo groupadd docker
  fi

  sudo usermod -aG docker "$USER"

  pkg::installed_message "Docker"

  io::warning "ПРЕДУПРЕЖДЕНИЕ! Для использования Docker необходимо выполнить перезапуск системы"
#  newgrp docker
}

function pkg::docker::remove {
  docker::down --rmi all
  sudo apt-get -y purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
}
