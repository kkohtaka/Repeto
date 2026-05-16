# iOS Project Guidelines for AI Agents

You are a senior iOS engineer on this project. Follow these guidelines strictly.

## 1. Technology Stack and Core Principles

- **Language / OS**: Swift 6.2+, targeting iOS 17.0+.
- **UI Framework**: Prefer SwiftUI. Avoid UIKit unless explicitly instructed.
- **Architecture**: MVVM using the `@Observable` macro. Keep Views lightweight; concentrate business logic in ViewModels.
- **Concurrency**: Use `async/await` and structured concurrency. Do not use completion handler–based APIs.

## 2. File Operations and Project Integrity

### No Direct Editing of `.pbxproj`

Never manually edit the `.pbxproj` file inside `.xcodeproj`. Direct edits by agents carry an extremely high risk of corruption and are strictly forbidden.

### Manage the Project with XcodeGen

This project uses **XcodeGen** to auto-generate `Repeto.xcodeproj` from `project.yml`.
`Repeto.xcodeproj` is excluded from Git — do not commit it.

After adding, deleting, or renaming any file, run the following command from the project root to regenerate the project file:

```bash
xcodegen generate
```

### Setup (after fresh clone)

```bash
brew install xcodegen
xcodegen generate
```

### Adding New Files

Create files in the appropriate directory, then regenerate:

```bash
# Create a new view
touch Repeto/Views/NewView.swift

# Regenerate the Xcode project
xcodegen generate
```

### Changing Build Settings

Edit `project.yml` (the single source of truth), then regenerate:

```bash
xcodegen generate
```

## 3. UX/UI Design and Design Token Enforcement

### Use Semantic Tokens

Hardcoding raw numeric values directly into `Color` or `.padding()` is forbidden.

Always use the design tokens defined in `TOKENS.md` (e.g., `.designSystem(.spacing(.md))`) to ensure design consistency and accessibility.

### Accessibility

All interactive elements must have appropriate `accessibilityLabel` values. Support Dynamic Type and Dark Mode by default.

## 4. Automated Validation Workflow (XcodeBuildMCP)

### Build and Test

After any code change, run a simulator build via XcodeBuildMCP to confirm there are no compile errors.

Write unit tests using Swift Testing for new logic, and verify they pass with a simulator test run before reporting completion.

Use XcodeBuildMCP tools (MCP server: `xcodebuildmcp`) instead of xcodebuild CLI directly.

| Operation | MCP Tool |
| --- | --- |
| List simulators | `simulator-management:list` |
| Build | `simulator:build` (scheme: Repeto) |
| Run all tests | `simulator:test` (scheme: Repeto) |
| Build & launch app | `simulator:build-and-run` (scheme: Repeto) |
| Clean build products | `utilities:clean` |
| Code coverage report | `coverage:get-coverage-report` |
| Discover project | `project-discovery:discover-projects` |
| List schemes | `project-discovery:list-schemes` |

For UI automation (screenshots, taps, etc.), use the `ui-automation:*` tools.

### Documentation Sync

#### Navigation and Screen Changes

When making any of the following changes, update `docs/transitions.mmd` **in the same commit**. Omissions are also detected by the Git pre-commit hook.

| Type of change | Example |
|---|---|
| Add a new screen (View) | Create `FooView.swift` |
| Delete or rename an existing screen | Delete / rename `BarView.swift` |
| Add, change, or remove navigation between screens | Add a transition trigger, change `NavigationLink` / `sheet` / phase transition |
| Change a trigger label | Change button label text |

If documentation updates are not required (e.g., style fixes, bug fixes, test additions), state so in the commit message.

#### Other Documentation

**Always update when tasks are completed:**

1. **`documentation/development-plan.md`** — Change task status from `[ ]` to `[x]`
2. **`README.md`** — Update "Development Status" section

**Update when design changes:**

1. **`documentation/design.md`** — Data model, architecture, UI/UX changes
2. **`documentation/cicd-setup.md`** — GitHub Actions, secrets, build/deployment changes

