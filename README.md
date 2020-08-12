Material GTK Framework
======

## Install 

Clone the project then cd into the project folder.

To install the default theme (palenight) then run: 

```shell script
./main.sh -i
```

To install a theme by name (e.g. Amarena) run:

```shell script
./main.sh -t amarena -i
```

## Available themes

- `palenight` (this is the default theme)
- `amarena`
- `gruvterial`

### Options

- `-h` Show script usage
- `-v` Show output
- `-i` Install
- `-c` Recompile theme
- `-f` Force png asset recompilation
- `-o` Install theme icon set
- `-s` Switch theme/icons active after install
- `-t theme-name` Pick a theme to compile or install
- `-n theme-name` Create a new theme config
- `-x style-name` Create a new theme style
- `-d /path/to/dir` Pick a custom dir to install the theme to
- `-p /path/to/dir` Pick a custom dir to install icons to

Therefore, the following:

```shell script
./main.sh -t amarena -ios
```

Will install the Amarena theme and icon set and switch them active upon completion

## Hacking

For recompilation of assets you will need:
- sassc
- inkscape
- optipng

To create your own colour scheme, run the following:

```shell script
./main.sh -n my-awesome-theme
```

This will create a new file in the `themes` directory with the same name as your theme, you can then modify the 
variables within it to your liking.

To recompile gtk2, gtk3 and gnome-shell styles run:
```shell script
./main.sh -t my-awesome-theme -c
```

To automatically switch to this theme on completion run:
```shell script
./main.sh -t my-awesome-theme -cios
```

To force asset recompilation use the `-f` option
```shell script
./main.sh -t my-awesome-theme -ciosf
```

#### Advanced

You can create your own base style to which themes are applied, doing this is more involved and you will 
need to know scss/css.

To create your own base style run the following:
```shell script
./main.sh -x my-awesome-style
```

Before compiling, make sure that the `THEME_STYLE` var in your theme config points to your new style. I.e.

```shell script
THEME_STYLE="my-awesome-style"
```

### Theme Variables

| Name                              | Options           | Usage                                                                 |
|-----------------------------------|-------------------|-----------------------------------------------------------------------|
| `THEME_VARIANT`                   | light/dark        | Adjusts colouring for light vs dark themes                            |
| `THEME_LAPTOP_MODE`               | true/false        | Modifies the amount of padding on things such as title bars           |
| `THEME_HEADER_BAR`                | light/dark        | Currently not in use                                                  |
| `THEME_PANEL`                     | light/dark        | Adjusts the gnome-shell panel for light vs dark themes                |
| `THEME_STYLE`                     | material          | Select which source files to build from                               |
| `THEME_COLOUR_BACKGROUND`         | Hex colour code   | Background                                                            |
| `THEME_COLOUR_FOREGROUND`         | Hex colour code   | Accented background                                                   |
| `THEME_COLOUR_DIVIDER`            | Hex colour code   | Panel division                                                        |
| `THEME_COLOUR_COMMENT`            | Hex colour code   | Sliders, toggle button, checkboxes, radiobuttons, choice highlights   |
| `THEME_COLOUR_DANGER`             | Hex colour code   | Window close button, general error                                    |
| `THEME_COLOUR_MID_DANGER`         | Hex colour code   | Warning colour for some applications                                  |
| `THEME_COLOUR_WARNING`            | Hex colour code   | Alt primary colour and window minimize button                         |
| `THEME_COLOUR_SUCCESS`            | Hex colour code   | "Okay" type buttons, Sliding switches, filled in area in sliders      |
| `THEME_COLOUR_INFO`               | Hex colour code   | Hover over some types of text buttons                                 |
| `THEME_COLOUR_DARK_INFO`          | Hex colour code   | Currently not in use                                                  |
| `THEME_COLOUR_TEXT`               | Hex colour code   | Standard text                                                         |
| `THEME_COLOUR_TEXT_HIGHLIGHT`     | Hex colour code   | Currently not in use                                                  |
| `THEME_COLOUR_ACCENT_PRIMARY`     | Hex colour code   | Link button                                                           |
| `THEME_COLOUR_ACCENT_SECONDARY`   | Hex colour code   | GTK3 theme accent colour                                              |
| `THEME_COLOUR_ACCENT_TERTIARY`    | Hex colour code   | Underlines in the shell (topbar/dock/workspace switcher)              |

Feel free to open a PR with your theme if you want to add it to the project.

## Credit

- [vinceliuice](https://github.com/vinceliuice) - Creator of [vimix-gtk-themes](https://github.com/vinceliuice/vimix-gtk-themes)
which was the base of this project and [vimix-icon-theme](https://github.com/vinceliuice/vimix-icon-theme) which is the
icon set that can be installed with the theme.
- [elenapan](https://github.com/elenapan) - Creator of the [Amarena](https://github.com/elenapan/dotfiles/blob/master/.xfiles/amarena)
colour scheme.
- [JHerseth](https://github.com/JHerseth) - Added the Gruvterial theme, helped find bugs and added documentation.  

### Palenight
![Palenight](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/palenight.png)
![Palenight Widget Factory](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/palenight-widget-factory.png)

### Amerena
![Amarena](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/amarena.png)
![Amarena Widget Factory](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/amarena-widget-factory.png)

### Gruvterial
![Gruvterial](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/gruvterial.png)
![Gruvterial Widget Factory](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/gruvterial-widget-factory.png)
