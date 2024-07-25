#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Kurtosis is already installed
if command_exists kurtosis; then
    echo "Kurtosis is already installed."
    kurtosis version
else
    echo "Installing Kurtosis..."
    echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
    sudo apt update
    sudo apt install kurtosis-cli
    # Verify installation
    if command_exists kurtosis; then
        echo "Kurtosis has been successfully installed."
        kurtosis version
    else
        echo "Failed to install Kurtosis. Please check the installation process and try again."
        exit 1
    fi
fi

# Check if curl is installed, if not, install it
if ! command_exists curl; then
    echo "curl is not installed. Installing curl..."
    sudo apt-get update
    sudo apt-get install -y curl
fi

# Install Docker
if ! command_exists docker; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker has been installed. Please log out and log back in for the changes to take effect."
else
    echo "Docker is already installed."
fi

echo "Kurtosis installation complete."