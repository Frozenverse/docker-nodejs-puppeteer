# Docker Node.js Puppeteer

Docker images with Node.js and Puppeteer (Chromium) dependencies for web automation and testing.

## Features

- Multiple Node.js versions (18, 20, 22)
- Pre-installed Puppeteer dependencies
- Optimized Docker layers for faster builds
- Non-root user for security
- Multi-architecture support (amd64, arm64)
- Automated builds via GitHub Actions

## Quick Start

### Using Docker Compose

```bash
# Build and run Node.js 20 container
docker-compose up node20

# Run specific Node version
docker-compose run node18 node --version
docker-compose run node22 npm --version
```

### Using Make

```bash
# Build single version
make build NODE_VERSION=20

# Build all versions
make build-all

# Test an image
make test NODE_VERSION=18

# Run interactive shell
make shell NODE_VERSION=22
```

### Using Build Script

```bash
# Build all default versions
./build.sh

# Build specific versions
./build.sh --node-versions "18,20"

# Build and push to registry
./build.sh --push --registry ghcr.io/yourusername
```

## Docker Image Tags

Images are tagged with the following convention:
- `nodejs-puppeteer:node18-ubuntu22.04` - Full version tag
- `nodejs-puppeteer:node18` - Short version tag
- `nodejs-puppeteer:node20-ubuntu22.04`
- `nodejs-puppeteer:node20`
- `nodejs-puppeteer:node22-ubuntu22.04`
- `nodejs-puppeteer:node22`

## Usage Examples

### Running Puppeteer Scripts

```bash
# Create a test script
cat > test.js <<'EOF'
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();
  await page.goto('https://example.com');
  const title = await page.title();
  console.log('Page title:', title);
  await browser.close();
})();
EOF

# Run with Docker
docker run --rm -v $(pwd):/app nodejs-puppeteer:node20 sh -c "npm init -y && npm install puppeteer && node test.js"
```

### Development Environment

```bash
# Start interactive development container
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  nodejs-puppeteer:node20 \
  /bin/bash

# Inside container
npm init -y
npm install puppeteer
node your-script.js
```

## GitHub Actions

The repository includes automated builds that:
- Build images for all Node.js versions on push to main
- Test images in pull requests
- Push to GitHub Container Registry on tagged releases
- Support multi-platform builds (linux/amd64, linux/arm64)

## Configuration

### versions.json

Configure available versions in `versions.json`:

```json
{
  "node_versions": ["18", "20", "22"],
  "ubuntu_versions": ["22.04"],
  "default_node": "20",
  "default_ubuntu": "22.04"
}
```

### Environment Variables

- `NODE_VERSION` - Node.js version to build (default: 20)
- `UBUNTU_VERSION` - Ubuntu base image version (default: 22.04)
- `REGISTRY` - Docker registry for pushing images
- `IMAGE_NAME` - Docker image name (default: nodejs-puppeteer)

## Security

- Images run with a non-root user (`pptruser`) for better security
- Puppeteer runs with `--no-sandbox` flag in the container environment
- Regular security updates via GitHub Actions

## Troubleshooting

### Chrome/Chromium crashes

Add these flags when launching Puppeteer:

```javascript
const browser = await puppeteer.launch({
  headless: 'new',
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-gpu'
  ]
});
```

### Permission issues

The container runs as non-root user. Ensure mounted volumes have appropriate permissions:

```bash
# Fix permissions for mounted directory
docker run --rm -v $(pwd):/workspace nodejs-puppeteer:node20 \
  sh -c "sudo chown -R pptruser:pptruser /workspace"
```

## License

See [LICENSE](LICENSE) file for details.
