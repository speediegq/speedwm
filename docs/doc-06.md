## 7. Configuration and .Xresources

speedwm has .Xresources support thanks to the .Xresources patch. It also has pywal support (tool which grabs colors based on your wallpaper).

To configure speedwm, you may /usr/share/speedwm/example.Xresources to either ~/.speedwmrc or ~/.config/speedwm/speedwmrc. Alternatively, you can also copy the values to your .Xresources file.

.speedwmrc or speedwm/speedwmrc will be loaded when speedwm restarts. If you want to load a .Xresources file you'll need to add that to autostart.sh.

Colors do not reload automatically though, you must reload them manually. Use a signal for this (See list of signals above) or simply 'libspeedwm --perform core_wm_reload'. This won't restart speedwm, but it will reload colors.

To use .Xresources, make sure 'xrdb' is installed. If a .xinitrc is used, add 'xrdb /path/to/.Xresources/file' before 'speedwm'. If a .Xresources file is not used, add it to ~/.config/speedwm/autostart.sh instead.

If you don't want to define the options manually, there is an example .Xresources file containing speedwm default settings in docs/example.Xresources. You can copy this somewhere or you can simply '< docs/example.Xresources >> ~/.Xresources' to append the speedwm options to your .Xresources file.

The magic of .Xresources is that it is a universal configuration file. While you *can* use the col.value values, you can also use traditional colors 0 through 15 as well. These colors take priority over regular speedwm colors. This is so that speedwm is compatible with Pywal and more general/mainstream .Xresources configurations.

Below is a list of all .Xresources values you can define.

