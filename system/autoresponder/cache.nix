{ config, ... }: {
  # Serve the nix store over HTTP
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/var/lib/nix-serve/cache-priv-key.pem";
  };

  # Open firewall for nix-serve
  networking.firewall.allowedTCPPorts = [ 5000 ];

  # Use brain-ghost as a binary cache
  nix.settings = {
    substituters = [ "http://192.168.122.1:5000" ];
    trusted-public-keys = [ "brain-ghost:cache:OMxLN2hDV2lcyYZIE3abMh7AYn/qP9W+bWVMhIuj1fk=" ];
  };
}
