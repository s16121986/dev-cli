#!/bin/bash

set -e

function cli::update {
  git -C "$CLI_TOOL_PATH" pull -q
  io::success "Cli tool successful updated!"
}

function cli::configure {
  if [ ! -f "$CLI_TOOL_PATH/.env" ]; then
    cp "$CLI_TOOL_PATH/.env.example" "$CLI_TOOL_PATH/.env"
  fi

  # shellcheck disable=SC2046
  export $(grep -v '^#' "$CLI_TOOL_PATH/.env" | xargs)

  _setup_project_dir

  io::success "Configuration completed!"
}

function cli::config {
  while IFS= read -r line; do
    if [[ $line =~ ^#.* ]] || [[ -z $line ]]; then
      continue
    fi

    echo "$line"
  done <"$CLI_TOOL_PATH/.env"
}

function cli::usage {
  io::title "Usage:"
  io::line "  $CLI_ALIAS [options] [arguments]"
  echo ""

  io::title "Service commands:"
  io::dotted_line "  --install" "Run package installer"
  io::dotted_line "  --remove" "Remove installed packages"
  io::dotted_line "  --update" "Update cli tool"
  io::dotted_line "  --uninstall" "Uninstall"
  io::dotted_line "  --configure" "Configure variables"
  io::dotted_line "  --config" "Display config variables"
  io::dotted_line "  --wsl-update-hosts" "Update hosts file for WSL platform"
  echo ""
  io::comment "Tool location: /usr/local/lib"
}

cli::main() {
  ## Checking input parameters
  if [ $# -eq 0 ]; then
    cli::usage
    exit 0
  fi

  local arg="$1"
  shift

  case $arg in
  list | -h | --help)
    cli::usage "$@"
    exit 0
    ;;

  --update)
    cli::update "$@"
    ;;

  --uninstall)
    cli::uninstall "$@"
    ;;

  --configure)
    cli::configure "$@"
    ;;

  --config)
    cli::config "$@"
    ;;

  *)
    return
    ;;
  esac

  exit 0
}

function _setup_project_dir {
  ## Setup www dir
  [ -d "/var/www" ] || sudo mkdir -p "/var/www"
  sudo chown "$UID":"$GID" "/var/www"

  while true; do
    ## setup directory
    read -p "Укажите директорию в которой будут устанавливаться файлы проектов (${PROJECTS_SOURCE_PATH}): " i
    if [ -z "$i" ]; then
      i=$PROJECTS_SOURCE_PATH
    elif [[ $i != /* ]]; then
      i=$(realpath "$i")
    fi

    if [ ! -d "$i" ]; then
      if ! sudo mkdir -p "$i" 2>/dev/null; then
        io::error "Can't create folder. Check user ($USER) permissions"
        continue
      fi
      sudo chown "$UID":"$GID" "$i"
    fi
    break
  done

  if [ "$i" != "$PROJECTS_SOURCE_PATH" ]; then
    sed -i "/^PROJECTS_SOURCE_PATH=/c\PROJECTS_SOURCE_PATH=$i" "$CLI_TOOL_PATH/.env"
    PROJECTS_SOURCE_PATH="$i"
  fi
}

function setup_wsl_requirements {
  local wsl_required_packages=(php83 composer redis supervisor rabbitmq volta nginx)

  echo -e "${YELLOW}Внимание!${NC} Для работы в данном режиме требуется установка дополнительных сервисов"
  echo -e "Вы можете это сделать позже, запустив команду: $CLI_ALIAS --install"
  echo -en "${YELLOW}Запустить установку сервисов сейчас?$NC (Y/n): "
  read i
  case $i in
  Y | y | yes | "")
    echo -e "${GRAY}Запуск установщика...$NC"
    for i in "${wsl_required_packages[@]}"; do
      "$CLI_ALIAS" --install "${i}"
    done
    ;;
  *)
    echo "Установка прервана"
    ;;
  esac
}
