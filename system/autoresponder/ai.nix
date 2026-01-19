{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda.override {
      cudaPackages = pkgs.cudaPackages_12_2;
    };
    openFirewall = true;
    loadModels = [
      "qwen3-vl:32b"
    ];
  };
}
