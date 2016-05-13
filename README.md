# dotfiles
* My configuration files can be shared on github.
* If it is possible, I put config files inside ~/.config/ directory
* My local changes are stored inside ~/.local/ directory

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/.config/dotfiles.git`) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
curl https://raw.githubusercontent.com/lhost/dotfiles/master/tools/bootstrap.sh | env bash
```

To update, `cd` into your local `dotfiles.git` repository and then:

```bash
cd ~/.config/dotfiles.git/
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Add custom commands without creating a new fork

If `~/.local/zsh/*.zsh` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.local/zsh/env.zsh` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Lubomir Host"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="lubomir.host@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

#git config --global user.name  "$GIT_AUTHOR_NAME"
#git config --global user.email "$GIT_AUTHOR_EMAIL"
git config --file ~/.local/.git/config user.name  "$GIT_AUTHOR_NAME"
git config --file ~/.local/.git/config user.email "$GIT_AUTHOR_EMAIL"
```


