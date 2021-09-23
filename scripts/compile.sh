#! /bin/bash

INKSCAPE=$(command -v inkscape)
OPTIPNG=$(command -v optipng)
SASSC=$(command -v sassc)

INKSCAPE_EXPORT=$([[ "$(inkscape --version 2>&1 | tail -n 1 | awk '{print $2}')" = 0.* ]] \
    && echo "--export-png" \
    || echo "--export-filename")

PROJ_DIR=$(cd $(dirname $(dirname "${0}")) && pwd)

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
    -t      theme name
NOTICE
}

say() {
    [ "$VERBOSE" ] || [ "$2" ] && echo "==> $1"
}

make_css() {
    local SRC_FILE="$1"
    local OUT_FILE="$2"

    mkdir -p "$(dirname "$OUT_FILE")"

    sh -c "$SASSC -M -t expanded ${SRC_FILE}.scss ${OUT_FILE}.css"
}

make_optipng() {
    $OPTIPNG -o7 --quiet "$1"
}

make_assets() {
    local INDEX="$1"
    local SRC_FILE="$2.svg"
    local ASSETS_DIR="$3"

    mkdir -p "$ASSETS_DIR"

    while IFS= read -r ASSET
    do
        if [ ! -f "${ASSETS_DIR}/${ASSET}.png" ]; then
            say "Rendering ${ASSETS_DIR}/${ASSET}.png"
            $INKSCAPE --export-id="$ASSET" \
                --export-id-only \
                "${INKSCAPE_EXPORT}=${ASSETS_DIR}/${ASSET}.png" "$SRC_FILE" > /dev/null 2>&1

            make_optipng "${ASSETS_DIR}/${ASSET}.png"
        fi
    done < "$INDEX"
}

make_assets_x2() {
    local INDEX="$1"
    local SRC_FILE="$2.svg"
    local ASSETS_DIR="$3"

    mkdir -p "$ASSETS_DIR"

    while IFS= read -r ASSET
    do
        if [ ! -f "${ASSETS_DIR}/${ASSET}@2.png" ]; then
            say "Rendering ${ASSETS_DIR}/${ASSET}@2.png"
            $INKSCAPE --export-id="$ASSET" \
              --export-dpi=180 \
              --export-id-only \
              "${INKSCAPE_EXPORT}=${ASSETS_DIR}/${ASSET}@2.png" "$SRC_FILE" > /dev/null 2>&1

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
        "THEME_COLOUR_DANGER"
        "THEME_COLOUR_MID_DANGER"
        "THEME_COLOUR_WARNING"
        "THEME_COLOUR_SUCCESS"
        "THEME_COLOUR_INFO"
        "THEME_COLOUR_DARK_INFO"
        "THEME_COLOUR_TEXT"
        "THEME_COLOUR_ACCENT_PRIMARY"
        "THEME_COLOUR_ACCENT_SECONDARY"
        "THEME_COLOUR_ACCENT_TERTIARY"
        "THEME_COLOUR_UI_FOREGROUND_PRIMARY"
        "THEME_COLOUR_UI_FOREGROUND_SECONDARY"
    )

    mkdir -p "$(dirname "$OUT_FILE")"

    cp "$SRC_FILE" "$OUT_FILE"

    for PLACEHOLDER in "${PLACEHOLDERS[@]}"
    do
        sed -i "s/${PLACEHOLDER}/${!PLACEHOLDER}/g" "$OUT_FILE"
    done
}

