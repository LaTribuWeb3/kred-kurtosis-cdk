# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

# Add the repository to Apt sources:
if ! grep -q "deb \[arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc\] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" /etc/apt/sources.list.d/docker.list; then
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
