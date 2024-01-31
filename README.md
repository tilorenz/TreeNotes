### DISCLAIMER: This software is provided without any warranty. It *should* work, but if it eats your files, it won't be my problem. Make regular backups of your notes when using it.

# TreeNotes
A sticky notes Plasmoid (desktop widget) for the [KDE Plasma desktop](https://kde.org/plasma-desktop/), featuring an expandable directory tree.
My [previous attempt](https://github.com/tilorenz/DirNotes) never really worked well, so I decided to rewrite it from scratch for Plasma 6.

![image](https://github.com/tilorenz/TreeNotes/assets/59516401/1a5ed5ae-5fce-4b67-9f0f-ff3af8bb8e87)


## Installation
- Clone the repo: `git clone https://github.com/tilorenz/TreeNotes.git`
- `cd TreeNotes`
- `mkdir build && cd build`
- create the build system: `cmake -GNinja ..`
- build the plugin (the C++ part): `ninja`
- install it: `sudo ninja install`
- install the package (the QML part): `kpackagetool6 -i ../package/ -t Plasma/Applet`

## Development
To install to a non-systemwide location (if you're building your own plasma), take a look at `configure_cmake.sh` (you'll probably need to adapt the paths).

You can use `plasmoidviewer -a ./package` to view the plasmoid without installing the package.

## TODO
- context menu entries for rename and delete/trash
- icons in file tree and context menu
- make file tree fill its horizontal space
- once I'm confident the plasmoid is stable and doesn't eat files (and plasma 6 is released?): package it
    - probably AUR would be the easiest / most sensible
- consider i18n
- find a text area with proper (that is, interactive) markdown rendering
- maybe add an option for a root path where the cdUp button stops?
- better handling of too large files: check size first, if too large, set path to "" or the previous path and show error popup

## Known issues
- The lines on the tree are indented too far; this was an issue in KDE's desktop style and is already fixed on master

