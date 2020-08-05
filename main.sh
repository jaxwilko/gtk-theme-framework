#!/usr/bin/env bash

usage() {
    cat << NOTICE
    OPTIONS
    -h      show this message
    -v      print verbose info
    -f      force asset recompilation
    -c      compile theme
    -i      automatically install theme after completion
    -is     automatically set the theme/icons active after install
    -o      automatically icons theme after completion
    -n      create a new theme template file
NOTICE
}

say() {
    [ "$VERBOSE" ] || [ "$2" ] && echo "==> $1"
}

VERBOSE=""
FORCE=""
INSTALL=""
COMPILE=""
SET_THEME_ACTIVE=""
INSTALL_ICONS=""
NEW_THEME=""
THEME_NAME="palenight"

while getopts hvficost:n: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        f) FORCE=1 ;;
        i) INSTALL=1 ;;
        c) COMPILE=1 ;;
        s) SET_THEME_ACTIVE=1 ;;
        o) INSTALL_ICONS=1 ;;
        t) THEME_NAME=${OPTARG} ;;
        n) NEW_THEME=${OPTARG} ;;
        *);;
    esac
done

if [ ! -f "./themes/${THEME_NAME}.sh" ]; then
    say "Could not find theme ${THEME_NAME}" "true"
    exit 1
fi

if [ "$NEW_THEME" ]; then
    if [ -f "./themes/${NEW_THEME}.sh" ]; then
        say "Theme ${NEW_THEME} already exists, please pick another name" "true"
        exit 1
    fi
    cp "./themes/palenight.sh" "./themes/${NEW_THEME}.sh"
    exit 0
fi

if [ "$COMPILE" ]; then
     [[ "$VERBOSE" ]] && FLAG="-v" || FLAG=""
     [[ "$FORCE" ]] && FLAG="$FLAG -f"
    sh -c "./scripts/compile.sh $FLAG"
fi

if [ "$INSTALL" ]; then
     [[ "$VERBOSE" ]] && FLAG="-v" || FLAG=""
     [[ "$SET_THEME_ACTIVE" ]] && FLAG="$FLAG -s"
     [[ "$INSTALL_ICONS" ]] && FLAG="$FLAG -o"
    sh -c "./scripts/install.sh $FLAG"
fi