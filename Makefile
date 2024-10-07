.PHONY: install-kurtosis install-docker run-kurtosis

# Default target
all: install-docker install-kurtosis run-kurtosis

# Install Docker
install-docker:
	@echo "Installing Docker..."
	@if ! command -v docker &> /dev/null; then \
		sudo apt-get update; \
		sudo apt-get install -y ca-certificates curl gnupg; \
		sudo install -m 0755 -d /etc/apt/keyrings; \
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
		sudo chmod a+r /etc/apt/keyrings/docker.gpg; \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(. /etc/os-release && echo "$$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
		sudo apt-get update; \
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; \
	else \
		echo "Docker is already installed."; \
	fi
	@echo "Docker installation complete. Version installed:"
	@docker --version

# Install Kurtosis
install-kurtosis:
	@echo "Installing Kurtosis..."
	@if [ -f /etc/apt/sources.list.d/kurtosis.list ]; then \
		sudo rm /etc/apt/sources.list.d/kurtosis.list; \
	fi
	@echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list > /dev/null
	@sudo apt update
	@sudo apt install -y kurtosis-cli
	@kurtosis analytics disable
	@echo "Kurtosis installation complete. Version installed:"
	@kurtosis version

# Run Kurtosis
run-kurtosis:
	@echo "Running Kurtosis..."
	@kurtosis clean --all
	@kurtosis run --enclave cdk-v1 --args-file params.yml --image-download always .

# Clean up (optional)
clean:
	@echo "Cleaning up..."
	@sudo rm -f /etc/apt/sources.list.d/kurtosis.list
	@sudo apt update
	@kurtosis clean --all
