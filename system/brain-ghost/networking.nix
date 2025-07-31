{ ... }: {
  # Network settings
  networking = {
    hostName = "brain-ghost"; # Define your hostname.
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  # Enable tailscale
  services.tailscale.enable = true;
}
