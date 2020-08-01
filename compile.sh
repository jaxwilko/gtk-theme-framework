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

usage() {
    cat << NOTICE
    OPTIONS
    -h      show this message
    -v      print verbose info
    -f      force asset recompilation
    -i      automatically install theme after completion
    -is     automatically set the theme/icons active after install
    -o      automatically icons theme after completion
NOTICE
}

say() {
    [ "$VERBOSE" ] && echo "==> $1"
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
            say "Rendering ${ASSETS_DIR}/${ASSET}.png"
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
            say "Rendering ${ASSETS_DIR}/${ASSET}@2.png"
            $INKSCAPE --export-id="$ASSET" \
              --export-dpi=180 \
              --export-id-only \
              --export-png="${ASSETS_DIR}/${ASSET}@2.png" "$SRC_FILE" > /dev/null

            make_optipng "${ASSETS_DIR}/${ASSET}@2.png"
        fi
    done < "$INDEX"
}

make_placeholder_replacement() {
    local SRC_FILE="$1"
    local OUT_FILE="$2"
    local PLACEHOLDERS=(
        "THEME_COLOUR_BACKGROUND"
        "THEME_COLOUR_FOREGROUND"
        "THEME_COLOUR_DIVIDER"
        "THEME_COLOUR_COMMENT"
        "THEME_COLOUR_ACCENT"
        "THEME_COLOUR_DANGER"
        "THEME_COLOUR_MID_DANGER"
        "THEME_COLOUR_WARNING"
        "THEME_COLOUR_SUCCESS"
        "THEME_COLOUR_INFO"
        "THEME_COLOUR_DARK_INFO"
        "THEME_COLOUR_TEXT"
    )

    cp "$SRC_FILE" "$OUT_FILE"

    for PLACEHOLDER in "${PLACEHOLDERS[@]}"
    do
        sed -i "s/${PLACEHOLDER}/${!PLACEHOLDER}/g" "$OUT_FILE"
    done
}

make_icons() {
    local MAKE_COLOUR="$1"
    cp src/icons/default/* src/icons/dist
    find ./src/icons/dist -type f -name "*.svg" -exec sed -i "s/DEFAULT_COLOUR/${MAKE_COLOUR}/g" {} +
}

VERBOSE=""
FORCE=""
INSTALL=""
INSTALL_ICONS=""
SET_THEME_ACTIVE=""

while getopts hvfios opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        f) FORCE=1 ;;
        i) INSTALL=1 ;;
        s) SET_THEME_ACTIVE=1 ;;
        o) INSTALL_ICONS=1 ;;
        *);;
    esac
done

source ./theme-variables.sh

if [[ -f ./theme-variables-custom.sh ]]; then
    say "Loading custom variables"
    source ./theme-variables-custom.sh
fi

say "Generating global color scheme"
cat > src/global/theme-variables.scss << SCSS
\$variant:               '$THEME_VARIANT';
\$laptop:                '$THEME_LAPTOP_MODE';
\$headerbar:             '$THEME_HEADER_BAR';
\$panel:                 '$THEME_PANEL';
\$palenight_background:  $THEME_COLOUR_BACKGROUND;
\$palenight_foreground:  $THEME_COLOUR_FOREGROUND;
\$palenight_divider:     $THEME_COLOUR_DIVIDER;
\$palenight_comment:     $THEME_COLOUR_COMMENT;
\$palenight_accent:      $THEME_COLOUR_ACCENT;
\$palenight_red:         $THEME_COLOUR_DANGER;
\$palenight_orange:      $THEME_COLOUR_MID_DANGER;
\$palenight_yellow:      $THEME_COLOUR_WARNING;
\$palenight_green:       $THEME_COLOUR_SUCCESS;
\$palenight_blue:        $THEME_COLOUR_INFO;
\$palenight_purple:      $THEME_COLOUR_DARK_INFO;
\$palenight_text:        $THEME_COLOUR_TEXT;
SCSS

if [ "$FORCE" ]; then
    rm -rf "src/gtk-3.0/assets/assets" \
        "src/gtk-2.0/assets/material/assets" \
        "src/gtk-3.0/assets/window-assets" \
        "src/gtk-3.0/assets/window-assets-contrast"
fi

say "Generating the gtk.css"
make_css "src/gtk-3.0/gtk"

say "Generating the gnome-shell.css"
make_css "src/gnome-shell/gnome-shell"

say "Generating gtk-2.0 gtkrc"
make_placeholder_replacement "src/gtk-2.0/gtkrc-template" "src/gtk-2.0/gtkrc"

say "Generating gtk-2.0 assets"
make_placeholder_replacement "src/gtk-2.0/assets/material/assets-template.svg" "src/gtk-2.0/assets/material/assets.svg"
make_assets "src/gtk-2.0/assets/assets.txt" "src/gtk-2.0/assets/material/assets"

say "Generating gtk-3.0 assets"
make_placeholder_replacement "src/gtk-3.0/assets/assets-template.svg" "src/gtk-3.0/assets/assets.svg"
make_assets "src/gtk-3.0/assets/assets.txt" "src/gtk-3.0/assets/assets"
make_assets_x2 "src/gtk-3.0/assets/assets.txt" "src/gtk-3.0/assets/assets"

say "Generating gtk-3.0 window assets"
make_placeholder_replacement "src/gtk-3.0/assets/window-assets-template.svg" "src/gtk-3.0/assets/window-assets.svg"
make_assets "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets"
make_assets_x2 "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets"

say "Generating gtk-3.0 contrast window assets"
make_assets "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets-contrast"
make_assets_x2 "src/gtk-3.0/assets/window-assets.txt" "src/gtk-3.0/assets/window-assets-contrast"

say "Generating colour icons"
make_icons "${THEME_COLOUR_SUCCESS}"

if [ "$INSTALL" ]; then
     [[ "$VERBOSE" ]] && FLAG="-v" || FLAG=""
     [[ "$SET_THEME_ACTIVE" ]] && FLAG="$FLAG -s"
     [[ "$INSTALL_ICONS" ]] && FLAG="$FLAG -o"
    sh -c "./install.sh $FLAG"
fi