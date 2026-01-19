{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    openFirewall = true;
    loadModels = [
      "qwen3-vl:32b"
    ];
  };
}
