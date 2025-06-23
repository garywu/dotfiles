#!/usr/bin/env bash
# Release management script for dotfiles

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_CONFIG="${REPO_ROOT}/.github/release-schedule.yml"

# Functions
print_header() {
  echo -e "\n${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Get current version
get_current_version() {
  git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
}

# Calculate next version
calculate_next_version() {
  local current_version="$1"
  local bump_type="$2"

  # Remove 'v' prefix
  current_version="${current_version#v}"

  # Split version
  IFS='.' read -r -a version_parts <<<"$current_version"
  local major="${version_parts[0]:-0}"
  local minor="${version_parts[1]:-0}"
  local patch="${version_parts[2]:-0}"

  case "$bump_type" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  *)
    print_error "Invalid bump type: $bump_type"
    return 1
    ;;
  esac

  echo "v${major}.${minor}.${patch}"
}

# Generate changelog
generate_changelog() {
  local from_tag="$1"
  local to_ref="${2:-HEAD}"

  print_header "Generating changelog from $from_tag to $to_ref"

  # Group commits by type
  local features=""
  local fixes=""
  local docs=""
  local other=""

  while IFS= read -r commit; do
    local hash=$(echo "$commit" | cut -d' ' -f1)
    local message=$(echo "$commit" | cut -d' ' -f2-)

    if [[[[[ "$message" =~ ^feat(\(.*\))?!?: ]]]]]; then
      features="${features}- ${message} (${hash})\n"
    elif [[[[[ "$message" =~ ^fix(\(.*\))?!?: ]]]]]; then
      fixes="${fixes}- ${message} (${hash})\n"
    elif [[[[[ "$message" =~ ^docs(\(.*\))?!?: ]]]]]; then
      docs="${docs}- ${message} (${hash})\n"
    else
      other="${other}- ${message} (${hash})\n"
    fi
  done < <(git log --pretty=format:"%h %s" "${from_tag}..${to_ref}")

  # Build changelog
  local changelog=""

  if [[[[[ -n "$features" ]]]]]; then
    changelog="${changelog}### 🚀 Features\n${features}\n"
  fi

  if [[[[[ -n "$fixes" ]]]]]; then
    changelog="${changelog}### 🐛 Bug Fixes\n${fixes}\n"
  fi

  if [[[[[ -n "$docs" ]]]]]; then
    changelog="${changelog}### 📚 Documentation\n${docs}\n"
  fi

  if [[[[[ -n "$other" ]]]]]; then
    changelog="${changelog}### 🔧 Other Changes\n${other}\n"
  fi

  echo -e "$changelog"
}

# Check release status
check_release_status() {
  print_header "Release Status"

  local current_version=$(get_current_version)
  local latest_commit=$(git rev-parse HEAD)
  local commits_since_tag=$(git rev-list --count "${current_version}..HEAD" 2>/dev/null || echo "0")

  echo "Current version: ${current_version}"
  echo "Latest commit: ${latest_commit:0:7}"
  echo "Commits since last release: ${commits_since_tag}"

  if [[[[[ $commits_since_tag -eq 0 ]]]]]; then
    print_warning "No new commits since last release"
    return 1
  fi

  # Analyze commits for suggested version bump
  local suggested_bump="patch"
  if git log "${current_version}..HEAD" --pretty=%B | grep -q "BREAKING CHANGE\|^feat!:\|^fix!:"; then
    suggested_bump="major"
  elif git log "${current_version}..HEAD" --pretty=%B | grep -q "^feat:"; then
    suggested_bump="minor"
  fi

  echo "Suggested version bump: ${suggested_bump}"
  return 0
}

