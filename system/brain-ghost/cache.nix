{ config, ... }: {
  # Serve the nix store over HTTP
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = "/var/lib/nix-serve/cache-priv-key.pem";
  };

  # Open firewall for nix-serve
  networking.firewall.allowedTCPPorts = [ 5000 ];

  # Use autoresponder as a binary cache
  nix.settings = {
    substituters = [ "http://10.0.0.2:5000" ];
    trusted-public-keys = [ "autoresponder:cache:IeEWx3ykSpytCgG2bwhr1OUMvUPaMEZDTrFKiO83VyA=" ];
  };
}
