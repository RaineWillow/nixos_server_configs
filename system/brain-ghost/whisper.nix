{ pkgs, lib, ... }:
let
  port = 28535;
in
{
  services.wyoming.faster-whisper.servers.whisper = {
    enable = true;
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
