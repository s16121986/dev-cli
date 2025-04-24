#!/bin/bash

PG_LOCALE="ru_RU.utf8"
PG_LOCALE_KEY="ru_RU.UTF-8"

function pkg::postgresql::is_installed {
  command -v "psql" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::postgresql::install {
  if pkg::postgresql::is_installed; then
    io::line "Postgresql package already installed"
    return
  fi

  if ! is_locale_exists "$PG_LOCALE"; then
    sudo sed -i "s|# $PG_LOCALE_KEY|$PG_LOCALE_KEY|g" /etc/locale.gen
    sudo locale-gen "$PG_LOCALE"
    sudo update-locale
  fi

  if ! is_locale_exists "$PG_LOCALE"; then
    #sudo dpkg-reconfigure locales
    io::error "Не удалось установть локаль $PG_LOCALE"
    return 1
  fi

  # todo detect latest
  local version=17

  # Import the repository signing key:
  sudo apt install curl ca-certificates
  sudo install -d /usr/share/postgresql-common/pgdg
  sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

  # Create the repository configuration file:
  sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

  # Update the package lists:
  sudo apt -yqq update

  # Install
  sudo apt -yqq install postgresql
  sudo systemctl enable --now postgresql

  # configure
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_PASSWORD}';"

  local conf_path="/etc/postgresql/$version/main"
  sudo sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" "$conf_path/postgresql.conf"
  sudo tee -a "$conf_path/pg_hba.conf" > /dev/null <<EOT
#allows connections from all IP addresses.
host    all             all             0.0.0.0/0               md5
EOT

  sudo service postgresql restart

  pkg::installed_message "Postgres"
}

function pkg::postgresql::remove {
  sudo apt-get -y --purge remove postgresql
  sudo apt-get purge -y postgresql*
  sudo apt -y autoremove
}

#function _search_postgres_latest_version {
#  echo $(sudo su postgres -c "psql -c 'SELECT version();'" | grep -oE '[0-9]+')
#  echo $(sudo apt-cache policy postgresql | grep -oE 'Candidate: [0-9]+')
#}
