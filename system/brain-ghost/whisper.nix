{ pkgs, lib, ... }:
let
  port = 28535;
  wyoming-faster-whisper = pkgs.wyoming-faster.whisper.overrideAttrs (final: prev: rec {
    version = "2.4.0";
    src = final.fetchFromGitHub {
      owner = "rhasspy";
      repo = "wyoming-faster-whisper";
      rev = "refs/tags/v${version}";
      hash = "sha256-Ai28i+2/oWI2Y61x7U5an5MBHfuBaGy6qZZwZydS308=";
    };
  });
in
{
  services.wyoming.faster-whisper.servers.whisper = {
    enable = true;
    package = wyoming-faster-whisper;
    device = "cuda";
    model = "turbo";
    uri = "tcp://0.0.0.0:${builtins.toString port}";
    # TODO: id like it to support en, nl, jp, de but we can restrict it to en if wilo wants
    language = "auto";
  };
  systemd.services.wyoming-faster-whisper-whisper = {
    environment = {
      HF_HUB_CACHE = lib.mkForce "/var/cache/wyoming-faster-whisper";
      HF_XET_CACHE = lib.mkForce "/var/cache/wyoming-faster-whisper/xet";
    };
    serviceConfig.CacheDirectory = "wyoming-faster-whisper";
  };
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ port ];
  };
}
