{ config, pkgs, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "550.163.01";
      sha256_64bit = "sha256-74FJ9bNFlUYBRen7+C08ku5Gc1uFYGeqlIh7l1yrmi4=";
      settingsSha256 = "";
      persistencedSha256 = "";
    };
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
