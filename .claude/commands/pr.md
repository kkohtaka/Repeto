Create a pull request for the current branch using the project PR template.

## Steps

### 1. Gather branch information

Run these in parallel:
- `git status` — confirm working tree is clean (warn if dirty)
- `git log main..HEAD --oneline` — list commits on this branch
- `git diff main...HEAD --stat` — summarize changed files
- `git diff main...HEAD` — full diff for content analysis

### 2. Run pre-commit checks

Run these in parallel and report any failures before proceeding:
- SwiftLint: `swiftlint` — must show 0 violations
- Markdownlint (if any `.md` files changed): `npx markdownlint-cli2 "**/*.md"` — must show 0 errors
- Actionlint (if any `.github/workflows/*.yml` files changed): `actionlint` — must show 0 errors

If XcodeBuildMCP is available (check session defaults first with `session_show_defaults`):
- Build: `simulator:build` (scheme: Repeto)
- Tests: `simulator:test` (scheme: Repeto)

**Do not create the PR if any check fails.** Fix the issues first, then re-run.

### 3. Fill in the PR template

Read `.github/pull_request_template.md`, then fill each section based on the diff and commits:

**Summary**: One concise paragraph or 2–4 bullet points. Capture *what* changed and *why* — not a list of files.

**Changes**: Significant changes grouped by area (Views, ViewModels, Services, CI, docs, etc.). Omit the section if changes are trivial (e.g., a single-line fix).

**Background**: Include only if the motivation is non-obvious — e.g., a CI constraint, a design decision, a referenced issue. Delete the section otherwise.

**Test plan**: Check off items that were actually verified. Remove items that are not applicable (e.g., no new logic → no new unit tests required).

**Documentation**: Check off each documentation file that was updated. Remove the entire section if no documentation was required.

**Screenshots**: Include if any SwiftUI views changed. If not applicable, remove the section.

### 4. Determine PR metadata

- **Title**: Follow Conventional Commits — `<type>(<scope>): <subject>` (max 70 chars, imperative mood, no trailing period).
- **Base branch**: `main`
- **Draft**: Use draft if the branch is not yet ready for review (ask the user if unclear).
- **Labels**: Add `firebase-preview` only if the user explicitly requests a Firebase preview build.

### 5. Create the PR

Use `gh pr create` with `--title` and `--body` flags. Pass the body via a heredoc to preserve formatting.

If `gh` is unavailable (e.g., Claude Code on Web), use the GitHub REST API via `curl` as documented in CLAUDE.md under "GitHub Operations".

After creation, output the PR URL so the user can open it directly.

### 6. Post-creation reminder

Remind the user of any items in the Test plan or Documentation sections that were left unchecked — those still need manual action.
