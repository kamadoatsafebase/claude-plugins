#!/usr/bin/env bash

PROJECTS="${1}/projects"

if [ ! -d "$PROJECTS" ]; then
  echo "KB projects directory not found. Run: mkdir -p ${1}/projects ${1}/completed-projects"
  exit 1
fi

found=0
while IFS= read -r project_dir; do
  project_name=$(basename "$project_dir")
  step_files=()
  while IFS= read -r f; do
    step_files+=("$f")
  done < <(find "$project_dir/implementation/pending" -maxdepth 1 -name 'step-*.md' 2>/dev/null | sort -V)
  echo "$project_name  (${#step_files[@]} pending steps)"
  for f in "${step_files[@]}"; do
    echo "  • $(basename "$f") — $(head -1 "$f")"
  done
  echo
  found=1
done < <(find "$PROJECTS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

if [ "$found" -eq 0 ]; then
  echo "No KB projects found."
fi
