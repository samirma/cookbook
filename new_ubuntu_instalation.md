## Ubuntu

```sh
sudo apt update
sudo apt install vim wget curl rsync git
```

Setup git
```sh
git config --global user.name "Jane Doe"  
git config --global user.email "jane.doe@example.com" 

```

Install privite key into ~/.ssh

```sh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

```sh
ssh-copy-id -i ~/.ssh/id_res.pub -p 22 user@1.1.1.1
```

Brave
```sh
curl -fsS https://dl.brave.com/install.sh | sh
```

## Pyenv
https://github.com/pyenv/pyenv

```sh
curl -fsSL https://pyenv.run | bash
```

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
```

## Nvm
https://github.com/nvm-sh/nvm
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install 20
```

## Docker

```sh
curl -fsSL https://get.docker.com/ | sh
```


```sh
sudo usermod -aG docker $USER
```
