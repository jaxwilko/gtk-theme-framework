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

### Options

- `-h` Show script usage
- `-v` Show output
- `-i` Install
- `-c` Recompile theme
- `-f` Force png asset recompilation
- `-o` Install theme icon set
- `-s` Switch theme/icons active after install
- `-n theme-name` Create a new theme config

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

Feel free to open a PR with your theme if you want to add it to the project.

## Credit

- [vinceliuice](https://github.com/vinceliuice) - Creator of [vimix-gtk-themes](https://github.com/vinceliuice/vimix-gtk-themes)
which was the base of this project and the [vimix-icon-theme](https://github.com/vinceliuice/vimix-icon-theme) which is the
icon set that can be installed with the theme.
- [elenapan](https://github.com/elenapan) - Creator of the [Amarena](https://github.com/elenapan/dotfiles/blob/master/.xfiles/amarena)
colour scheme.


### Palenight
![Palenight](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/palenight.png)
![Palenight Widget Factory](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/palenight-widget-factory.png)

### Amerena
![Amarena](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/amarena.png)
![Amarena Widget Factory](https://raw.githubusercontent.com/JaxWilko/material-gtk-framework/develop/.github/examples/amarena-widget-factory.png)
