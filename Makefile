.PHONY: install-kurtosis

# Default target
all: install-kurtosis

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

# Clean up (optional)
clean:
	@echo "Cleaning up..."
	@sudo rm -f /etc/apt/sources.list.d/kurtosis.list
	@sudo apt update
