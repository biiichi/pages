#!/usr/bin/env bash

#
# Author: Jake Zimmerman <jake@zimmerman.io>
#
# A simple script to build an HTML file using Pandoc
#

set -euo pipefail

usage() {
  echo "usage: $0 <source.md> <dest.html>"
}

# ----- args and setup -----

src="${1:-}"
dest="${2:-}"
if [ "$src" = "" ] || [ "$dest" = "" ]; then
  2>&1 usage
  exit 1
fi

case "$src" in
  -h|--help)
    usage
    exit
    ;;
esac

if command -v grealpath &> /dev/null; then
  realpath="grealpath"
elif command -v realpath &> /dev/null; then
  realpath="realpath"
else
  2>&1 echo "$0: This script requires GNU realpath. Install it with:"
  2>&1 echo "    brew install coreutils"
  exit 1
fi

# ----- main -----

for file in "docs/css/theme.css" "docs/css/skylighting-solarized-theme.css"; do
  if ! [ -f "$file" ]; then
    2>&1 echo "$0: warning: CSS theme file is missing: $file (will 404 when serving)"
  fi
done

dest_dir="$(dirname "$dest")"
mkdir -p "$dest_dir"

css_rel_path="$("$realpath" "docs/css/" --relative-to "$dest_dir")"
img_folder="$("$realpath" "docs/img/" --relative-to "$dest_dir")"

pandoc \
  --katex \
  --from markdown+tex_math_single_backslash \
  --resource-path "$img_folder:." \
  --filter pandoc-sidenote.js \
  --to html5+smart \
  --template=template \
  --css="$css_rel_path/theme.css" \
  --css="$css_rel_path/skylighting-solarized-theme.css" \
  --css="$css_rel_path/custom.css" \
  --toc \
  --toc-depth 2 \
  --wrap=none \
  --output "$dest" \
  "$src"
