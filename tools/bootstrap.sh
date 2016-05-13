#!/usr/bin/env bash
#
# bootstrap installs things.
#
# Install directly from network:
#
# curl https://raw.githubusercontent.com/lhost/dotfiles/master/tools/bootstrap.sh | env bash
#

# define URL to my dotfiles git repo
DOTFILES_GIT_REPO="https://github.com/lhost/dotfiles.git"

if [ -z "`which dirname`" ]; then
	echo "Please install coreutils package"
	if [ -f /etc/debian_version ]; then
		sudo apt-get install coreutils
	elif [ -f /etc/redhat-release ]; then
		sudo yum install coreutils
	fi
	exit 1
fi

dirname="$(dirname "$0")"
if [ "x$dirname" = "x." ]; then  # when this script is started from curl $DOTFILES_GIT_REPO | env bash
	dirname=~/.config/dotfiles.git
fi
cd $dirname
DOTFILES_ROOT=$(pwd)

echo "DOTFILES_ROOT=$DOTFILES_ROOT"

set -e

echo ''

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_gitconfig ()
{ # {{{
  if ! [ -f ~/.local/.git/config ]; then
    info 'setup gitconfig'

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/gitconfig.symlink.example > ~/.local/.git/config

    success 'gitconfig'
  fi
} # }}}

link_file ()
{ # {{{
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
} # }}}

install_dotfiles ()
{ # {{{
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find "$DOTFILES_ROOT/" -maxdepth 2 -name '*.symlink')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done

  # find the installers and run them iteratively
  find . -name install.sh | while read installer ; do
  	sh -c "${installer}" ;
  done
} # }}}

# create basic directories
for dir in ~/.config ~/.local/.git; do
	if [ ! -d $dir ]; then
		mkdir -p $dir
	fi
done

if [ ! -d ~/.config/dotfiles.git/ ]; then
	cd ~/.config && git clone $DOTFILES_GIT_REPO dotfiles.git && cd dotfiles.git
else
	cd ~/.config/dotfiles.git/ && git pull
fi

install_dotfiles
setup_gitconfig

# If we're on a Mac, let's install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
  info "installing dependencies"
  if source bin/dot > /tmp/dotfiles-dot 2>&1
  then
    success "dependencies installed"
  else
    fail "error installing dependencies"
  fi
fi

echo ''
echo '  All installed!'

# vim: fdm=marker

