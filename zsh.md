# ZSH
```
sudo apt install zsh git autojump -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## 代码高亮插件
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=.*/plugins=(git z autojump sudo zsh-syntax-highlighting)/' ~/.zshrc
source ~/.zshrc
```
## 代码填充插件
```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sed -i 's/^plugins=.*/plugins=(git z autojump sudo zsh-syntax-highlighting zsh-autosuggestions)/'~/.zshrc

source ~/.zshrc
```
