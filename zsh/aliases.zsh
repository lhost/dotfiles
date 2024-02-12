
# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias g="git"
alias h="history"
alias j="jobs"

unalias	ls &>/dev/null
alias ls='ls -F -C --color=auto --show-control-chars --time-style=long-iso'
alias l='ls -a'
alias ll='ls -la --time-style=long-iso'
alias dir='ls -la --time-style=long-iso'
alias s='screen -h 10000 -U'
alias net='export TERM=vt100'
alias S='less -S -R'
alias x='startx &'
# share files on the web:
alias www='setfacl -s user::rw-,group::---,other::r--,u:www-data:r--'
alias grep='grep --color=always --exclude="*.map" --exclude="*.min.css" --exclude="*.min.js" --exclude-dir=.git --exclude-dir=.tmp --exclude-dir=.idea --exclude-dir=vendor --exclude-dir=node_modules'

unalias	pstree &> /dev/null
alias	pstree='pstree -pGh'
alias	lo=exit

alias   rm='rm -i -v'
#alias   cp='cp -i -v'
alias cp='nocorrect cp'       # no spelling correction on cp
#alias   mv='mv -i -v'
alias mv='nocorrect mv'       # no spelling correction on mv
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir

# 'cd' push directory onto the directory stack
# 'cx' pop directory from the stack
alias cd='pushd'
alias cx='pushd -0 > /dev/null'
alias ks='killall -STOP xlock'
alias kc='killall -CONT xlock'

#
# PHP stuff
#
alias serve='php artisan serve'
alias art='php artisan'
alias mig='php artisan migrate'
alias seed='php artisan db:seed'
alias tinker='php artisan tinker'

alias a='php artisan'
alias c='composer'

#
# Define aliases 'g:m' and 'g.m' (dot saves one Shift press):
#
for sep in ':' '.'; do
	alias g${sep}m='php artisan generate:model'
	alias g${sep}c='php artisan generate:controller'
	alias g${sep}v='php artisan generate:view'
	alias g${sep}s='php artisan generate:seed'
	alias g${sep}mig='php artisan generate:migration'
	alias g${sep}r='php artisan generate:resource'

	alias c${sep}i='composer install'
done

#unalias run-help
autoload run-help

# ViM modeline
# vim: ft=zsh
