#!/bin/bash

function pkg::volta::is_installed {
  command -v "volta" >/dev/null 2>&1 && return 0 || return 1
}

function pkg::volta::install {
  if pkg::volta::is_installed; then
    io::line "Volta package already installed"
    return
  fi

  curl https://get.volta.sh | bash

#  echo "
#  export VOLTA_HOME=\"$HOME/.volta\"
#  export PATH=\"$VOLTA_HOME/bin:$PATH\"
#  " >>~/.bashrc

  "$HOME/.volta/bin/volta" install node@latest
  "$HOME/.volta/bin/volta" install npm@latest

  pkg::installed_message "Volta"
  #echo "volta list"

  #wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

  #~/.nvm/nvm.sh install node
}
