# Claude Code Development Guidelines

## Pre-Commit Checklist

### 1. Code Quality Checks

- [ ] Verify SwiftLint shows zero errors
- [ ] Verify markdownlint shows zero errors (for Markdown changes)
- [ ] Verify actionlint shows zero errors (for workflow changes)
- [ ] Confirm build succeeds (Simulator)
- [ ] Verify all existing tests pass

### 2. New Code Requirements

- [ ] Add unit tests for new logic
- [ ] Add documentation comments for public APIs
- [ ] Consider migration strategy for Core Data model changes

### 3. Documentation Updates

- [ ] **Update development status in README.md**
- [ ] **Update task checklist in `documentation/development-plan.md`**
- [ ] Update design.md for significant design changes
- [ ] Update cicd-setup.md for CI/CD configuration changes

### 4. Pre-Commit/Push

- [ ] Run linters:
  - SwiftLint: `swiftlint`
  - Markdownlint (if Markdown changed): `npx markdownlint-cli2 "**/*.md"`
  - Actionlint (if workflows changed): `actionlint`
- [ ] Run tests: `xcodebuild test -scheme Repeto -destination 'platform=iOS Simulator,name=Any iOS Simulator Device'`
- [ ] Update CLAUDE.md if needed (for significant changes)
- [ ] **Write commit message in Conventional Commits format (English)**

### 5. Pull Request Creation

- [ ] Provide clear summary of changes
- [ ] Add screenshots for UI changes
- [ ] Reference related issues

## Coding Standards

### Swift

- Indentation: 4 spaces
- Naming: lowerCamelCase (variables/functions), UpperCamelCase (types)
- Access control: Principle of least privilege (private > fileprivate > internal > public)
- Keep SwiftUI views small (aim for under 50 lines)

### Project Structure

```text
Repeto/
├── App/           # Application entry point
├── Models/        # Data models & Core Data
├── Views/         # SwiftUI Views
├── ViewModels/    # MVVM ViewModels
├── Services/      # Business logic
└── Resources/     # Assets
```

### Testing

- Unit tests: `RepetoTests/`
- UI tests: `RepetoUITests/`
- Coverage target: 70%+

## Xcode File Management

### Automatic File Synchronization

This project uses **PBXFileSystemSynchronizedRootGroup** (Xcode 14+), which provides automatic file detection:

- ✅ **No manual project.pbxproj editing** needed for Swift files
- ✅ **Files are auto-detected** from the filesystem
- ✅ **Fewer merge conflicts** in Git
- ✅ **Simpler workflow**: Just add files to the correct directory

### Adding New Files

Simply create files in the appropriate directory:

```bash
# Create a new view
touch Repeto/Views/NewView.swift

# Create a new model extension
touch Repeto/Models/NewModel+Extension.swift
```

Xcode will automatically:

- Detect the new file
- Include it in the build
- Make it available for import

### Important Notes

- ⚠️ **Don't manually edit** project.pbxproj for file additions
- ⚠️ **Use Xcode** if you need special build settings
- ⚠️ **Resources** (images, plists) may still need manual configuration
- ✅ **Swift files** in standard directories are auto-detected

## Commit Message Guidelines

### Format

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### Types and Scopes

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`

**Scopes (optional):** `core-data`, `ui`, `service`, `viewmodel`, `workflow`, `docs`

### Writing Rules

1. **Subject**: Max 50 chars, imperative mood, no period
2. **Body**: Wrap at 72 chars, explain **why** not what, use bullet points
3. **Footer**: Note breaking changes, reference issues (`Closes #123`)

### Example

```text
feat(service): Implement interval calculation logic

Add logic to calculate next reminder date based on task interval:
- Support for daily, weekly, and monthly intervals
- Handle edge cases (month-end dates, leap years)
- Unit tests with 95% coverage

Related to #20
```

**Note:** When using Squash & Merge, commit messages become PR title and description.

