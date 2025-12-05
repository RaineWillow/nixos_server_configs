{ ... }: {
  services.ollama = {
    enable = true;
    openFirewall = true;
    loadModels = [
      "qwen3-vl:32b"
    ];
  };
}
