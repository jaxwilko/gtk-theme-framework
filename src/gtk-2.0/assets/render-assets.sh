#! /bin/bash

INKSCAPE=$(command -v inkscape)
OPTIPNG=$(command -v optipng)

INDEX="assets.txt"
ASSETS_DIR="material/assets"
SRC_FILE="material/assets.svg"

mkdir -p $ASSETS_DIR

while IFS= read -r $i
do
  if [ ! -f $ASSETS_DIR/$i.png ]; then
        echo Rendering $ASSETS_DIR/$i.png
        $INKSCAPE --export-id=$i \
            --export-id-only \
            --export-png=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null &&
            $OPTIPNG -o7 --quiet $ASSETS_DIR/$i.png
    fi
done < "$INDEX"

exit 0
