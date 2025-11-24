#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  echo "Skipping: Not in Claude Code remote environment"
  exit 0
fi

echo "🚀 Setting up development environment for Repeto..."

# Create bin directory for user-installed tools
mkdir -p ~/bin

# Add ~/bin to PATH for this session
export PATH="$HOME/bin:$PATH"

# Persist PATH for the session
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi

# Install actionlint (GitHub Actions linter)
if ! command -v actionlint &> /dev/null; then
  echo "📦 Installing actionlint..."
  ACTIONLINT_VERSION=$(curl -s https://api.github.com/repos/rhysd/actionlint/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
  if [ -n "$ACTIONLINT_VERSION" ]; then
    curl -sL "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
      | tar xz -C ~/bin actionlint
    echo "✅ actionlint v${ACTIONLINT_VERSION} installed"
  else
    echo "⚠️  Failed to get actionlint version"
  fi
else
  echo "✅ actionlint already installed ($(actionlint -version 2>&1 | head -n1))"
fi

# Install gh (GitHub CLI)
if ! command -v gh &> /dev/null; then
  echo "📦 Installing gh (GitHub CLI)..."
  GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
  if [ -n "$GH_VERSION" ]; then
    cd /tmp
    curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
      | tar xz
    mv "gh_${GH_VERSION}_linux_amd64/bin/gh" ~/bin/
    rm -rf "gh_${GH_VERSION}_linux_amd64"
    echo "✅ gh v${GH_VERSION} installed"
  else
    echo "⚠️  Failed to get gh version"
  fi
else
  echo "✅ gh already installed ($(gh --version 2>&1 | head -n1))"
fi

# Verify Node.js/npm for markdownlint
if command -v npx &> /dev/null; then
  echo "✅ npx available for markdownlint-cli2"
else
  echo "⚠️  npx not found - markdownlint may not work"
fi

echo ""
echo "📋 Installed development tools:"
echo "  - actionlint: $(actionlint -version 2>&1 | head -n1 || echo 'not found')"
echo "  - gh: $(gh --version 2>&1 | head -n1 || echo 'not found')"
echo "  - npx: $(npx --version 2>&1 || echo 'not found')"
echo ""
echo "✨ Development environment ready!"
echo ""
echo "Note: SwiftLint and Xcode tests are not available in Linux environment."
echo "These will run in CI on macOS runners."
