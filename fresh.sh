#!/bin/sh

echo "Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Removes .zsh_history from $HOME (if it exists) and symlinks from the .dotfiles
rm -rf $HOME/.zsh_history
ln -s $HOME/.dotfiles/.zsh_history $HOME/.zsh_history

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file $DOTFILES/Brewfile

# Set default MySQL root password and auth type
#mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Clone Github repositories
#$DOTFILES/clone.sh

# Symlink the Mackup config file to the home directory
ln -s $DOTFILES/.mackup.cfg $HOME/.mackup.cfg

#Symlink Git config files
ln -s $DOTFILES/.gitignore_global $HOME/.gitignore
ln -s $DOTFILES/.gitconfig_global $HOME/.gitconfig

# Symlink MAVEN settings , backed up using mackup so commeting it out, storing in this repo as a backup
#ln -s $DOTFILES/settings.xml $HOME/.m2/settings.xml

# Set macOS preferences - we will run this last because this will reload the shell
echo "Setting macOS preferences..."
source $DOTFILES/.macos

#Create .secrets file in HOME folder if it doesnt exist 
[ ! -d "$HOME/.secrets" ] && mkdir "$HOME/.secrets"