#!/bin/sh

if [ ! -d ~/.vim/bundle ]; then
	echo "~/.vim directory not symlinked to dotfiles.git yet"
	exit 1
fi
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
	 git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

vim +PluginInstall +qall

