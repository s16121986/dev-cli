install_php() {
  local version="$1"
  local phpKey="php$version"
  local config_path="$CONFIG_PATH/php"

  _init_php_repository

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
    _update_php_assertion "$p/php.ini"
    sudo ln -sf "$shared_conf_path/laravel.ini" "$p/conf.d/00-laravel.ini"
    #    sudo ln -sf "$shared_conf_path/xdebug.ini" "$p/conf.d/00-xdebug.ini"
  done

  sudo sed -i "s/^group = www-data/;group = www-data/" "/etc/php/$version/fpm/pool.d/www.conf"
  sudo sed -i "s/^listen.group = www-data/;listen.group = www-data/" "/etc/php/$version/fpm/pool.d/www.conf"

  sudo systemctl enable "$phpKey-fpm"
  sudo service "$phpKey-fpm" restart
}

remove_php() {
  local phpKey="$1"
  sudo apt remove -y "${phpKey}-fpm"
  sudo apt remove -y "$phpKey"
  sudo apt-get purge -y "$phpKey"*
  sudo apt -y autoremove
  sudo rm "/usr/bin/$phpKey"

  #  pkg::php::manage_nginx_upstreams
}

function _update_php_assertion {
  local ini="$1"
  sudo sed -i "s|zend.assertions = -1|zend.assertions = 1|g" "$ini"
}
function _init_php_repository {
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
