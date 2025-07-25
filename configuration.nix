# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./libvirt.nix
      ./wilofan.nix
      ./jade/planes.nix
    ];

  nix = {
    package = pkgs.lix;
    gc = {
      automatic = true;
      persistent = true;
    };
    settings = {
      sandbox = true;
      auto-optimise-store = true;
      trusted-users = lib.mkAfter [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  services.acpid.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  networking = {
    hostName = "brain-ghost"; # Define your hostname.
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  services.userborn.enable = true;
  users.mutableUsers = false;
  users.users.jade = {
    isNormalUser = true;
    hashedPassword = "$6$rounds=25000$OhnKyrVBL2vq8wmr$g.44VDLmx.N6NjS4GzbquqHtaxXJEXVwxYAponGRuuOJIzTm6BhR2f2fIx8JEJUsBFtDlQHZiBO9Lvln0AxGT.";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ81DLRnb10XRpTTtHD56h4ciXqCeKnuQIDls/0uJ5R" ];
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  users.users.willow = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$rounds=25000$9EIzPG6oIRxQ64i1$Js4DyQrRz6LyD1ty.TGcBOg..x8AT4QLno7Uta4O14QqT0o.gS61Heco8XX.kcY5KlYgjOdcMnGqlu1dadqMw0";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIORqal69EoLu+l3d1vvrK2uDwIdrLmIJYitdpIAw4XeO wilofox@maryam" ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tmux
    git
    vim
    bind
    file
    gptfdisk
    htop
    man-pages
    mkpasswd
    openssl
    pv
    progress
    ripgrep
    alacritty.terminfo
    kitty.terminfo
    tcpdump
    aria2
    curl
    wget
    unzip
    zip
    p7zip
    w3m
    dnsutils
    dmidecode
    pciutils
    usbutils
  ];
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };
  programs.bash.completion.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}

