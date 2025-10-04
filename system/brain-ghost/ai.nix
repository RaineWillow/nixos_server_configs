{ ... }: {
  services.open-webui = {
    enable = true;
    # Use the tailscale ip
    host = "100.81.155.79";
    environment = {
      OLLAMA_API_BASE_URL = "http://100.127.78.38:11434";
    };
  };
}
