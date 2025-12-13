# Developer Environment Setup

This guide covers the setup of development tools for both Ubuntu and macOS.

## Git

### Installation

**Ubuntu:**
```sh
sudo apt update
sudo apt install git
```

**macOS:**
Git is usually available by default. You can also install it via Homebrew:
```sh
brew install git
```

### Configuration
Applies to both OS.

```sh
git config --global user.name "Your Name"  
git config --global user.email "your.email@example.com"
git config --global core.editor "vim"
```

## Java (JDK 21)

**macOS:**
```sh
brew install openjdk@21
brew link --overwrite openjdk@21

# Add to ~/.zshrc or ~/.bashrc depending on your shell
echo 'export JAVA_HOME="$(brew --prefix openjdk@21)"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Ubuntu:**
```sh
sudo apt install openjdk-21-jdk
```

To set `JAVA_HOME` permanently (optional but recommended):
```bash
# Check where java is
# update-alternatives --list java

# Add to ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" >> ~/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

## Python Global Setup (Pyenv + UV)

We will use **Pyenv** to manage Python versions and **uv** for extremely fast package management.

### 1. Install Pyenv
```sh
curl -fsSL https://pyenv.run | bash
```


**Ubuntu:**
```sh
# Add to ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
```

**macOS:**
```sh
# Add to ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Install and Set Global Python
Install a recent Python version (e.g., 3.12) and set it as global.

```sh
pyenv install 3.12
pyenv global 3.12
```

### 3. Install UV
https://github.com/astral-sh/uv

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## NVM (Node Version Manager)
https://github.com/nvm-sh/nvm

### Installation
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

### Usage
Install Node.js version 20:
```sh
nvm install 20
```

## Docker

**Ubuntu:**
Install Docker Engine:
```sh
curl -fsSL https://get.docker.com/ | sudo sh
sudo usermod -aG docker $USER
```

**macOS:**
Install Docker Desktop via Homebrew:
```sh
brew install --cask docker
```

## Android SDK Setup

**Ubuntu:**
```sh
echo 'export PATH="$PATH:$HOME/Android/Sdk/platform-tools"' >> ~/.bashrc
```

**macOS:**
```sh
echo 'export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"' >> ~/.zshrc
```
