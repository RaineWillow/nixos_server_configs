# Stuff for an ADSB dongle
# to watch plane data
{ config, pkgs, ... }: {
  boot.blacklistedKernelModules = [
    "dvb_usb_rtl28xxu"
  ];
  users.users.jade.extraGroups = [ "plugdev" ];
}
