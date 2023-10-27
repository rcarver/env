#!/bin/bash
#
# This script sets up an OSX machine for my general happiness. Everything is
# idempotent, so it's safe to run repeatedly.
#

# Abort on error.
set -e

# Set the ENV variable from where this script is located.
ENVPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Write the location of this repo to ~/.envpath so that other scripts can find it.
echo ~/.envpath = \"$ENVPATH\"
echo "$ENVPATH" > "$HOME/.envpath"

# Make sure OSX is configured nicely.
$ENVPATH/bin/env-osx-defaults

# Install Homebrew, a package manager for OSX we'll use to get other stuff.
# http://brew.sh
if ! hash brew 2> /dev/null
then
  echo Installing homebrew...
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install coreutils, providing better versions of common unix utilities.
# https://www.gnu.org/software/coreutils/manual/html_node/
if ! hash gls 2> /dev/null
then
  echo Installing coreutils...
  brew install coreutils
fi

# Install grc, the generic colorizer for nice colors on a bunch of common utils.
# https://github.com/garabik/grc
if ! hash grc 2> /dev/null
then
  echo Installing grc...
  brew install grc
fi

# Install macvim, a pretty solid text editor.
if ! hash mvim 2> /dev/null
then
  echo Installing macvim...
  brew install macvim
fi

# Install Vundle vim plugin manager.
if ! test -d ~/.vim/bundle/Vundle.vim
then
  echo Installing vundle...
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# cmake is required for YouCompleteMe vim plugin.
if ! hash cmake 2> /dev/null
then
  echo Installing cmake...
  brew install cmake
fi

# Install aws tools.
if ! hash aws 2> /dev/null
then
  echo Installing aws
  brew install awscli
fi

# Install exuberant ctags for vim.
# Check for location of install here because a default install already has
# /usr/bin/ctags but we need to a new version.
if ! test -x /usr/local/bin/ctags 2> /dev/null
then
  echo Installing ctags
  brew install ctags-exuberant
fi

# Install ack, for searching.
if ! hash ack 2> /dev/null
then
  echo Installing ack...
  brew install ack
fi

# Install git-lfs for git large files
if ! hash git-lfs 2> /dev/null
then
  echo Installing git-lfs...
  brew install git-lfs
  git lfs install
fi

# Install jq for json parsing
if ! hash jq 2> /dev/null
then
  echo Installing jq...
  brew install jq
fi

# Install jsonpp for json printing
if ! hash jsonpp 2> /dev/null
then
  echo Installing jsonpp...
  brew install jsonpp
fi

# Install xcodes for installing Xcode
if ! hash xcodes 2> /dev/null
then
  echo Installing xcodes...
  brew install xcodes
fi

# Install heroku
if ! hash heroku 2> /dev/null
then
  echo Installing heroku...
  brew tap heroku/brew && brew install heroku
fi

if ! hash psql 2> /dev/null
then
  echo Installing postgresql...
  brew install postgresql
fi

# Install zsh-completions for general magic.
if [ ! -d /usr/local/share/zsh-completions ]
then
  echo Installing zsh-completions...
  brew install zsh-completions
fi

if [ ! -f $HOME/.iterm2_shell_integration.zsh ]
then
  echo Installing iTerm2 shell integration...
  curl -sL https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
fi

# Ensure permissions are correct for completions
# https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
# compaudit | xargs chmod g-w

# Configure other systems by symlinking dotfiles from this repo.
for source in `find "$ENVPATH/dotfiles" -type f`
do
  dest="$HOME/.`basename \"${source}\"`"
  # If it's a symblink and points to the source, we're good.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" == "$source" ]
  then
    continue
  # But if it's a file, then leave it but warn the user.
  elif [ -f "$dest" ]
  then
    echo "$dest exists, but is not the file provided by env"
  # Else create a symlink.
  else
    echo "Linking $source to $dest"
    ln -fs "$source" "$dest"
  fi
done

