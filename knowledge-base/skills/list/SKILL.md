---
name: list
description: List all KB projects with their pending step counts and titles. Use when the user types /list and wants an overview of knowledge-base projects.
---

# /list

List all knowledge-base projects and their pending implementation steps.

Usage: `/list`

@../../docs/config.md

---

Extract `KB_ROOT` from the config above. Spawn a subagent to run this script, substituting `KB_ROOT` with the literal configured value (leave it unquoted in the assignment so tilde expands):

```bash
PROJECTS=KB_ROOT/projects

if [ ! -d "$PROJECTS" ]; then
  echo "KB projects directory not found. Run: mkdir -p KB_ROOT/projects KB_ROOT/completed-projects"
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

[ "$found" -eq 0 ] && echo "No KB projects found."
```

Print the script output exactly as returned.