## Documentation Management

### Documents to Update

**Always update when tasks are completed:**

1. **`documentation/development-plan.md`** - Change task status from `[ ]` to `[x]`
2. **`README.md`** - Update "Development Status" section

**Update when design changes:**

1. **`documentation/design.md`** - Data model, architecture, UI/UX changes
2. **`documentation/cicd-setup.md`** - GitHub Actions, secrets, build/deployment changes

## Common Workflows

### Adding New Features

1. Create/verify issue
2. Create branch: `claude/feature-name-{session-id}`
3. Implementation (including tests)
4. Run SwiftLint + tests
5. **Update documentation (development-plan.md, README.md)**
6. Commit & push
7. Create PR

### Bug Fixes

1. Reproduce the issue
2. Add test case (verify reproduction)
3. Implement fix
4. Verify tests pass
5. **Update documentation if needed**
6. Commit & push

### Testing PR Changes with Firebase App Distribution

1. Create PR as usual
2. Add `firebase-preview` label to PR
3. GitHub Actions automatically builds Ad Hoc IPA and uploads to Firebase
4. Share the build with testers for early feedback
5. Remove label if no longer needed (stops automatic builds)

**Note:** Testers must have their device UDIDs registered in the Ad Hoc provisioning profile.

## Firebase App Distribution (PR Preview Builds)

### Overview

PRs with the `firebase-preview` label automatically trigger Ad Hoc builds that are distributed
via Firebase App Distribution. This allows testers to try changes before merging to main.

### Workflow

1. Create a PR
2. Add the `firebase-preview` label
3. GitHub Actions runs automatically:
   - Builds Ad Hoc IPA (macOS runner)
   - Uploads to Firebase App Distribution (Linux runner)
   - Posts distribution info as PR comment
4. Testers receive email notification
5. Testers download and test the build

### Build Numbers

- **Firebase (PR)**: `2000000 + PR number` (e.g., PR #42 → `2000042`)
- **TestFlight (Release)**: `github.run_number` (unchanged)

This ensures no conflicts between PR preview builds and official releases.

### Version String

Format: `{marketing_version}-pr.{pr_number}`

Example: `1.0.0-pr.42`

### Adding Testers

To add a new tester:

1. Obtain tester's device UDID
2. Register device in Apple Developer Portal
3. Update Ad Hoc provisioning profile to include new device
4. Download updated profile and Base64 encode it
5. Update GitHub Secret `APPLE_ADHOC_PROVISION_PROFILE_BASE64`
6. Trigger new build (profile change takes effect)

### Required GitHub Secrets

See `documentation/cicd-setup.md` for detailed information.

**Firebase Authentication (Workload Identity Federation):**

- `FIREBASE_APP_ID`
- `WIF_PROVIDER`
- `WIF_SERVICE_ACCOUNT`

**Apple Code Signing (Ad Hoc):**

- `APPLE_ADHOC_CERTIFICATE_BASE64`
- `APPLE_ADHOC_CERTIFICATE_PASSWORD`
- `APPLE_ADHOC_PROVISION_PROFILE_BASE64`

## GitHub Operations (Claude Code on Web)

### Creating Pull Requests

**IMPORTANT**: Always use `curl` with GitHub REST API instead of `gh pr create`, as `gh` commands
may be restricted.

```bash
curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/kkohtaka/Repeto/pulls" \
  -d @- <<'EOF'
{
  "title": "feat(service): Add new feature",
  "head": "feature-branch-name",
  "base": "main",
  "body": "## Summary\n\nDetailed description...\n\n## Changes\n\n- Change 1\n- Change 2"
}
EOF
```

**Key fields:** `title` (required), `head` (required), `base` (required), `body` (optional)

### Managing Pull Requests

```bash
# Merge PR using squash method
curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/kkohtaka/Repeto/pulls/{PR_NUMBER}/merge" \
  -d '{"merge_method":"squash"}'

# Close PR without merging
curl -s -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/kkohtaka/Repeto/pulls/{PR_NUMBER}" \
  -d '{"state":"closed"}'
```

### Check Workflow Runs for a Branch

**IMPORTANT**: Due to environment variable expansion issues in Bash tool, use Python scripts
with subprocess to call curl for reliable GitHub API access.

```bash
python3 << 'PYEOF'
import os
import subprocess
import json

token = os.environ.get('GITHUB_TOKEN', '')

result = subprocess.run(
    ['curl', '-s', '-H', f'Authorization: token {token}',
     '-H', 'Accept: application/vnd.github.v3+json',
     'https://api.github.com/repos/kkohtaka/Repeto/actions/runs?branch=main&per_page=5'],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
runs = data.get('workflow_runs', [])
print(f"Found {len(runs)} workflow runs\n")
for run in runs:
    print(f"- {run['name']}: {run['status']} / {run.get('conclusion', 'running')}")
    print(f"  URL: {run['html_url']}")
PYEOF
```

**Response fields:**

- `status`: "queued", "in_progress", "completed"
- `conclusion`: "success", "failure", "cancelled", "skipped"
- `html_url`: Link to workflow run on GitHub

**For detailed job analysis**, replace the API endpoint with:

- `/actions/runs/{run_id}` - Specific workflow run
- `/actions/runs/{run_id}/jobs` - Jobs and failed steps
- `/pulls/{pr_number}` - PR status and mergeability

**Common errors:**

- `401 Unauthorized`: Token missing or expired
- `403 Forbidden`: Token lacks required permissions
- `404 Not Found`: Repository, branch, or run doesn't exist

## Git Operations

### Git Push

- Always use `git push -u origin <branch-name>`
- Branch must start with 'claude/' and end with matching session id
- Retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s) on network errors

