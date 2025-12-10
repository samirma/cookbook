## Mac Installation

### Homebrew
https://brew.sh/

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Oh My Zsh
https://github.com/ohmyzsh/ohmyzsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
 ~/.zshrc -> ZSH_THEME="risto"

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

### System Defaults
Enable the sound icon in the menu bar:
```sh
defaults -currentHost write com.apple.controlcenter Sound -int 18
```
