{ config, pkgs, ... }: {
  boot.blacklistedKernelModules = [
    "dvb_usb_rtl28xxu"
  ];
}
