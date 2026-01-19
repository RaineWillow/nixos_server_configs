{ config, ... }:
let
  tailscale_domain = "halfmoon-mixolydian.ts.net";
in
{
  services.open-webui = {
    enable = true;
    # Use the tailscale ip
    host = "brain-ghost.${tailscale_domain}";
    port = 1111;
    environment = {
      OLLAMA_API_BASE_URL = "http://autoresponder.${tailscale_domain}:11434";
    };
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ config.services.open-webui.port ];
}
