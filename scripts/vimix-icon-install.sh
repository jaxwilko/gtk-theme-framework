#!/usr/bin/env bash

usage() {
    cat << NOTICE
    OPTIONS
    -h                  show this message
    -v                  print verbose info
    -d /path/to/dir     force icons directory
    -n name             icons name
NOTICE
}

say() {
    [ "$VERBOSE" ] && echo "==> $1"
}

PROJ_DIR=$(cd $(dirname $(dirname "${0}")) && pwd)
SRC_DIR="${PROJ_DIR}/src/icons/vimix-icon-theme"

ROOT_UID=0

if [ -z "${HOME:-}" ]; then
    HOME="$(cd ~ && pwd)"
fi

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
    DEST_DIR="/usr/share/icons"
else
    DEST_DIR="${HOME}/.local/share/icons"
fi

VERBOSE=""
THEME_NAME="palenight"

while getopts hvd:n: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        d) DEST_DIR=${OPTARG} ;;
        n) THEME_NAME=${OPTARG} ;;
        *);;
    esac
done

THEME_DIR="${DEST_DIR}/${THEME_NAME}"

say "Installing icons to ${THEME_DIR}"

if [ -d "${THEME_DIR}" ]; then
    say "Removing existing icon dir"
    rm -r "${THEME_DIR}"
fi

install -d "${THEME_DIR}"

install -m644 "${SRC_DIR}/src/index.theme"                                      "${THEME_DIR}"

# Update the name in index.theme
sed -i "s/%NAME%/${THEME_NAME//-/ }/g"                                          "${THEME_DIR}/index.theme"

install -d "${THEME_DIR}"/{16,22,24}

cp -r "${SRC_DIR}"/src/{16,22,24,scalable,symbolic}                             "${THEME_DIR}"
cp -r "${SRC_DIR}"/links/{16,22,24,scalable,symbolic}                           "${THEME_DIR}"
cp -r "${SRC_DIR}"/src/16/{actions,devices,places}                              "${THEME_DIR}/16"
cp -r "${SRC_DIR}"/src/22/{actions,devices,places}                              "${THEME_DIR}/22"
cp -r "${SRC_DIR}"/src/24/{actions,devices,places}                              "${THEME_DIR}/24"

# Change icon color for dark theme
sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*
sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*

cp -r "${SRC_DIR}"/links/16/{actions,devices,places}                            "${THEME_DIR}/16"
cp -r "${SRC_DIR}"/links/22/{actions,devices,places}                            "${THEME_DIR}/22"
cp -r "${SRC_DIR}"/links/24/{actions,devices,places}                            "${THEME_DIR}/24"

# Link the common icons
ln -sr "${THEME_DIR}/scalable"                                                  "${THEME_DIR}/scalable"
ln -sr "${THEME_DIR}/symbolic"                                                  "${THEME_DIR}/symbolic"
ln -sr "${THEME_DIR}/16/mimetypes"                                              "${THEME_DIR}/16/mimetypes"
ln -sr "${THEME_DIR}/16/panel"                                                  "${THEME_DIR}/16/panel"
ln -sr "${THEME_DIR}/16/status"                                                 "${THEME_DIR}/16/status"
ln -sr "${THEME_DIR}/22/emblems"                                                "${THEME_DIR}/22/emblems"
ln -sr "${THEME_DIR}/22/mimetypes"                                              "${THEME_DIR}/22/mimetypes"
ln -sr "${THEME_DIR}/22/panel"                                                  "${THEME_DIR}/22/panel"
ln -sr "${THEME_DIR}/24/animations"                                             "${THEME_DIR}/24/animations"
ln -sr "${THEME_DIR}/24/panel"                                                  "${THEME_DIR}/24/panel"

ln -sr "${THEME_DIR}/16"                                                        "${THEME_DIR}/16@2x"
ln -sr "${THEME_DIR}/22"                                                        "${THEME_DIR}/22@2x"
ln -sr "${THEME_DIR}/24"                                                        "${THEME_DIR}/24@2x"
ln -sr "${THEME_DIR}/scalable"                                                  "${THEME_DIR}/scalable@2x"

cp -r "${SRC_DIR}/src/cursors/dist"                                             "${THEME_DIR}/cursors"
gtk-update-icon-cache "${THEME_DIR}"                                            > /dev/null 2>&1