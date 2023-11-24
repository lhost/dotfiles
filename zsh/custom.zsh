# $Id: zshrc-local,v 1.16 2002/03/16 17:21:52 8host Exp $
# vim:set ts=4:
# vim600:fdm=marker fdl=0 fdc=3 ft=zsh:

mesg y
bindkey -e

# Set prompts
#PROMPT='%m%# '    # default prompt
#PS1='%B%T %m%b [%~]: '
if [[ ${UID} == 0 ]]; then
		PROMPT="%B%T %n@%m%b [%~]%{[35;1m%}%#%#%{[0m%} "
else    
		PROMPT='%B%T %n@%m%b [%~]: '
fi
# http://tldp.org/HOWTO/Xterm-Title-4.html
precmd () { print -Pn "\e]0;%n@%m: %~\a" }
   

#RPROMPT=' %~'     # prompt for right side of screen


# Some environment variables
export USER=`id -un`
export LOGNAME=$USER
export PATH=/snap/bin:$HOME/.local/bin/:$HOME/bin:/sbin:/usr/sbin:$PATH
#export MAIL=/var/spool/mail/`id -u -n`
unset MAIL
export MAILDIR=$HOME/Maildir
export HOSTNAME=`/bin/hostname`
export EDITOR=vim
export BROWSER=firefox
export PAGER=less
export LESS='-M'
export ZBEEP=''
export LYNX_TEMP_SPACE=/tmp/
#export LESSCHARSET=iso8859

# Zsh options {{{
setopt NOTIFY
#setopt CORRECT
setopt NO_HUP
#setopt MAIL_WARNING
unsetopt MAIL_WARNING
setopt NO_BG_NICE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
#setopt PROMPT_CR
setopt EXTENDED_HISTORY
#setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt LIST_TYPES
setopt MAGIC_EQUAL_SUBST
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB

# 'PUSHD*' used with 'cd' and 'cx' alias 
setopt PUSHD_IGNORE_DUPS
#setopt PUSHD_MINUS 
setopt PUSHD_SILENT
#setopt PUSHD_TO_HOM


zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' menu select=long
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl true

autoload -Uz complete

# }}}

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.local/zsh/history

# limits
ulimit -c unlimited # core dump size
ulimit -s unlimited # stack size (8192)

# export LS_COLORS {{{
export LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;37;41:mi=01;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:*.c=00;33:*.h=00;36:"
#export LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:*.c=00;33:*.h=00;36:"
# }}}

#
# Shell functions {{{
#
##mc ()
##{
##	MC=/tmp/mc$$-"$RANDOM"
##	/usr/bin/mc -P "$@" > "$MC"
##	cd "`cat $MC`"
##	rm "$MC"
##	unset MC;
##}

# csh compatibility
setenv()
{
	export $1=$2
} 

# set $DISPLAY enviroment using $SSH_CLIENT
disp()
{
    local DISP
    export DISPLAY=
    if [ "$?SSH_CLIENT" ]; then
        DISP=`xauth list  "$SSH_CLIENT":0 | awk '{print $1}'`
        if [ ! -z "$DISP" ]; then
            if [ $SHLVL != 1 ]; then
                echo "Setting DISPLAY $DISP"
            fi
            export DISPLAY=$DISP
        fi
    fi
}

vimhelp()
{
	vim -c "help $1" -c on
}

gvimhelp()
{
	gvim -c "help $1" -c on
}

# }}}

# If login shell then set display
#if [ $SHLVL = 1 ]; then
#	disp
#fi

