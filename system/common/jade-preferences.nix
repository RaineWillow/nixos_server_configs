{ pkgs, ... }: {
  # Push some of systemd to initrd
  boot.initrd.systemd.enable = true;
  # Use zram swap
  zramSwap.enable = true;
  # Clean up /tmp on boot
  boot.tmp.cleanOnBoot = true;
  # Userborn manages users better
  services.userborn.enable = true;
  # Bash completion is nice
  programs.bash.completion.enable = true;
  # Stuff i like to have on a system by default
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
}
