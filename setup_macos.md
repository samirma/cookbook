## Mac Installation

### Homebrew
https://brew.sh/

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Oh My Zsh
https://github.com/ohmyzsh/ohmyzsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
echo 'ZSH_THEME="risto"' >>  ~/.zshrc

### Itsycal (Mowglii)
https://mowglii.com/itsycal/

```sh
brew install --cask itsycal
```

### KeepingYouAwake
https://github.com/newmarcel/KeepingYouAwake

```sh
brew install --cask keepingyouawake
```

### Sudo TouchID
https://github.com/artginzburg/sudo-touchid

```sh
brew install artginzburg/tap/sudo-touchid
sudo-touchid
```

### Enable the sound icon in the menu bar
```sh
defaults -currentHost write com.apple.controlcenter Sound -int 18
```

### To set the Dock to automatically hide
```sh
defaults write com.apple.dock autohide -bool true
killall Dock
```



