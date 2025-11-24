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

## Commit Message Guidelines

### Format

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code formatting (no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependency updates, etc.)
- `ci`: CI/CD configuration changes

### Scope (Optional)

- `core-data`: Core Data related
- `ui`: UI/View related
- `service`: Service layer
- `viewmodel`: ViewModel layer
- `workflow`: GitHub Actions
- `docs`: Documentation

### Writing Rules

1. **Subject (First line)**
   - Maximum 50 characters
   - English, imperative mood ("Add" not "Added" or "Adds")
   - No period at the end
   - Example: `feat(service): Add TaskService for CRUD operations`

2. **Body (Message body)**
   - Leave one blank line after subject
   - Wrap at 72 characters
   - Explain **why** rather than **what**
   - Use bullet points (`-` or `*`) if needed
   - Write detailed description suitable for PR description

3. **Footer**
   - Note breaking changes if any
   - Reference issues: `Closes #123` or `Related to #123`

### Good Examples

```text
feat(service): Implement interval calculation logic

Add logic to calculate next reminder date based on task interval:
- Support for daily, weekly, and monthly intervals
- Handle edge cases (month-end dates, leap years)
- Unit tests with 95% coverage

This completes the core calculation engine required for
task completion flow in Phase 2.

Related to #20
```

```text
fix(core-data): Fix iCloud sync conflict resolution

Update merge policy to properly handle conflicts when multiple
devices modify the same task simultaneously. Changed from
NSMergeByPropertyStoreTrumpMergePolicy to
NSMergeByPropertyObjectTrumpMergePolicy to prioritize
in-memory changes.

Fixes #15
```

```text
docs(dev-plan): Update Phase 1 completion status

Mark all Phase 1 tasks as completed:
- CI/CD pipeline setup
- Core Data schema implementation
- iCloud sync configuration
- Privacy policy publication

Updated README.md to reflect current development status.
```

### Bad Example

```text
update files
```

(Unclear what changed, cannot be used as PR description)

### GitHub PR Creation

- When using Squash & Merge, commit messages become PR title and description
- For multiple commits, use the most important change as title and summarize each commit in body

## Documentation Management

### Documents to Update

#### Always update when tasks are completed

1. **`documentation/development-plan.md`**
   - Change task status from `[ ]` to `[x]`
   - Add new tasks if discovered

2. **`README.md`**
   - Update "Development Status" section
   - Note when phases are completed

#### Update when design changes

1. **`documentation/design.md`**
   - Data model changes
   - Architecture changes
   - UI/UX design changes

2. **`documentation/cicd-setup.md`**
   - GitHub Actions configuration changes
   - New secrets added
   - Build/deployment procedure changes

### Documentation Update Examples

**When completing tasks:**

```diff
# development-plan.md
### Phase 2: Core Feature Implementation
- [ ] TaskService implementation (CRUD operations)
+ - [x] TaskService implementation (CRUD operations)
- [ ] Interval calculation logic
+ - [x] Interval calculation logic
```

```diff
# README.md
## Development Status

- Currently preparing iOS development.
+ ### Phase 1: Project Foundation ✅ Completed
+ ### Phase 2: Core Feature Implementation (In Progress)
+ - [x] TaskService implementation
+ - [x] Interval calculation logic
+ - [ ] Task completion handling
```

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

### Milestone Completion

1. Verify all tasks are completed
2. **Update Phase status in development-plan.md**
3. **Update development status in README.md**
4. Create release notes (if applicable)

## Checking CI Status (Claude Code on Web)

When working in Claude Code on the web, the GitHub CLI (`gh`) is automatically installed
via the SessionStart hook. You can use `gh` commands or the GitHub REST API with `curl`
to check CI status.

### Prerequisites

Ensure `GITHUB_TOKEN` is set in the environment:

```bash
env | grep GITHUB_TOKEN
```

### Check Workflow Runs for a Branch

```bash
# List recent workflow runs for a specific branch
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/{owner}/{repo}/actions/runs?branch={branch-name}&per_page=5"

# Example for this repo
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/kkohtaka/Repeto/actions/runs?branch=main&per_page=5"
```

**Key fields in response:**

- `status`: "queued", "in_progress", "completed"
- `conclusion`: "success", "failure", "cancelled", "skipped" (only when status is "completed")
- `name`: Workflow name (e.g., "Linters", "CI - Build and Test")
- `html_url`: Link to workflow run on GitHub

