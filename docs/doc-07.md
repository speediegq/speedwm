
## 8. Signals

Thanks to the 'fsignal' patch available on suckless.org's website, we can easily write shell scripts to interact with dwm and therefore speedwm.
I made some changes to this patch, because it has some.. questionable behaviour in my opinion.

To use signals, you can use libspeedwm. Previously, speedwm-utils (part of speedwm-extras) would be used but that now depends on libspeedwm anyway. Using libspeedwm directly is the easiest option.

If you do not have speedwm-extras or libspeedwm, you can use the speedwm binary itself. The syntax is speedwm -s "#cmd:<signum>"
This option is not as solid though as signums can and will likely be moved around breaking your scripts. Therefore I highly recommend you use libspeedwm when writing scripts.

Below is a list of all signums and what they do.

