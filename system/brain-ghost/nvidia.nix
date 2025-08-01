{ config, pkgs, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia = {
    # used https://www.nvidia.com/en-us/drivers/results/ to get the most recent driver less than 560
    /*package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "550.163.01";
      sha256_64bit = "sha256-74FJ9bNFlUYBRen7+C08ku5Gc1uFYGeqlIh7l1yrmi4=";
      settingsSha256 = "";
      persistencedSha256 = "";
      };*/
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    modesetting.enable = true;
    nvidiaSettings = false;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config = {
    allowUnfree = true;
    # TODO: enable when cuda works
    #cudaSupport = true;
    # TODO: enable to save compile time
    #cudaCapabilities = [ "6.1" ];
    # TODO: enable when cuda works
    #cudaForwardCompat = false;
    nvidia.acceptLicense = true;
  };
}
