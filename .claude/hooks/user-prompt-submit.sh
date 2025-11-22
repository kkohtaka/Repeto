#!/bin/bash

# This hook is triggered when user submits a prompt to Claude Code
# It helps ensure code quality by reminding about pre-commit checks

# Check if the prompt contains git commit or push keywords
if echo "$USER_PROMPT" | grep -iE "git (commit|push)|commit|push" > /dev/null 2>&1; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Pre-Commit/Push Checklist Reminder"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Before committing/pushing, please verify:"
    echo ""
    echo "1. ✓ Code Quality"
    echo "   → SwiftLint: swiftlint"
    echo "   → Build: xcodebuild build -scheme Repeto -destination 'platform=iOS Simulator,name=iPhone 17 Pro'"
    echo "   → Tests: xcodebuild test -scheme Repeto -destination 'platform=iOS Simulator,name=iPhone 17 Pro'"
    echo ""
    echo "2. ✓ Documentation"
    echo "   → Update README.md (development status)"
    echo "   → Update documentation/development-plan.md (task checklist)"
    echo ""
    echo "3. ✓ Commit Message"
    echo "   → Use Conventional Commits format (English)"
    echo "   → Format: <type>(<scope>): <subject>"
    echo "   → Example: feat(service): Add TaskService for CRUD operations"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "See CLAUDE.md for complete guidelines."
    echo ""

    # Return non-zero to pause and show the reminder
    # User can continue by confirming
    exit 1
fi

# Allow the prompt to proceed for non-git operations
exit 0
