{ config, pkgs, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia = {
    #open = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    modesetting.enable = true;
    nvidiaSettings = false;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    nvidia.acceptLicense = true;
  };
}
