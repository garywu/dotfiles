#!/usr/bin/env bash

# Fix all bash shebangs to use env for proper bash version detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Fixing bash shebangs to use '#!/usr/bin/env bash'..."

# Find all shell scripts with #!/bin/bash
files_to_fix=$(find "$PROJECT_ROOT" -type f -name "*.sh" -exec grep -l "^#!/bin/bash" {} \; 2>/dev/null || true)

if [[ -z "$files_to_fix" ]]; then
  echo "No files need fixing!"
  exit 0
fi

count=0
for file in $files_to_fix; do
  # Skip this script itself
  if [[ "$file" == "$0" ]]; then
    continue
  fi

  echo "Fixing: $file"
  # Use sed to replace the shebang
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS sed requires -i ''
    sed -i '' '1s|^#!/bin/bash$|#!/usr/bin/env bash|' "$file"
  else
    # GNU sed
    sed -i '1s|^#!/bin/bash$|#!/usr/bin/env bash|' "$file"
  fi
  ((count++))
done

echo "Fixed $count files"
echo ""
echo "Current bash version in PATH:"
bash --version | head -1
