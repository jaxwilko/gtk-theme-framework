#! /bin/bash

INKSCAPE=$(command -v inkscape)
OPTIPNG=$(command -v optipng)
SASSC=$(command -v sassc)

if [ ! "$SASSC" ]; then
   echo sassc needs to be installed to generate the css.
   exit 1
fi

if [ ! "$INKSCAPE" ]; then
   echo inkscape needs to be installed to generate assets.
   exit 1
fi

if [ ! "$OPTIPNG" ]; then
   echo optipng needs to be installed for asset optimisation.
   exit 1
fi

help_message() {
    cat << NOTICE
    OPTIONS
    -h      show this message
    -v      print verbose info
NOTICE
}

make_css() {
    local SRC_FILE="$1"
    sh -c "$SASSC -M -t expanded ${SRC_FILE}.scss ${SRC_FILE}.css"
}

make_optipng() {
    $OPTIPNG -o7 --quiet "$1"
}

make_assets() {
    local INDEX="$1"
    local ASSETS_DIR="$2"
    local SRC_FILE="$2.svg"

    mkdir -p "$ASSETS_DIR"

    while IFS= read -r ASSET
    do
        if [ ! -f "${ASSETS_DIR}/${ASSET}.png" ]; then
            [ "$VERBOSE" ] && echo "Rendering ${ASSETS_DIR}/${ASSET}.png"
            $INKSCAPE --export-id="$ASSET" \
                --export-id-only \
                --export-png="${ASSETS_DIR}/${ASSET}.png" "$SRC_FILE" > /dev/null

            make_optipng "${ASSETS_DIR}/${ASSET}.png"
        fi
    done < "$INDEX"
}

make_assets_x2() {
    local INDEX="$1"
    local ASSETS_DIR="$2"
    local SRC_FILE="$2.svg"

    mkdir -p "$ASSETS_DIR"

    while IFS= read -r ASSET
    do
        if [ ! -f "${ASSETS_DIR}/${ASSET}@2.png" ]; then
            [ "$VERBOSE" ] && echo "Rendering ${ASSETS_DIR}/${ASSET}@2.png"
            $INKSCAPE --export-id="$ASSET" \
              --export-dpi=180 \
              --export-id-only \
              --export-png="${ASSETS_DIR}/${ASSET}@2.png" "$SRC_FILE" > /dev/null

            make_optipng "${ASSETS_DIR}/${ASSET}@2.png"
        fi
    done < "$INDEX"
}

VERBOSE=""

while getopts hv opts; do
    case ${opts} in
        h)
            help_message
            exit 0
            ;;
        v) VERBOSE=1 ;;
        *);;
    esac
done

echo "==> Generating the gtk.css..."
make_css "src/gtk-3.0/gtk"

echo "==> Generating the gnome-shell.css..."
make_css "src/gnome-shell/gnome-shell"

echo "==> Generating gtk-2.0 assets..."
make_assets "src/gtk-2.0/assets/assets.txt" "src/gtk-2.0/assets/material/assets"

echo "==> Generating gtk-3.0 assets..."
make_assets "src/gtk-3.0/assets/assets.txt" "src/gtk-3.0/assets/assets"
make_assets_x2 "src/gtk-3.0/assets/assets.txt" "src/gtk-3.0/assets/assets"

echo "==> Generating gtk-3.0 window assets..."
make_assets "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets"
make_assets_x2 "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets"

echo "==> Generating gtk-3.0 contrast window assets..."
make_assets "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets-contrast"
make_assets_x2 "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets-contrast"
