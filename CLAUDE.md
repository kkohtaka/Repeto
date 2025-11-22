# Claude Code Development Guidelines

## Pre-Commit Checklist

### 1. Code Quality Checks
- [ ] Verify SwiftLint shows zero errors
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
- [ ] Run SwiftLint: `swiftlint`
- [ ] Run tests: `xcodebuild test -scheme Repeto -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
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
```
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
```
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

```
feat(service): Implement interval calculation logic

Add logic to calculate next reminder date based on task interval:
- Support for daily, weekly, and monthly intervals
- Handle edge cases (month-end dates, leap years)
- Unit tests with 95% coverage

This completes the core calculation engine required for
task completion flow in Phase 2.

Related to #20
```

```
fix(core-data): Fix iCloud sync conflict resolution

Update merge policy to properly handle conflicts when multiple
devices modify the same task simultaneously. Changed from
NSMergeByPropertyStoreTrumpMergePolicy to
NSMergeByPropertyObjectTrumpMergePolicy to prioritize
in-memory changes.

Fixes #15
```

```
docs(dev-plan): Update Phase 1 completion status

Mark all Phase 1 tasks as completed:
- CI/CD pipeline setup
- Core Data schema implementation
- iCloud sync configuration
- Privacy policy publication

Updated README.md to reflect current development status.
```

### Bad Example
```
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
3. **`documentation/design.md`**
   - Data model changes
   - Architecture changes
   - UI/UX design changes

4. **`documentation/cicd-setup.md`**
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

## Important Notes
- Be cautious with Core Data model changes (migration required)
- Consider iCloud sync in implementation (offline support)
- Note the 64 notification limit
- Update docs/privacy.html when privacy policy changes
- **Always keep documentation in sync with code**

## SwiftLint Execution

### Local execution
```bash
# Check all files
swiftlint

# Auto-fix where possible
swiftlint --fix

# Check specific files
swiftlint lint --path Repeto/Services/
```

### CI/CD
- Automatically runs on all PRs via GitHub Actions
- Must pass before merge

## Testing

### Run all tests
```bash
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,OS=18.1,name=iPhone 17 Pro'
```

### Run specific test
```bash
xcodebuild test \
  -project Repeto.xcodeproj \
  -scheme Repeto \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:RepetoTests/TaskServiceTests
```

### Test coverage
- Target: 70%+
- Measured automatically in CI/CD (Phase 5)
