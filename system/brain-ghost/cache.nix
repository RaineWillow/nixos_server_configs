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
    substituters = [ "http://192.168.122.228:5000" ];
    trusted-public-keys = [ "autoresponder:IeEWx3ykSpytCgG2bwhr1OUMvUPaMEZDTrFKiO83VyA=" ];
  };
}
