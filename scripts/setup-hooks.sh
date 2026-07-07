#!/usr/bin/env bash
#
# setup-hooks.sh — point git at the repo's tracked hooks in .githooks/.
# Run once after cloning.
#
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath .githooks
echo "✅ core.hooksPath set to .githooks (pre-commit guardrail checks enabled)"
