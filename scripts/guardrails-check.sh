#!/usr/bin/env bash
#
# guardrails-check.sh — UX/design guardrail checks (see CLAUDE.md section 4).
#
# Verifies that navigation/screen changes stay in sync with the documentation
# and flags interactive elements that are missing accessibility labels.
#
# Usage:
#   scripts/guardrails-check.sh --staged     # check staged changes (pre-commit hook)
#   scripts/guardrails-check.sh <base-ref>   # check <base-ref>...HEAD (CI)
#
# Exit status is non-zero when a blocking check fails. Advisory checks only
# print "::warning::" annotations and never fail the build.
#
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MODE="${1:---staged}"
TRANSITIONS="docs/transitions.mmd"
VIEWS_DIR="Repeto/Views"

# Collect changed files with status (Added/Copied/Deleted/Modified/Renamed).
if [ "$MODE" = "--staged" ]; then
  name_status="$(git diff --cached --name-status --diff-filter=ACDMR || true)"
else
  base="$MODE"
  if ! git rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then
    base="$(git rev-parse --verify --quiet HEAD~1 || true)"
  fi
  if [ -n "$base" ]; then
    name_status="$(git diff --name-status --diff-filter=ACDMR "${base}...HEAD" || true)"
  else
    name_status=""
  fi
fi

status=0

# A screen view is a top-level View; row/cell/item subviews are not screens.
is_screen_view() {
  case "$1" in
    "$VIEWS_DIR"/*RowView.swift | "$VIEWS_DIR"/*CellView.swift | "$VIEWS_DIR"/*ItemView.swift)
      return 1 ;;
    "$VIEWS_DIR"/*View.swift)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# --- Check A (blocking): every screen referenced in transitions.mmd exists ----
if [ -f "$TRANSITIONS" ]; then
  screens="$(grep -oE '[A-Z][A-Za-z0-9]*View' "$TRANSITIONS" | sort -u || true)"
  for screen in $screens; do
    if [ ! -f "$VIEWS_DIR/$screen.swift" ]; then
      echo "::error file=$TRANSITIONS::transitions.mmd references '$screen' but $VIEWS_DIR/$screen.swift does not exist (renamed or deleted screen?)."
      status=1
    fi
  done
fi

# --- Check C (blocking): screen add/remove/rename must update transitions.mmd -
screen_structural_change=0
transitions_touched=0
while IFS="$(printf '\t')" read -r st path new; do
  [ -z "${st:-}" ] && continue
  case "$st" in
    R*)
      if is_screen_view "$path" || { [ -n "${new:-}" ] && is_screen_view "$new"; }; then
        screen_structural_change=1
      fi
      ;;
    A | D)
      if is_screen_view "$path"; then
        screen_structural_change=1
      fi
      ;;
  esac
  if [ "$path" = "$TRANSITIONS" ] || [ "${new:-}" = "$TRANSITIONS" ]; then
    transitions_touched=1
  fi
done <<EOF
$name_status
EOF

if [ "$screen_structural_change" = "1" ] && [ "$transitions_touched" = "0" ]; then
  echo "::error file=$TRANSITIONS::A screen View was added/removed/renamed but $TRANSITIONS was not updated in the same change (CLAUDE.md section 4)."
  status=1
fi

# --- Check B (advisory): changed views missing accessibilityLabel -------------
changed_views="$(printf '%s\n' "$name_status" | awk -F"$(printf '\t')" '$1 !~ /^D/ {print $NF}' | grep -E "^$VIEWS_DIR/.*\.swift$" || true)"
for view in $changed_views; do
  [ -f "$view" ] || continue
  if grep -qE 'Image\(systemName:|onTapGesture' "$view" && ! grep -q 'accessibilityLabel' "$view"; then
    echo "::warning file=$view::Interactive/icon element without accessibilityLabel; add one for VoiceOver (CLAUDE.md section 3)."
  fi
done

if [ "$status" -ne 0 ]; then
  echo "Guardrail checks failed. See messages above and CLAUDE.md section 4." >&2
fi

exit "$status"