# Create release
create_release() {
  local bump_type="$1"
  local prerelease="${2:-}"

  print_header "Creating ${bump_type} release"

  # Check if we have uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them first."
    return 1
  fi

  local current_version=$(get_current_version)
  local new_version=$(calculate_next_version "$current_version" "$bump_type")

  if [[[[[ -n "$prerelease" ]]]]]; then
    new_version="${new_version}-${prerelease}.1"
  fi

  print_header "Release details"
  echo "Current version: $current_version"
  echo "New version: $new_version"
  echo "Release type: $bump_type"
  if [[[[[ -n "$prerelease" ]]]]]; then
    echo "Prerelease: $prerelease"
  fi

  # Generate changelog
  local changelog=$(generate_changelog "$current_version")

  echo -e "\n${BLUE}Changelog:${NC}"
  echo -e "$changelog"

  # Confirm
  echo -e "\n${YELLOW}Do you want to create this release? (y/N)${NC}"
  read -r confirm
  if [[[[[ "$confirm" != "y" ]]]]]; then
    print_warning "Release cancelled"
    return 0
  fi

  # Update version in files
  print_header "Updating version in files"

  # Update package.json files
  find "$REPO_ROOT" -name "package.json" -type f | while read -r file; do
    if grep -q '"version"' "$file"; then
      sed -i.bak "s/\"version\": \".*\"/\"version\": \"${new_version#v}\"/" "$file"
      rm "${file}.bak"
      print_success "Updated $file"
    fi
  done

  # Commit version changes
  if ! git diff --quiet; then
    git add -A
    git commit -m "chore(release): ${new_version}"
    print_success "Committed version changes"
  fi

  # Create and push tag
  git tag -a "$new_version" -m "Release ${new_version}

${changelog}"
  print_success "Created tag $new_version"

  # Push changes
  git push origin main
  git push origin "$new_version"
  print_success "Pushed changes and tag"

  print_success "Release $new_version created successfully!"
  echo -e "\n${BLUE}View release at:${NC} https://github.com/garywu/dotfiles/releases/tag/${new_version}"
}

# Show release schedule
show_schedule() {
  print_header "Release Schedule"

  if [[[[[ ! -f "$RELEASE_CONFIG" ]]]]]; then
    print_error "Release schedule configuration not found"
    return 1
  fi

  echo -e "\n${BLUE}Production Releases:${NC}"
  echo "- Monthly minor releases: First Monday of each month at 9 AM UTC"
  echo "- Weekly patch releases: Every Monday at 9 AM UTC"

  echo -e "\n${BLUE}Pre-release Channels:${NC}"
  echo "- Alpha: Daily builds (weekdays) at 2 AM UTC"
  echo "- Beta: Weekly releases on Fridays at 2 PM UTC"
  echo "- RC: Manual trigger only"

  echo -e "\n${BLUE}Version Bumping Rules:${NC}"
  echo "- Major: BREAKING CHANGE, feat!, fix!"
  echo "- Minor: feat:"
  echo "- Patch: fix:, perf:, refactor:, style:, docs:, test:, chore:"
}

# Main menu
show_menu() {
  echo -e "\n${BLUE}Dotfiles Release Management${NC}"
  echo "=========================="
  echo "1. Check release status"
  echo "2. Create patch release"
  echo "3. Create minor release"
  echo "4. Create major release"
  echo "5. Create prerelease (alpha/beta/rc)"
  echo "6. Show release schedule"
  echo "7. Exit"
  echo -e "\nSelect an option: \c"
}

# Main
main() {
  cd "$REPO_ROOT"

  while true; do
    show_menu
    read -r choice

    case $choice in
    1)
      check_release_status
      ;;
    2)
      check_release_status && create_release "patch"
      ;;
    3)
      check_release_status && create_release "minor"
      ;;
    4)
      check_release_status && create_release "major"
      ;;
    5)
      echo -e "\nPrerelease type (alpha/beta/rc): \c"
      read -r prerelease_type
      check_release_status && create_release "patch" "$prerelease_type"
      ;;
    6)
      show_schedule
      ;;
    7)
      print_success "Goodbye!"
      exit 0
      ;;
    *)
      print_error "Invalid option"
      ;;
    esac

    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
  done
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
