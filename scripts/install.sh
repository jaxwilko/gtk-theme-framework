#!/usr/bin/env bash

usage() {
    cat << NOTICE
    OPTIONS
    -h                  show this message
    -v                  print verbose info
    -d /path/to/dir     force themes directory
    -s                  automatically set the theme active after install
    -o                  install icons
    -t                  theme name
NOTICE
}

say() {
    [ "$VERBOSE" ] && echo "==> $1"
}

PROJ_DIR=$(cd $(dirname $(dirname "${0}")) && pwd)
SRC_DIR="${PROJ_DIR}/src"

ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
    DEST_DIR="/usr/share/themes"
    ICON_DEST_DIR="/usr/share/icons"
else
    DEST_DIR="${HOME}/.themes"
    ICON_DEST_DIR="${HOME}/.local/share/icons"
fi

VERBOSE=""
THEME_NAME="palenight"

while getopts hvsocd:t: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        d) DEST_DIR=${OPTARG} ;;
        s) SET_THEME_ACTIVE=1 ;;
        o) INSTALL_ICONS=1 ;;
        t) THEME_NAME=${OPTARG} ;;
        *);;
    esac
done

if [ ! -f "./themes/${THEME_NAME}.sh" ]; then
    say "Could not find theme ${THEME_NAME}" "true"
    exit 1
fi

DIST_DIR="${PROJ_DIR}/dist/${THEME_NAME}"

if [ ! -d "$DIST_DIR" ]; then
    say "Theme dist missing, compile first" "true"
fi

say "Loading theme ${THEME_NAME} settings"
source "${PROJ_DIR}/themes/${THEME_NAME}.sh"

THEME_DIR="${DEST_DIR}/${THEME_NAME}"

say "Installing to '${THEME_DIR}'"

say "Removing theme if exists"

[[ -d ${THEME_DIR} ]] && rm -rf "$THEME_DIR"

say "Copying files"

cp -r "${DIST_DIR}/theme" "$THEME_DIR"

if [ "$INSTALL_ICONS" ]; then
    say "Installing icons"
    if [[ ! -d "${ICON_DEST_DIR}/${THEME_NAME}" ]]; then

        if [[ ! -d "${SRC_DIR}/icons/vimix-icon-theme" ]]; then
            echo -e "\033[1;31mInstalling vimix-icons-theme, please show vinceliuice love and support!\033[0m"
            git clone git@github.com:vinceliuice/vimix-icon-theme.git "${SRC_DIR}/icons/vimix-icon-theme"
        fi

        sh -c "${SRC_DIR}/icons/vimix-icon-theme/install.sh -n ${THEME_NAME} > /dev/null"
    fi

    cp "${DIST_DIR}"/icons/* "${ICON_DEST_DIR}/${THEME_NAME}-dark/scalable/places"
    cp "${DIST_DIR}"/icons/* "${ICON_DEST_DIR}/${THEME_NAME}/scalable/places"
fi


if [ "$SET_THEME_ACTIVE" ]; then
    say "Setting theme active"
    gsettings reset org.gnome.desktop.interface gtk-theme
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
    gsettings set org.gnome.shell.extensions.user-theme name "Adwaita"
    gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME"
    say "Setting icons active"
    gsettings reset org.gnome.desktop.interface icon-theme
    gsettings set org.gnome.desktop.interface icon-theme "$THEME_NAME"
fi