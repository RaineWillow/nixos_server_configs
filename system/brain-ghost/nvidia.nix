{ config, pkgs, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia = {
    # used https://www.nvidia.com/en-us/drivers/results/ to get the most recent driver less than 560
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    modesetting.enable = true;
    nvidiaSettings = false;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cudaCapabilities = [ "6.1" ];
    nvidia.acceptLicense = true;
  };
  nixpkgs.overlays = [
    (final: prev: {
      cudaPackages = final.cudaPackages_13;
    })
  ];
}
