#!/usr/bin/env bash
#
# install.sh — install the Figma design-to-code skill suite for Claude Code.
#
# Usage:
#   ./install.sh                 # install for the current user (~/.claude/skills)
#   ./install.sh --project       # install into ./.claude/skills (this project only)
#   ./install.sh --dir <path>    # install into a custom skills directory
#   ./install.sh --force         # overwrite existing skills without prompting
#   ./install.sh --uninstall     # remove the three skills from the target
#
# Remote one-liner (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/Peeradonte48/FIGMA-IMPLEMENT/main/install.sh | bash
#
set -euo pipefail

REPO="Peeradonte48/FIGMA-IMPLEMENT"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/main"
SKILLS=(
  "implement-figma-design"
  "figjam-to-use-case-narrative"
  "use-case-narrative-to-prototype"
)
# Files shipped per skill (relative to the skill directory).
FILES_implement_figma_design=(
  "SKILL.md"
)
FILES_figjam_to_use_case_narrative=(
  "SKILL.md"
  "references/figjam-mapping.md"
  "references/use-case-narrative-format.md"
)
FILES_use_case_narrative_to_prototype=(
  "SKILL.md"
  "references/prototype-mapping.md"
  "references/use-case-narrative-format.md"
)

# --- arg parsing -----------------------------------------------------------
TARGET=""
FORCE=0
UNINSTALL=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project)   TARGET="$(pwd)/.claude/skills"; shift ;;
    --dir)       TARGET="${2:?--dir needs a path}"; shift 2 ;;
    --force)     FORCE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)   sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done
[ -n "$TARGET" ] || TARGET="${HOME}/.claude/skills"

# --- helpers ---------------------------------------------------------------
say() { printf '  %s\n' "$1"; }

# Where is the skills/ source? Local checkout if present, else download.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SOURCE_MODE="local"
if [ ! -d "${SCRIPT_DIR}/skills" ]; then
  SOURCE_MODE="remote"
fi

files_for() {
  # Map a skill name to its file list via the FILES_<name> arrays above.
  local var="FILES_${1//-/_}[@]"
  printf '%s\n' "${!var}"
}

# --- uninstall -------------------------------------------------------------
if [ "$UNINSTALL" -eq 1 ]; then
  echo "Removing skills from: ${TARGET}"
  for s in "${SKILLS[@]}"; do
    if [ -d "${TARGET}/${s}" ]; then
      rm -rf "${TARGET:?}/${s}"
      say "removed ${s}"
    else
      say "skip   ${s} (not installed)"
    fi
  done
  echo "Done."
  exit 0
fi

# --- install ---------------------------------------------------------------
echo "Installing Figma skill suite (${SOURCE_MODE}) into: ${TARGET}"
mkdir -p "${TARGET}"

for s in "${SKILLS[@]}"; do
  dest="${TARGET}/${s}"
  if [ -d "$dest" ] && [ "$FORCE" -ne 1 ]; then
    printf '  %s already exists. Overwrite? [y/N] ' "$s"
    read -r ans </dev/tty || ans="n"
    case "$ans" in [yY]*) ;; *) say "skip   ${s}"; continue ;; esac
  fi
  rm -rf "$dest"
  if [ "$SOURCE_MODE" = "local" ]; then
    mkdir -p "$dest"
    cp -R "${SCRIPT_DIR}/skills/${s}/." "$dest/"
  else
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      mkdir -p "$(dirname "${dest}/${rel}")"
      curl -fsSL "${RAW_BASE}/skills/${s}/${rel}" -o "${dest}/${rel}"
    done < <(files_for "$s")
  fi
  say "installed ${s}"
done

echo
echo "Done. Restart Claude Code (or run /doctor) so it picks up the new skills."
echo "Invoke a skill by sharing a Figma/FigJam link, or type its name, e.g.:"
echo "  implement-figma-design  •  figjam-to-use-case-narrative  •  use-case-narrative-to-prototype"
