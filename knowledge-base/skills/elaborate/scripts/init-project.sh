#!/usr/bin/env bash
# Usage: init-project.sh <KB_ROOT> <project-name>

KB_ROOT="$1"
PROJECT="$2"
PROJECT_DIR="$KB_ROOT/projects/$PROJECT"

mkdir -p \
  "$PROJECT_DIR/context" \
  "$PROJECT_DIR/implementation/pending" \
  "$PROJECT_DIR/implementation/complete" || exit 1

cat > "$PROJECT_DIR/index.md" << EOF
# $PROJECT

## Intent

<!-- What is this and why does it exist -->

## Target Directory Structure

<!-- The actual codebase/infrastructure outcome -->

## Future Work

<!-- Known gaps and next steps -->
EOF

echo "Created: $PROJECT_DIR"
echo "  index.md"
echo "  context/"
echo "  implementation/pending/"
echo "  implementation/complete/"
