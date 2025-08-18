#!/bin/bash

set -e

REGISTRY=${REGISTRY:-""}
IMAGE_NAME=${IMAGE_NAME:-"nodejs-puppeteer"}
UBUNTU_VERSION=${UBUNTU_VERSION:-"22.04"}

NODE_VERSIONS=${NODE_VERSIONS:-"18 20 22"}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -n, --node-versions    Comma-separated list of Node versions (default: 18,20,22)"
    echo "  -r, --registry         Docker registry (optional)"
    echo "  -i, --image-name       Image name (default: nodejs-puppeteer)"
    echo "  -u, --ubuntu-version   Ubuntu version (default: 22.04)"
    echo "  -p, --push             Push images to registry"
    echo "  -h, --help             Show this help message"
}

PUSH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--node-versions)
            NODE_VERSIONS="${2//,/ }"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -i|--image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -u|--ubuntu-version)
            UBUNTU_VERSION="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

if [ -n "$REGISTRY" ]; then
    IMAGE_PREFIX="${REGISTRY}/"
else
    IMAGE_PREFIX=""
fi

echo "Building Docker images with:"
echo "  Ubuntu version: $UBUNTU_VERSION"
echo "  Node versions: $NODE_VERSIONS"
echo "  Image name: ${IMAGE_PREFIX}${IMAGE_NAME}"
echo ""

for NODE_VERSION in $NODE_VERSIONS; do
    TAG="${IMAGE_PREFIX}${IMAGE_NAME}:node${NODE_VERSION}-ubuntu${UBUNTU_VERSION}"
    LATEST_TAG="${IMAGE_PREFIX}${IMAGE_NAME}:node${NODE_VERSION}"
    
    echo "Building image for Node.js ${NODE_VERSION}..."
    echo "Tag: ${TAG}"
    
    docker build \
        --build-arg NODE_VERSION=${NODE_VERSION} \
        -t "${TAG}" \
        -t "${LATEST_TAG}" \
        -f "ubuntu${UBUNTU_VERSION}/Dockerfile" \
        .
    
    if [ "$PUSH" = true ] && [ -n "$REGISTRY" ]; then
        echo "Pushing ${TAG} to registry..."
        docker push "${TAG}"
        docker push "${LATEST_TAG}"
    fi
    
    echo "Successfully built ${TAG}"
    echo ""
done

echo "All images built successfully!"

if [ "$PUSH" = false ] || [ -z "$REGISTRY" ]; then
    echo ""
    echo "To push images to a registry, use:"
    echo "  $0 --push --registry <your-registry>"
fi