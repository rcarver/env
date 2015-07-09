#!/bin/bash

# Abort on error.
set -e

# Set the ENV variable from where this script is located.
ENV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Write the location of this repo to ~/.envpath so that other scripts can find it.
echo Writing ~/.envpath with $ENV
echo "$ENV" > "$HOME/.envpath"


echo Running setup...

# This script sets up an OSX machine for my general happiness. Everything is
# idempotent, so it's safe to run repeatedly.

# Make sure OSX is configured nicely.
$ENV/bin/env-osx-defaults

# Install Homebrew, a package manager for OSX we'll use to get other stuff.
# http://brew.sh
if hash brew 2> /dev/null
then
  echo homebrew is installed
else
  echo Installing homebrew...
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install coreutils, providing better versions of common unix utilities.
# https://www.gnu.org/software/coreutils/manual/html_node/
if hash gls 2> /dev/null
then
  echo coreutils is installed
else
  echo Installing coreutils...
  brew install coreutils
fi

# Install grc, the generic colorizer for nice colors on a bunch of common utils.
# https://github.com/garabik/grc
if hash grc 2> /dev/null
then
  echo grc is installed
else
  echo Installing grc...
  brew install grc
fi

# Install macvim.
if hash mvim 2> /dev/null
then
  echo macvim is installed
else
  brew install macvim
  brew linkapps macvim
fi

# Configure other systems by symlinking dotfiles from this repo.
echo Installing dotfiles...
for source in `find "$ENV/dotfiles" -type f`
do
  dest="$HOME/.`basename \"${source}\"`"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" == "$source" ]
  then
    echo "$dest is linked"
  elif [ -f "$dest" ]
  then
    echo "$dest exists, but is not the file provided by env"
  else
    echo "linking $source to $dest"
    ln -fs "$source" "$dest"
  fi
done

exit 0