## 5. UI Asset Generation

### Policy

App icons and other image assets are generated via **Swift scripts using AppKit**, rather than relying on external tools or manual work. This keeps assets manageable as code and makes design changes easy.

### Steps

1. **Create the script**: Place Swift scripts under the `scripts/` directory.
   - Create a bitmap context with `NSBitmapImageRep` and set it as `NSGraphicsContext.current` to avoid unintended Retina scaling (@2x).
   - Use `NSBezierPath`, `NSColor`, and `NSString.draw(in:withAttributes:)` for drawing.
   - Output to the appropriate `appiconset` or `imageset` under `Repeto/Assets.xcassets/`.

2. **Specify pixel dimensions explicitly**: Use `NSBitmapImageRep(pixelsWide:pixelsHigh:...)` instead of `NSImage(size:)` to target exact pixel counts (`NSImage` renders at @2x resolution on Retina displays).

3. **Run the script to update assets** from the project root:
   ```bash
   swift scripts/generate_icon.swift
   ```

4. **Regenerate the project with XcodeGen** after adding or modifying `.xcassets`:
   ```bash
   xcodegen generate
   ```

5. **Verify with a build**: Use XcodeBuildMCP to confirm there are no compile errors.

### Consistency with Design Tokens

Colors and sizes used in scripts must match the token values (numeric) defined in `TOKENS.md`. For example, define constants for the accent color (#007AFF) and corner radii so that design changes can be applied in a single place.

### Reference Implementation

| Script | Generated asset | Output path |
|---|---|---|
| `scripts/generate_icon.swift` | App icon 1024×1024 | `Repeto/Assets.xcassets/AppIcon.appiconset/AppIcon.png` |

## 6. Installing to a Physical Device

### Prerequisites

All of the following must be in place before installing to a device. If anything is missing, ask a human engineer.

- Apple Developer Program membership
- Latest Program License Agreement accepted at [developer.apple.com](https://developer.apple.com/account)
- Correct Team ID set in `DEVELOPMENT_TEAM` inside `project.yml`
- An `Apple Development` certificate created in Xcode under **Settings → Accounts → Manage Certificates**

### Find the Device ID

```bash
xcrun devicectl list devices
```

Use the `Identifier` value (UUID format) of the device showing `State: connected`. Note that the destination ID required by `xcodebuild` may differ; confirm with:

```bash
xcodebuild -project Repeto.xcodeproj -scheme Repeto -showdestinations 2>/dev/null | grep 'platform:iOS,'
```

### Build

```bash
xcodebuild \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'id=<DEVICE_ID>' \
  -allowProvisioningUpdates \
  build
```

### Install

```bash
APP_PATH=$(xcodebuild \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'id=<DEVICE_ID>' \
  -showBuildSettings 2>/dev/null | grep 'CODESIGNING_FOLDER_PATH' | awk '{print $3}')

xcrun devicectl device install app \
  --device <DEVICE_ID> \
  "$APP_PATH"
```

### Launch

```bash
xcrun devicectl device process launch \
  --device <DEVICE_ID> \
  <BUNDLE_ID>
```

## 7. Approval Flow and Planning

### Present an Implementation Plan Before Starting

Before beginning any work, present an **implementation plan** covering the following and obtain approval from a human engineer:

- List of files to be modified or added
- Overview of the architecture and logic to be adopted
- Test cases to be added and verified

### Responding to Feedback

If a build error or test failure occurs, analyze the root cause and attempt to fix it autonomously. Only escalate to a human when the fix is beyond your capability.

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
- [ ] Run tests: XcodeBuildMCP `simulator:test` (scheme: Repeto)
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
- Coverage target: 70%+

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

## Common Workflows

### Adding New Features

1. Create/verify issue
2. Create branch: `claude/feature-name-{session-id}`
3. Present implementation plan and obtain approval (see Section 7)
4. Implementation (including tests)
5. Run SwiftLint + tests
6. **Update documentation (development-plan.md, README.md)**
7. Commit & push
8. Create PR

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
