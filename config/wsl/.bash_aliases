# common
alias h="history"
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"
alias home="cd ~"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias c="clear"
alias cla="clear && ls -la"
alias cll="clear && ls -l"
alias cls="clear && ls"

# laravel
alias art="php artisan"
alias migrate="php artisan release:migrate"

# composer
alias cu="composer update"
alias ci="composer install"
alias cr="composer require"

# npm
alias nd="npm run dev"
alias nb="npm run build"
alias nu="npm update && npx browserslist@latest --update-db"
alias ni="npm install && npx browserslist@latest --update-db"

# git
alias gs="git status"
alias gf="git fetch"
alias gr="git reset --hard && git clean -df"
alias gp="git pull"

# nav
alias .www="cd /var/www"
alias .vhosts="cd /var/www/vhosts"
alias .logs="cd ./storage/logs"

# Add artisan autocomplete
function _artisan()
{
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
	COMMANDS=`php artisan --raw --no-ansi list | sed "s/[[:space:]].*//g"`
	COMPREPLY=(`compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"`)
	return 0
}
complete -F _artisan art
