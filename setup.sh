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
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
  brew install macvim --override-local-vim
  brew linkapps macvim
fi

if ! test -d ~/.vim/bundle/Vundle.vim
then
  echo Installing vundle...
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install aws tools.
if ! hash aws 2> /dev/null
then
  echo Installing aws
  brew install awscli
fi

# Install ctags for vim.
if ! hash ctags 2> /dev/null
then
  echo Installing ctags
  brew install ctags
fi

# Install ack, for searching.
if ! hash ack 2> /dev/null
then
  echo Installing ack...
  brew install ack
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

# Install zsh-completions for general magic.
if [ ! -d /usr/local/share/zsh-completions ]
then
  echo Installing zsh-completions...
  brew install zsh-completions
fi

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

