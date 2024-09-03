# Set software versions
GO_VERSION="1.21.6"
NVM_VERSION="0.40.1"
NODE_VERSION="20.17.0"

# Check if ca-certificates and curl are installed
if ! dpkg -s ca-certificates curl make wget >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl make wget
fi

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y jq
fi

# Create the keyrings directory if it doesn't exist
sudo install -m 0755 -d /etc/apt/keyrings

# Check if docker.asc already exists before downloading
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
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

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Check if Kurtosis is installed
if ! command -v kurtosis >/dev/null 2>&1; then
  echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
  sudo apt-get update
  sudo apt-get install -y kurtosis-cli
fi

# Check if gcc is installed
if ! command -v gcc >/dev/null 2>&1; then
  echo "gcc is not installed. Installing gcc..."
  sudo apt-get update
  sudo apt-get install -y gcc

  # Verify gcc installation
  if ! command -v gcc >/dev/null 2>&1; then
    echo "gcc installation failed or gcc is not found in the PATH."
    exit 1
  else
    echo "gcc has been successfully installed."
  fi
else
  echo "gcc is already installed."
fi

if ! command -v go >/dev/null 2>&1; then
  # Install Go
  wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
  rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/go/bin
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

  # Verify Go installation
  if ! command -v go >/dev/null 2>&1; then
    echo "Go installation failed or Go is not found in the PATH."
    exit 1
  fi
fi

if ! command -v polycli >/dev/null 2>&1; then
# Original script content
  git clone https://github.com/maticnetwork/polygon-cli.git
  cd polygon-cli

  make install

  ln -s $HOME/go/bin/polycli /usr/local/bin/polycli
fi

# Check if nvm is installed
if [ ! -d "$HOME/.nvm" ]; then
  # Install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

  # Load nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Verify nvm installation
  if ! command -v nvm >/dev/null 2>&1; then
    echo "nvm installation failed or nvm is not found in the PATH."
    exit 1
  fi
fi

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
  # Load nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Install the latest LTS version of Node.js
  nvm install ${NODE_VERSION}

  # Verify Node.js installation
  if ! command -v node >/dev/null 2>&1; then
    echo "Node.js installation failed or Node.js is not found in the PATH."
    exit 1
  fi
fi

if [ -d "polygon-cli" ]; then
  echo "Removing Polygon CLI source directory..."
  rm -rf polygon-cli
fi

# Remove go${GO_VERSION}.linux-amd64.tar.gz if it exists
if [ -f "go${GO_VERSION}.linux-amd64.tar.gz" ]; then
  echo "Removing go${GO_VERSION}.linux-amd64.tar.gz..."
  rm go${GO_VERSION}.linux-amd64.tar.gz
fi

source ~/.bashrc