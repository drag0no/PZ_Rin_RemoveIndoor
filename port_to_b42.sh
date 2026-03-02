#!/bin/bash

MODS_DIR="Contents/mods"

echo "Scanning for mods in $MODS_DIR..."

for MOD_PATH in "$MODS_DIR"/*/; do
    [ -d "$MOD_PATH" ] || continue

    echo "> Processing: $MOD_NAME"

    MOD_NAME=$(basename "$MOD_PATH")
    TARGET_DIR="$MODS_DIR/$MOD_NAME"

    if [ ! -f "$TARGET_DIR/mod.info" ]; then
        echo "  * Skipping '$MOD_NAME' - No mod.info found."
        continue
    fi

    mkdir -p "$TARGET_DIR/42"
    mkdir -p "$TARGET_DIR/common"

    cp -r "$TARGET_DIR/media" "$TARGET_DIR/common/"
    cp "$TARGET_DIR/mod.info" "$TARGET_DIR/42/"
    cp "$TARGET_DIR/poster.png" "$TARGET_DIR/42/"
    cp "icon.png" "$TARGET_DIR/42/"

    {
      echo "author=Rinski"
      echo "icon=icon.png"
      echo "versionMin=42.0.0"
     } >> "$TARGET_DIR/42/mod.info"

    echo "  * Successfully restructured '$MOD_NAME'."
done

echo "Processing complete!"