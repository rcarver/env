#!/bin/bash
#
# This script sets up an OSX machine for my general happiness. Everything is
# idempotent, so it's safe to run repeatedly.
#

# Abort on error.
set -e

# Set the ENV variable from where this script is located.
ENV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Write the location of this repo to ~/.envpath so that other scripts can find it.
echo ~/.envpath = \"$ENV\"
echo "$ENV" > "$HOME/.envpath"

# Make sure OSX is configured nicely.
$ENV/bin/env-osx-defaults

# Install Homebrew, a package manager for OSX we'll use to get other stuff.
# http://brew.sh
if not hash brew 2> /dev/null
then
  echo Installing homebrew...
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install coreutils, providing better versions of common unix utilities.
# https://www.gnu.org/software/coreutils/manual/html_node/
if not hash gls 2> /dev/null
then
  echo Installing coreutils...
  brew install coreutils
fi

# Install grc, the generic colorizer for nice colors on a bunch of common utils.
# https://github.com/garabik/grc
if not hash grc 2> /dev/null
then
  echo Installing grc...
  brew install grc
fi

# Install macvim, a pretty solid text editor.
if not hash mvim 2> /dev/null
then
  echo Installing macvim...
  brew install macvim
  brew linkapps macvim
  ln -s /usr/local/bin/mvim /usr/local/bin/vim
fi

if [ ! -d /usr/local/share/zsh-completions ]
then
  echo Installing zsh-completions...
  brew install zsh-completions
fi

# Configure other systems by symlinking dotfiles from this repo.
for source in `find "$ENV/dotfiles" -type f`
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

