#: Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # ====== COMMON STUFF =======
      # Common configs to make the system run well
      ../common/nix.nix
      ../common/jade-preferences.nix
      # ====== HOST SPECIFIC STUFF =======
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Networking config
      ./networking.nix
      # Nvidia stuff
      ./nvidia.nix
      # LLM stuff 
      ./ai.nix
      # Custom willow fan daemon
      ./wilofan.nix
      # Minecraft
      ./minecraft.nix
    ];
  # Set machine name here
  networking.hostName = "autoresponder";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Disable audio drivers
  # For accessing ACPI related stuff
  services.acpid.enable = true;
  # This is an AMD system
  hardware.cpu.amd.updateMicrocode = true;

  # This machine is in MA
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # This makes it so you change passwords with the hash here and not manually
  users.mutableUsers = false;
  users.users = {
    jade = {
      isNormalUser = true;
      hashedPassword = "$6$rounds=25000$OhnKyrVBL2vq8wmr$g.44VDLmx.N6NjS4GzbquqHtaxXJEXVwxYAponGRuuOJIzTm6BhR2f2fIx8JEJUsBFtDlQHZiBO9Lvln0AxGT.";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ81DLRnb10XRpTTtHD56h4ciXqCeKnuQIDls/0uJ5R" ];
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
    willow = {
      isNormalUser = true; # Definitely not true but okay
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      hashedPassword = "$6$rounds=25000$9EIzPG6oIRxQ64i1$Js4DyQrRz6LyD1ty.TGcBOg..x8AT4QLno7Uta4O14QqT0o.gS61Heco8XX.kcY5KlYgjOdcMnGqlu1dadqMw0";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIORqal69EoLu+l3d1vvrK2uDwIdrLmIJYitdpIAw4XeO wilofox@maryam" ];
    };
  };
  # Extra packages to install to system prefix
  environment.systemPackages = with pkgs; [ ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

