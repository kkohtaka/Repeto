#!/usr/bin/env bash
#
# check-workflow-toolchain.sh — keeps the Xcode toolchain identical across every
# GitHub Actions workflow (see CLAUDE.md section 4).
#
# The version we test with must be the version we ship with. Enforced by three
# blocking rules:
#
#   1. XCODE_VERSION is defined in .github/tool-versions.env (single source of truth).
#   2. No workflow or action hardcodes an Xcode version (e.g. /Applications/Xcode_26.0.1.app)
#      or calls `xcode-select -s` directly.
#   3. Every macOS job that runs xcodebuild selects its toolchain through the
#      ./.github/actions/setup-xcode composite action.
#
# Usage:
#   scripts/check-workflow-toolchain.sh
#
# Exit status is non-zero when a rule is violated.
#
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

VERSIONS_FILE=".github/tool-versions.env"
WORKFLOWS_DIR=".github/workflows"
SETUP_ACTION="./.github/actions/setup-xcode"
SETUP_ACTION_FILE=".github/actions/setup-xcode/action.yml"

status=0

# --- Rule 1 (blocking): XCODE_VERSION is pinned in one place -----------------
if [ ! -f "$VERSIONS_FILE" ]; then
  echo "::error::$VERSIONS_FILE not found."
  exit 1
fi

xcode_version="$(grep -E '^XCODE_VERSION=' "$VERSIONS_FILE" | head -n 1 | cut -d= -f2- || true)"
if [ -z "$xcode_version" ]; then
  echo "::error file=$VERSIONS_FILE::XCODE_VERSION is not defined. Every macOS job pins its Xcode from this file."
  status=1
else
  echo "Pinned Xcode version: $xcode_version ($VERSIONS_FILE)"
fi

# Files that must never carry a version literal of their own.
scanned_files="$(
  {
    find "$WORKFLOWS_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null || true
    find ".github/actions" -type f \( -name 'action.yml' -o -name 'action.yaml' \) 2>/dev/null || true
  } | sort
)"

# --- Rule 2 (blocking): no hardcoded version, no direct xcode-select ---------
for file in $scanned_files; do
  while IFS=: read -r lineno _; do
    [ -z "${lineno:-}" ] && continue
    echo "::error file=$file,line=$lineno::Hardcoded Xcode version. Select the toolchain with 'uses: $SETUP_ACTION' and change the version in $VERSIONS_FILE instead."
    status=1
  done < <(grep -nE 'Xcode_[0-9]' "$file" || true)

  # The composite action is the one place allowed to switch the toolchain.
  [ "$file" = "$SETUP_ACTION_FILE" ] && continue

  while IFS=: read -r lineno _; do
    [ -z "${lineno:-}" ] && continue
    echo "::error file=$file,line=$lineno::Direct 'xcode-select -s' call. Use 'uses: $SETUP_ACTION' so every job shares one toolchain."
    status=1
  done < <(grep -nE 'xcode-select[[:space:]]+-s' "$file" || true)
done

# --- Rule 3 (blocking): macOS jobs building with xcodebuild use the action ---
# Emits one "<file>\t<job>\t<macos>\t<uses_xcodebuild>\t<uses_setup_action>" row
# per job. Jobs are the keys indented by exactly two spaces under "jobs:".
job_rows="$(
  for file in $scanned_files; do
    [[ "$file" == "$WORKFLOWS_DIR"/* ]] || continue
    awk -v file="$file" '
      function emit() {
        printf "%s\t%s\t%d\t%d\t%d\n", file, job, macos, xcodebuild, setup
      }
      /^jobs:[[:space:]]*$/ { in_jobs = 1; next }
      in_jobs && /^[^[:space:]#]/ { if (job != "") { emit(); job = "" } in_jobs = 0 }
      !in_jobs { next }
      /^  [A-Za-z0-9_-]+:[[:space:]]*$/ {
        if (job != "") emit()
        job = $1
        sub(/:$/, "", job)
        macos = 0; xcodebuild = 0; setup = 0
        next
      }
      job != "" {
        if ($0 ~ /runs-on:[[:space:]]*.*macos/) macos = 1
        if ($0 ~ /xcodebuild/) xcodebuild = 1
        if (index($0, "uses:") && index($0, "/.github/actions/setup-xcode")) setup = 1
      }
      END { if (job != "") emit() }
    ' "$file"
  done
)"

while IFS="$(printf '\t')" read -r file job macos xcodebuild setup; do
  [ -z "${file:-}" ] && continue
  if [ "$macos" = "1" ] && [ "$xcodebuild" = "1" ] && [ "$setup" = "0" ]; then
    echo "::error file=$file::Job '$job' runs xcodebuild on a macOS runner without 'uses: $SETUP_ACTION'; it would build with the runner's default Xcode and drift from the pinned version."
    status=1
  fi
done <<EOF
$job_rows
EOF

if [ "$status" -ne 0 ]; then
  echo "Toolchain consistency checks failed. See messages above and CLAUDE.md section 4." >&2
else
  echo "Toolchain consistency checks passed."
fi

exit "$status"
