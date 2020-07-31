#!/usr/bin/env bash

usage() {
    cat << NOTICE
    OPTIONS
    -h                  show this message
    -v                  print verbose info
    -d /path/to/dir     force themes directory
NOTICE
}

say() {
    [ "$VERBOSE" ] && echo "==> $1"
}

REO_DIR=$(cd $(dirname $0) && pwd)
SRC_DIR=${REO_DIR}/src

ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
    DEST_DIR="/usr/share/themes"
else
    DEST_DIR="${HOME}/.themes"
fi

VERBOSE=""
CONTRAST_MODE=""

while getopts hvcd: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        d) DEST_DIR=${OPTARG} ;;
        c) CONTRAST_MODE=1 ;;
        *);;
    esac
done

source ./theme-variables.sh

THEME_DIR="${DEST_DIR}/${THEME_NAME}"

say "Installing to '${THEME_DIR}'"

say "Removing theme if exists"

[[ -d ${THEME_DIR} ]] && rm -rf "$THEME_DIR"

say "Copying licence"

mkdir -p ${THEME_DIR}
cp -r ${REO_DIR}/LICENSE ${THEME_DIR}

say "Generating index.theme file"

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

say "Install gtk2 theme"

mkdir -p                                                        "${THEME_DIR}/gtk-2.0"
cp -r "${SRC_DIR}"/gtk-2.0/common/*.rc                          "${THEME_DIR}/gtk-2.0"
cp -r "${SRC_DIR}/gtk-2.0/assets/material/assets"               "${THEME_DIR}/gtk-2.0/assets"

cp -r "${SRC_DIR}/gtk-2.0/gtkrc"                                "${THEME_DIR}/gtk-2.0/gtkrc"


say "Install gtk3 theme"
mkdir -p                                                        "${THEME_DIR}/gtk-3.0/assets"
cp -r "${SRC_DIR}"/gtk-3.0/assets/assets/*.png                  "${THEME_DIR}/gtk-3.0/assets"

if [ "$CONTRAST_MODE" ]; then
    cp -r "${SRC_DIR}/gtk-3.0/assets/window-assets-contrast"    "${THEME_DIR}/gtk-3.0/assets/window-assets"
else
    cp -r "${SRC_DIR}/gtk-3.0/assets/window-assets"             "${THEME_DIR}/gtk-3.0/assets"
fi

cp -r "${SRC_DIR}/gtk-3.0/assets/scalable"                      "${THEME_DIR}/gtk-3.0/assets"
cp -r "${SRC_DIR}/gtk-3.0/gtk.css"                              "${THEME_DIR}/gtk-3.0/gtk.css"

# may add this back in later if needed
#cp -r "${SRC_DIR}/gtk-3.0/assets/thumbnails/thumbnail.png"      "${THEME_DIR}/gtk-3.0/thumbnail.png"

say "Install gnome-shell theme"
mkdir -p "${THEME_DIR}/gnome-shell"

cp -r "${SRC_DIR}/gnome-shell/extensions"                       "${THEME_DIR}/gnome-shell"
cp -r "${SRC_DIR}/gnome-shell/message-indicator-symbolic.svg"   "${THEME_DIR}/gnome-shell"
cp -r "${SRC_DIR}/gnome-shell/pad-osd.css"                      "${THEME_DIR}/gnome-shell"
cp -r "${SRC_DIR}/gnome-shell/common-assets"                    "${THEME_DIR}/gnome-shell/assets"
cp -r "${SRC_DIR}"/gnome-shell/assets/*.svg                     "${THEME_DIR}/gnome-shell/assets"
cp -r "${SRC_DIR}/gnome-shell/color-assets/checkbox.svg"        "${THEME_DIR}/gnome-shell/assets/checkbox.svg"
cp -r "${SRC_DIR}/gnome-shell/color-assets/more-results.svg"    "${THEME_DIR}/gnome-shell/assets/more-results.svg"
cp -r "${SRC_DIR}/gnome-shell/color-assets/toggle-on.svg"       "${THEME_DIR}/gnome-shell/assets/toggle-on.svg"
cp -r "${SRC_DIR}/gnome-shell/color-assets/menu-checked.svg"    "${THEME_DIR}/gnome-shell/assets/menu-checked.svg"
cp -r "${SRC_DIR}/gnome-shell/color-assets/menu.svg"            "${THEME_DIR}/gnome-shell/assets/menu.svg"
cp -r "${SRC_DIR}/gnome-shell/gnome-shell.css"                  "${THEME_DIR}/gnome-shell/gnome-shell.css"

cd "${THEME_DIR}/gnome-shell" || exit 1
ln -s assets/no-events.svg                                      no-events.svg
ln -s assets/process-working.svg                                process-working.svg
ln -s assets/no-notifications.svg                               no-notifications.svg
