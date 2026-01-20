{ config, pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    openFirewall = false;
    loadModels = [
      "qwen3-vl:32b"
    ];
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ config.services.ollama.port ];
}
