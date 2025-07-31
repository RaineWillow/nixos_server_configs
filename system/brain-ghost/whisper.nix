{ ... }: {
  services.wyoming.faster-whisper.servers.whisper = {
    enable = true;
    device = "cuda";
    model = "large-v3";
    # TODO: id like it to support en, nl, jp, de but we can restrict it to en if wilo wants
    language = "auto";
  };
}
