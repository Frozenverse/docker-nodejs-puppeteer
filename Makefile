.PHONY: build build-all push push-all test clean help

# Default values
NODE_VERSION ?= 20
UBUNTU_VERSION ?= 22.04
IMAGE_NAME ?= nodejs-puppeteer
REGISTRY ?= 

# Build single image
build:
	@echo "Building image for Node $(NODE_VERSION)..."
	@docker build \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		-t $(IMAGE_NAME):node$(NODE_VERSION)-ubuntu$(UBUNTU_VERSION) \
		-t $(IMAGE_NAME):node$(NODE_VERSION) \
		-f ubuntu$(UBUNTU_VERSION)/Dockerfile \
		.

# Build all configured versions
build-all:
	@echo "Building all configured images..."
	@./build.sh

# Push single image
push:
	@if [ -z "$(REGISTRY)" ]; then \
		echo "Error: REGISTRY not set. Use 'make push REGISTRY=your-registry'"; \
		exit 1; \
	fi
	@docker tag $(IMAGE_NAME):node$(NODE_VERSION) $(REGISTRY)/$(IMAGE_NAME):node$(NODE_VERSION)
	@docker push $(REGISTRY)/$(IMAGE_NAME):node$(NODE_VERSION)

# Push all images
push-all:
	@if [ -z "$(REGISTRY)" ]; then \
		echo "Error: REGISTRY not set. Use 'make push-all REGISTRY=your-registry'"; \
		exit 1; \
	fi
	@./build.sh --push --registry $(REGISTRY)

# Test image
test:
	@echo "Testing Node $(NODE_VERSION) image..."
	@docker run --rm $(IMAGE_NAME):node$(NODE_VERSION) node --version
	@docker run --rm $(IMAGE_NAME):node$(NODE_VERSION) npm --version
	@docker run --rm $(IMAGE_NAME):node$(NODE_VERSION) sh -c "npm init -y && npm install puppeteer && echo 'Puppeteer installed successfully'"

# Run interactive shell
shell:
	@docker run -it --rm \
		-v $(PWD)/workspace:/workspace \
		$(IMAGE_NAME):node$(NODE_VERSION) \
		/bin/bash

# Clean up images
clean:
	@echo "Removing nodejs-puppeteer images..."
	@docker images --format "{{.Repository}}:{{.Tag}}" | grep "^$(IMAGE_NAME):" | xargs -r docker rmi

# Show help
help:
	@echo "Docker Node.js Puppeteer - Makefile Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make build          Build single image (NODE_VERSION=20)"
	@echo "  make build-all      Build all configured versions"
	@echo "  make test           Test the image"
	@echo "  make shell          Run interactive shell in container"
	@echo "  make push           Push single image to registry"
	@echo "  make push-all       Push all images to registry"
	@echo "  make clean          Remove all built images"
	@echo "  make help           Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  NODE_VERSION        Node.js version (default: 20)"
	@echo "  UBUNTU_VERSION      Ubuntu version (default: 22.04)"
	@echo "  IMAGE_NAME          Image name (default: nodejs-puppeteer)"
	@echo "  REGISTRY            Docker registry for push operations"
	@echo ""
	@echo "Examples:"
	@echo "  make build NODE_VERSION=18"
	@echo "  make test NODE_VERSION=22"
	@echo "  make push REGISTRY=ghcr.io/username"