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

  local config_path="$CONFIG_PATH/php"

  pkg::init_php_repository

  local extensions=(common cli xdebug pgsql mysqlnd redis memcached opcache bcmath mcrypt zip xml curl mbstring gd soap yaml fpm)
  for i in "${extensions[@]}"; do
    sudo apt -yqq install "${phpKey}-${i}"
  done

  # configure
  #  sudo chown -R $UID:$GID "/etc/php/$version/fpm"

  local shared_conf_path="/etc/php/$version/mods-available"
  sudo mkdir -p "$shared_conf_path"

  sudo cp "$config_path/laravel.ini" "$shared_conf_path"
  sudo cp "$config_path/xdebug.ini" "$shared_conf_path"
  #  cat "$config_path/xdebug.ini" | sudo tee "$shared_conf_path/xdebug.ini" > /dev/null
  sudo sed -i "s/^xdebug.client_port=9003/xdebug.client_port=$PHP_PHP_XDEBUG_PORT/" "$shared_conf_path/xdebug.ini"

  local dirs=(cli fpm)
  for i in "${dirs[@]}"; do
    local p="/etc/php/$version/$i"
    update_php_assertion "$p/php.ini"
    sudo ln -sf "$shared_conf_path/laravel.ini" "$p/conf.d/00-laravel.ini"
    #    sudo ln -sf "$shared_conf_path/xdebug.ini" "$p/conf.d/00-xdebug.ini"
  done

  sudo sed -i "s/^group = www-data/;group = www-data/" "/etc/php/$version/fpm/pool.d/www.conf"
  sudo sed -i "s/^listen.group = www-data/;listen.group = www-data/" "/etc/php/$version/fpm/pool.d/www.conf"

  sudo systemctl enable "$phpKey-fpm"
  sudo service "$phpKey-fpm" restart

  #  pkg::php::manage_nginx_upstreams

  pkg::installed_message "PHP $version"
}

function pkg::php83::remove {

  sudo apt remove -y "${phpKey}-fpm"
  sudo apt remove -y "$phpKey"
  sudo apt-get purge -y "$phpKey"*
  sudo apt -y autoremove
  sudo rm "/usr/bin/$phpKey"

  #  pkg::php::manage_nginx_upstreams
}

function update_php_assertion {
  local ini="$1"
  sudo sed -i "s|zend.assertions = -1|zend.assertions = 1|g" "$ini"
}

#function boot_xdebug {
#  local ini=$(cat )
#  cp "" "/etc/php/$version/mods-available/xdebug.ini"
#}