make_icons() {
    local MAKE_COLOUR="$1"
    mkdir -p "${ICON_DIR}"
    cp "${PROJ_DIR}"/src/icons/default/* "${ICON_DIR}"
    find "${ICON_DIR}" -type f -name "*.svg" -exec sed -i "s/DEFAULT_COLOUR/${MAKE_COLOUR}/g" {} +
}

VERBOSE=""
FORCE=""
THEME_NAME="palenight"
THEME_STYLE="material"
THEME_TRANSPARENT="true"
FORCE_STYLE=""

while getopts hvft:y: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        f) FORCE=1 ;;
        t) THEME_NAME=${OPTARG} ;;
        y) FORCE_STYLE=${OPTARG} ;;
        *);;
    esac
done

if [ ! -f "${PROJ_DIR}/themes/${THEME_NAME}.sh" ]; then
    say "Could not find theme ${THEME_NAME}" "true"
    exit 1
fi

say "Loading theme ${THEME_NAME} settings"
source "${PROJ_DIR}/themes/${THEME_NAME}.sh"

if [ "$FORCE_STYLE" ]; then
    THEME_STYLE="$FORCE_STYLE"
fi

THEME_DIR="${PROJ_DIR}/dist/${THEME_NAME}/theme"
ICON_DIR="${PROJ_DIR}/dist/${THEME_NAME}/icons"

mkdir -p "$THEME_DIR"
mkdir -p "$ICON_DIR"

say "Generating global color scheme"
cat > "${PROJ_DIR}/src/theme-variables.scss" << SCSS
\$variant:                                  '$THEME_VARIANT';
\$laptop:                                   '$THEME_LAPTOP_MODE';
\$headerbar:                                '$THEME_HEADER_BAR';
\$panel:                                    '$THEME_PANEL';
\$transparency:                             '$THEME_TRANSPARENT';
\$theme_colour_background:                  $THEME_COLOUR_BACKGROUND;
\$theme_colour_foreground:                  $THEME_COLOUR_FOREGROUND;
\$theme_colour_divider:                     $THEME_COLOUR_DIVIDER;
\$theme_colour_comment:                     $THEME_COLOUR_COMMENT;
\$theme_colour_danger:                      $THEME_COLOUR_DANGER;
\$theme_colour_mid_danger:                  $THEME_COLOUR_MID_DANGER;
\$theme_colour_warning:                     $THEME_COLOUR_WARNING;
\$theme_colour_success:                     $THEME_COLOUR_SUCCESS;
\$theme_colour_info:                        $THEME_COLOUR_INFO;
\$theme_colour_dark_info:                   $THEME_COLOUR_DARK_INFO;
\$theme_colour_text:                        $THEME_COLOUR_TEXT;
\$theme_colour_text_highlight:              $THEME_COLOUR_TEXT_HIGHLIGHT;
\$theme_colour_accent_primary:              $THEME_COLOUR_ACCENT_PRIMARY;
\$theme_colour_accent_secondary:            $THEME_COLOUR_ACCENT_SECONDARY;
\$theme_colour_accent_tertiary:             $THEME_COLOUR_ACCENT_TERTIARY;
\$theme_colour_ui_foreground_primary:       $THEME_COLOUR_UI_FOREGROUND_PRIMARY;
\$theme_colour_ui_foreground_secondary:     $THEME_COLOUR_UI_FOREGROUND_SECONDARY;
SCSS

cat > "${THEME_DIR}/index.theme" <<EOT
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${THEME_NAME}
Comment=An Clean Gtk+ theme based on Material Design
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=${THEME_NAME}
MetacityTheme=${THEME_NAME}
IconTheme=Adwaita
CursorTheme=Adwaita
ButtonLayout=menu:minimize,maximize,close
EOT

if [ "$FORCE" ]; then
    rm -rf "${THEME_DIR}/gnome-shell/assets" \
        "${THEME_DIR}/gtk-3.0/assets" \
        "${THEME_DIR}/gtk-2.0/assets"
fi

mkdir -p "${THEME_DIR}/gnome-shell/assets"

say "Generating the gtk.css"
make_css "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/gtk" "${THEME_DIR}/gtk-3.0/gtk"

say "Generating the gnome-shell.css"
make_css "${PROJ_DIR}/src/${THEME_STYLE}/gnome-shell/gnome-shell" "${THEME_DIR}/gnome-shell/gnome-shell"

say "Generating common gnome-shell files"

cp -r "${PROJ_DIR}/src/${THEME_STYLE}/gnome-shell/extensions"                      "${THEME_DIR}/gnome-shell"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}/gnome-shell/message-indicator-symbolic.svg"  "${THEME_DIR}/gnome-shell"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}/gnome-shell/pad-osd.css"                     "${THEME_DIR}/gnome-shell"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}"/gnome-shell/common-assets/*.svg             "${THEME_DIR}/gnome-shell/assets"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}"/gnome-shell/assets/*.svg                    "${THEME_DIR}/gnome-shell/assets"

say "Generating gnome-shell theme assets"

for ASSET in "${PROJ_DIR}/src/${THEME_STYLE}"/gnome-shell/color-assets/*.svg
do
    make_placeholder_replacement "$ASSET" "${THEME_DIR}/gnome-shell/assets/$(basename $ASSET)"
done

cp "${THEME_DIR}/gnome-shell/assets/no-events.svg"                    "${THEME_DIR}/gnome-shell/no-events.svg"
cp "${THEME_DIR}/gnome-shell/assets/process-working.svg"              "${THEME_DIR}/gnome-shell/process-working.svg"
cp "${THEME_DIR}/gnome-shell/assets/no-notifications.svg"             "${THEME_DIR}/gnome-shell/no-notifications.svg"

say "Generating gtk-2.0 gtkrc"
make_placeholder_replacement "${PROJ_DIR}/src/${THEME_STYLE}/gtk-2.0/gtkrc-template" "${THEME_DIR}/gtk-2.0/gtkrc"

say "Generating common gtkrc files"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}"/gtk-2.0/common/*.rc                         "${THEME_DIR}/gtk-2.0"

say "Generating gtk-2.0 assets"
make_placeholder_replacement "${PROJ_DIR}/src/${THEME_STYLE}/gtk-2.0/assets/assets-template.svg" "${THEME_DIR}/gtk-2.0/assets/assets.svg"
make_assets "${PROJ_DIR}/src/${THEME_STYLE}/gtk-2.0/assets/assets.txt" "${THEME_DIR}/gtk-2.0/assets/assets" "${THEME_DIR}/gtk-2.0/assets"

say "Generating gtk-3.0 assets"
make_placeholder_replacement "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/assets-template.svg" "${THEME_DIR}/gtk-3.0/assets/assets.svg"
make_assets "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/assets.txt" "${THEME_DIR}/gtk-3.0/assets/assets" "${THEME_DIR}/gtk-3.0/assets"
make_assets_x2 "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/assets.txt" "${THEME_DIR}/gtk-3.0/assets/assets" "${THEME_DIR}/gtk-3.0/assets"

say "Generating gtk-3.0 window assets"
make_placeholder_replacement "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/window-assets-template.svg" "${THEME_DIR}/gtk-3.0/assets/window-assets.svg"
make_assets "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/window-assets.txt" "${THEME_DIR}/gtk-3.0/assets/window-assets" "${THEME_DIR}/gtk-3.0/assets/window-assets"
make_assets_x2 "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/window-assets.txt" "${THEME_DIR}/gtk-3.0/assets/window-assets" "${THEME_DIR}/gtk-3.0/assets/window-assets"

say "Generating scalable assets"
cp -r "${PROJ_DIR}/src/${THEME_STYLE}/gtk-3.0/assets/scalable" "${THEME_DIR}/gtk-3.0/assets"

say "Generating colour icons"
make_icons "${THEME_COLOUR_ACCENT_SECONDARY}"

say "Resetting theme scss"
echo "" > "${PROJ_DIR}/src/theme-variables.scss"
