{ config, pkgs, ... }: {
  boot.kernelModules = [ "nct6775" ];
}
