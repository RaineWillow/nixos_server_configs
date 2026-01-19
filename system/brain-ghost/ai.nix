{ ... }: {
  services.open-webui = {
    enable = true;
    # Use the tailscale ip
    host = "100.81.155.79";
    environment = {
      OLLAMA_API_BASE_URL = "http://autoresponder.halfmoon-mixolydian.ts.net:11434";
    };
  };
}
