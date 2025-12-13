# SSH Key Restoration

Restore SSH keys from a local backup (e.g., Downloads folder), setting the correct permissions

```bash
mkdir -p ~/.ssh && \
cp ~/Downloads/private/id_rsa ~/.ssh/ && \
cp ~/Downloads/private/id_rsa.pub ~/.ssh/ && \
chmod 700 ~/.ssh && \
chmod 600 ~/.ssh/id_rsa && \
chmod 644 ~/.ssh/id_rsa.pub && \
````


Copy the public key to a remote host.
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub username@remote_host
````
