#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  echo "Skipping: Not in Claude Code remote environment"
  exit 0
fi

echo "🚀 Setting up development environment for Repeto..."

# Load tool versions from configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/../../.github/tool-versions.env"

if [ -f "$VERSIONS_FILE" ]; then
  # shellcheck source=../../.github/tool-versions.env
  source "$VERSIONS_FILE"
  echo "📌 Using pinned tool versions from .github/tool-versions.env"
else
  echo "⚠️  Version file not found at $VERSIONS_FILE, using latest versions"
fi

# Create bin directory for user-installed tools
mkdir -p ~/bin

# Add ~/bin to PATH for this session
export PATH="$HOME/bin:$PATH"

# Persist PATH for the session
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi

# Install shellcheck (Shell script linter, required by actionlint)
if ! command -v shellcheck &> /dev/null; then
  echo "📦 Installing shellcheck..."
  VERSION="${SHELLCHECK_VERSION:-$(curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')}"
  if [ -n "$VERSION" ]; then
    curl -sL "https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}.linux.x86_64.tar.xz" \
      | tar xJ -C /tmp
    mv "/tmp/shellcheck-v${VERSION}/shellcheck" ~/bin/
    rm -rf "/tmp/shellcheck-v${VERSION}"
    echo "✅ shellcheck v${VERSION} installed"
  else
    echo "⚠️  Failed to get shellcheck version"
  fi
else
  echo "✅ shellcheck already installed ($(shellcheck --version | grep '^version:' | awk '{print $2}'))"
fi

# Install actionlint (GitHub Actions linter)
if ! command -v actionlint &> /dev/null; then
  echo "📦 Installing actionlint..."
  VERSION="${ACTIONLINT_VERSION:-$(curl -s https://api.github.com/repos/rhysd/actionlint/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')}"
  if [ -n "$VERSION" ]; then
    curl -sL "https://github.com/rhysd/actionlint/releases/download/v${VERSION}/actionlint_${VERSION}_linux_amd64.tar.gz" \
      | tar xz -C ~/bin actionlint
    echo "✅ actionlint v${VERSION} installed"
  else
    echo "⚠️  Failed to get actionlint version"
  fi
else
  echo "✅ actionlint already installed ($(actionlint -version 2>&1 | head -n1))"
fi

# Install gh (GitHub CLI)
if ! command -v gh &> /dev/null; then
  echo "📦 Installing gh (GitHub CLI)..."
  VERSION="${GH_VERSION:-$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')}"
  if [ -n "$VERSION" ]; then
    cd /tmp
    curl -sL "https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz" \
      | tar xz
    mv "gh_${VERSION}_linux_amd64/bin/gh" ~/bin/
    rm -rf "gh_${VERSION}_linux_amd64"
    echo "✅ gh v${VERSION} installed"
  else
    echo "⚠️  Failed to get gh version"
  fi
else
  echo "✅ gh already installed ($(gh --version 2>&1 | head -n1))"
fi

# Verify Node.js/npm for markdownlint
if command -v node &> /dev/null; then
  CURRENT_NODE_VERSION=$(node --version | sed 's/^v//' | cut -d. -f1)
  EXPECTED_NODE_VERSION="${NODE_VERSION:-20}"

  if [ "$CURRENT_NODE_VERSION" = "$EXPECTED_NODE_VERSION" ]; then
    echo "✅ Node.js v${CURRENT_NODE_VERSION} (matches expected version)"
  else
    echo "⚠️  Node.js v${CURRENT_NODE_VERSION} (expected: v${EXPECTED_NODE_VERSION})"
    echo "   Markdownlint may behave differently than in CI"
  fi
else
  echo "⚠️  Node.js not found - markdownlint may not work"
fi

echo ""
echo "📋 Installed development tools:"
echo "  - shellcheck: $(shellcheck --version 2>&1 | grep '^version:' | awk '{print $2}' || echo 'not found')"
echo "  - actionlint: $(actionlint -version 2>&1 | head -n1 || echo 'not found')"
echo "  - gh: $(gh --version 2>&1 | head -n1 || echo 'not found')"
echo "  - Node.js: $(node --version 2>&1 || echo 'not found')"
echo "  - npm: $(npm --version 2>&1 || echo 'not found')"
echo ""
echo "✨ Development environment ready!"
echo ""
echo "Note: SwiftLint and Xcode tests are not available in Linux environment."
echo "These will run in CI on macOS runners."
