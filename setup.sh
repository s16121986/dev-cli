#!/bin/bash

set -e

git_branch=main
install_path="/usr/local/lib"
bin_command="dev-cli"
tool_url="git@github.com:s16121986/dev-cli.git"
tool_name="dev-cli"
tool_path="$install_path/$tool_name"
gid="$(id -g)"

#RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function setup_git_config {
  # ensure git installed
  if [ -z "$(command -v git)" ]; then
    sudo apt -y install git
  fi

  if [ -z "$(git config -l)" ]; then
    git config --global core.eol lf
    git config --global core.autocrlf input
    git config --global core.safecrlf warn
    git config --global core.fileMode false
    git config --global credential.helper store
  fi

  log_success "Git config setup"
}

function parse_args {
  local arg
  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
    -b | --branch)
      git_branch="$1"
      shift
      ;;
    *)
      error "unknown option: '$arg'"
      #      usage
      exit 1
      ;;
    esac
  done
}

function clone_tool {
  if [ -d "$tool_path" ]; then
  log_success "cli-tool command"
    return 0
  fi

  if [ -d "/tmp/$tool_name" ]; then
    rm -rf "/tmp/$tool_name"
  fi

  git clone -q "$tool_url" "/tmp/$tool_name" || exit 2
  sudo mv "/tmp/$tool_name" "$install_path"
  sudo chown -R "$UID":"$gid" "$tool_path"
  cp "$tool_path/.env.example" "$tool_path/.env"
  if [ "$git_branch" != "main" ]; then
    git -C "$tool_path" checkout -q "$git_branch"
  fi

  log_success "Clone cli-tool"

  ## Add bin command alias
  sudo chmod o+x "$tool_path/cli.sh"
  sudo ln -sf "$tool_path/cli.sh" "/usr/local/bin/$bin_command"

  log_success "dev-cli command"
  echo -e "${GRAY}Справка по использованию: $bin_command -h${NC}"
}

function setup_wsl {
  local wsl_conf="/etc/wsl.conf"
  if [ ! -f "$wsl_conf" ]; then
    return 0
  fi

  # configure linux users & groups
  # shellcheck disable=SC2155
  local gn="$(id -gn)"
  if [ "$gn" != "psacln" ]; then
    sudo groupmod --new-name psacln "$gn"
    sudo usermod -g psacln www-data
  fi

  # register wsl-boot script
  local boot_script="$tool_path/wsl-boot.sh"
  sudo chmod o+x "$boot_script"

  if cat "$wsl_conf" | grep -qF "command="; then
    : #do nothing
  elif cat "$wsl_conf" | grep -qF "[boot]"; then
    sudo sed -i "s|\[boot]|[boot]\ncommand=$boot_script|g" "$wsl_conf"
  else
    sudo tee -a "$wsl_conf" >/dev/null <<EOT
[boot]
systemd=true
command=$boot_script
EOT
  fi

  # remove the need to enter a password for dev user
  if [ ! -f "/etc/sudoers.d/no-dev-pass" ]; then
    echo -e "$USER ALL=(ALL) NOPASSWD: ALL\n" | sudo tee -a "/etc/sudoers.d/no-dev-pass" >/dev/null
  fi

  # register bash aliases
  if [ ! -f "$HOME/.bash_aliases" ]; then
    cp "$tool_path/config/wsl/.bash_aliases" "$HOME/.bash_aliases"
  fi

  log_success "WSL configuration"
}

function setup_dev_user {
  if [ $USER == 'root' ]; then
    return
  fi
  groupadd psacln
  usermod -g psacln www-data
  useradd -b /home -mN -s /bin/bash -g psacln dev
  usermod -aG sudo dev
  passwd dev
}

function setup_sudo {
  if [ -z "$(command -v sudo)" ]; then
    sudo apt -y install sudo
  fi
}

function log_success {
  echo -e "$1: ${GREEN}OK$NC"
}

#echo "${YELLOW}Перед запуском установщика обязательно выполните настройку GitLab (https://$git_host/$git_path)"
#echo "Для продолжения нажмите любую клавишу"
#read

parse_args "$@"
sudo apt -yqq update && sudo apt -yqq install curl
setup_git_config
setup_sudo
#setup_dev_user
clone_tool
setup_wsl

# Register bash completion
sudo apt -yqq install bash-completion &>/dev/null
if [ ! -f "/etc/bash_completion.d/dev-cli-completion" ]; then
  sudo tee -a "/etc/bash_completion.d/dev-cli-completion" >/dev/null <<EOT
#
# Cli bash-completion
#

if [[ -e $tool_path/bash-completion.sh ]]; then
  . $tool_path/bash-completion.sh
fi
EOT
fi

## Configure variables
echo -e "Настрока дополнительных переменных: nano $tool_path/.env"
"$bin_command" --configure || exit 1

echo -e "${GREEN}dev-cli installed!$NC"
