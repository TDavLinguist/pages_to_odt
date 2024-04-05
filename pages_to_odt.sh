#!/bin/bash

# Initialize variables
WORKING_DIR="/tmp/pages_odt_convert"
LOG_FILE="$WORKING_DIR/log.txt"
INCLUDE_HIDDEN=0
VERBOSE_ZIP=0
RECURSIVE=0

# Create working directory and clear log file
mkdir -p "$WORKING_DIR"
> "$LOG_FILE"

# Option parsing
while getopts ":hRv" opt; do
  case ${opt} in
    h ) INCLUDE_HIDDEN=1 ;;
    R ) RECURSIVE=1 ;;
    v ) VERBOSE_ZIP=1 ;;
    \? ) echo "Usage: cmd [-h] [-R] [-v]"
         exit 1 ;;
  esac
done

# Prepare find command
find_cmd="find ."
[[ $RECURSIVE -eq 0 ]] && find_cmd+=" -maxdepth 1"
find_cmd+=" \( -type f -o -type d \)"
[[ $INCLUDE_HIDDEN -eq 0 ]] && find_cmd+=" ! -path '*/.*'"
find_cmd+=" -name '*.pages'"

# Conversion function
convert_pages_to_odt() {
  local source="$1"
  local dest="$2"
  echo "Converting '$source' to ODT format..."
  libreoffice --headless --convert-to odt:"writer8" --outdir "$dest" "$source"
}

# Process files/directories
process_item() {
  local item="$1"
  local id=$(printf "%04d" $((10#$2)))
  local temp_zip="$WORKING_DIR/$id.pages"

  if [[ -d "$item" ]]; then
    # It's a directory; zip its contents
    if [[ $VERBOSE_ZIP -eq 1 ]]; then
      (cd "$item" && zip -r "$temp_zip" .)
    else
      (cd "$item" && zip -r "$temp_zip" . > /dev/null 2>&1)
    fi
  else
    # It's a file; just copy it to temp location
    cp "$item" "$temp_zip"
  fi

  echo "$id: $item" >> "$LOG_FILE"
  convert_pages_to_odt "$temp_zip" "$WORKING_DIR"

  local converted_file="$WORKING_DIR/$id.odt"
  if [[ -f "$converted_file" ]]; then
    local original_path=$(dirname "$item")
    local original_name=$(basename "$item" .pages)
    mv "$converted_file" "$original_path/$original_name.odt"
    echo "Successfully converted and moved: $original_path/$original_name.odt"
  else
    echo "Conversion failed or file not found for ID: $id"
  fi
}

# Main execution
id=1
eval "$find_cmd" | while IFS= read -r item; do
  process_item "$item" $id
  ((id++))
done

# Cleanup
echo "Processing complete. Working directory cleaned up."
rm -rf "$WORKING_DIR"

