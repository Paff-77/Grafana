#!/bin/bash

# Update package list and install zsh, git and autojump
sudo apt update
sudo apt install -y zsh git autojump

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone zsh-syntax-highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Clone zsh-autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Update plugins in .zshrc
sed -i 's/^plugins=.*/plugins=(git z autojump sudo zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Source .zshrc to apply changes
source ~/.zshrc

# Change default shell to zsh
chsh -s $(which zsh)

echo "Installation and configuration complete! Please restart your terminal."