### Check Specific Workflow Run

```bash
# Get details of a specific workflow run by ID
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}"
```

### Check All Workflows for a Commit

```bash
# Check combined status for a specific commit
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/{owner}/{repo}/commits/{commit_sha}/status"
```

### Check PR Status

```bash
# Get PR details including CI status
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
```

**Key fields for merge readiness:**

- `mergeable`: true/false (can the PR be merged)
- `mergeable_state`: "clean", "unstable", "dirty", "blocked"
- `state`: "open", "closed"

### Practical Examples

**Wait for CI to complete:**

```bash
# Check every 30 seconds until workflow completes
while true; do
  STATUS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/kkohtaka/Repeto/actions/runs/{run_id}" \
    | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

  if [ "$STATUS" = "completed" ]; then
    echo "Workflow completed!"
    break
  fi
  echo "Status: $STATUS - waiting..."
  sleep 30
done
```

**Check if all workflows passed:**

```bash
# List latest runs and check conclusions
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/kkohtaka/Repeto/actions/runs?branch=main&per_page=5" \
  | python3 -c "import sys, json; runs = json.load(sys.stdin)['workflow_runs']; \
    [print(f\"{r['name']}: {r['status']} ({r.get('conclusion', 'running')})\") for r in runs]"
```

### Common Workflow States

| Status | Conclusion | Meaning |
| ------ | ---------- | ------- |
| `queued` | - | Workflow is waiting to start |
| `in_progress` | - | Workflow is currently running |
| `completed` | `success` | ✅ All jobs passed |
| `completed` | `failure` | ❌ At least one job failed |
| `completed` | `cancelled` | ⚠️ Workflow was cancelled |
| `completed` | `skipped` | ⏭️ Workflow was skipped |

### Troubleshooting

**401 Unauthorized:**

- Token is missing or expired
- Check: `echo $GITHUB_TOKEN`

**403 Forbidden:**

- Token lacks required permissions
- Need `repo` scope for private repos
- Need `actions:read` for workflow access

**404 Not Found:**

- Repository, branch, or run doesn't exist
- Check branch name and repository path

## Important Notes

- Be cautious with Core Data model changes (migration required)
- Consider iCloud sync in implementation (offline support)
- Note the 64 notification limit
- Update docs/privacy.html when privacy policy changes
- **Always keep documentation in sync with code**

## SessionStart Hook (Claude Code on Web)

When working in Claude Code on the web, the SessionStart hook automatically sets up
development tools.

### Installed Tools

- **shellcheck** - Shell script linter (required by actionlint)
- **actionlint** - GitHub Actions linter
- **gh** - GitHub CLI
- **npx** - For markdownlint (verification only)

**Note**: SwiftLint/Xcode are not available in Linux environment (run in CI)

### Customization

Edit `.claude/hooks/session-start.sh` when you need to add new tools.

## Linters

### SwiftLint (Swift Code Quality)

**Local execution:**

```bash
# Check all files
swiftlint

# Auto-fix where possible
swiftlint --fix

# Check specific files
swiftlint lint --path Repeto/Services/
```

### Markdownlint (Markdown Files)

**Local execution:**

```bash
# Check all Markdown files
npx markdownlint-cli2 "**/*.md"

# Auto-fix where possible
npx markdownlint-cli2 --fix "**/*.md"
```

**Configuration:** `.markdownlint.json`

### Actionlint (GitHub Actions Workflows)

**Local execution:**

```bash
# Install (if not already installed)
brew install actionlint

# Check all workflow files
actionlint
```

### CI/CD

- All linters automatically run on all PRs via GitHub Actions (`.github/workflows/linters.yml`)
- Must pass before merge

## Testing

### Check available simulators

```bash
xcrun simctl list devices available iOS
```

### Run all tests

```bash
# Using any available iOS simulator
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use the first available simulator dynamically
SIMULATOR=$(xcrun simctl list devices available iOS | grep -m 1 "iPhone" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}')
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination "platform=iOS Simulator,id=$SIMULATOR"
```

### Run specific test

```bash
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:RepetoTests/TaskServiceTests
```

### Test coverage

- Target: 70%+
- Measured automatically in CI/CD (Phase 5)
