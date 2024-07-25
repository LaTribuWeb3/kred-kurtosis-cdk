# Install Go
apt update
apt install -y wget

wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Verify Go installation
go version

# Original script content
git clone https://github.com/maticnetwork/polygon-cli.git
cd polygon-cli

make install
export PATH="$HOME/go/bin:$PATH"