### Git Fetch/Pull

- Prefer fetching specific branches: `git fetch origin <branch-name>`
- Retry up to 4 times with exponential backoff on network failures

## Important Notes

- Be cautious with Core Data model changes (migration required)
- Consider iCloud sync in implementation (offline support)
- Note the 64 notification limit
- Update docs/privacy.html when privacy policy changes
- **Always keep documentation in sync with code**

## SessionStart Hook (Claude Code on Web)

When working in Claude Code on the web, the SessionStart hook automatically sets up
development tools:

- **shellcheck** - Shell script linter (required by actionlint)
- **actionlint** - GitHub Actions linter
- **gh** - GitHub CLI
- **npx** - For markdownlint

**Note**: SwiftLint/Xcode are not available in Linux environment (run in CI)

## Linters

### SwiftLint

```bash
swiftlint                           # Check all files
swiftlint --fix                     # Auto-fix where possible
swiftlint lint --path Repeto/Services/  # Check specific files
```

### Markdownlint

```bash
npx markdownlint-cli2 "**/*.md"     # Check all Markdown files
npx markdownlint-cli2 --fix "**/*.md"  # Auto-fix where possible
```

**Configuration:** `.markdownlint.json`

### Actionlint

```bash
actionlint                          # Check all workflow files
```

**CI/CD:** All linters automatically run on PRs via `.github/workflows/linters.yml`

## Testing

```bash
# List available simulators
xcrun simctl list devices available iOS

# Run all tests
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:RepetoTests/TaskServiceTests
```

## Dependency Management (Renovate)

Renovate Bot automatically manages dependency updates:

- **GitHub Actions** → PR labeled `github-actions`, commit prefix `chore(ci):`
- **Development tools** (.github/tool-versions.env) → PR labeled `tools`, commit prefix `chore(tools):`

**Setup:** See `documentation/cicd-setup.md` for configuration details

### Reviewing Renovate PRs

1. Check PR description for changes
2. Verify CI passes (linters and tests)
3. Review changelog for breaking changes
4. Merge if everything looks good
