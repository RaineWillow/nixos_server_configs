{ ... }: {
  # Network settings
  networking = {
    # Disable dhcp by default
    useDHCP = false;
    # Use systemd-networkd
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
  };
  systemd.network = {
    networks."10-wan" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = false;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
  # Enable tailscale
  services.tailscale.enable = true;
}
