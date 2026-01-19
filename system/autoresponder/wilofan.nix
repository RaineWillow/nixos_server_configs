{ ... }: {
  services.fancontrol-client = {
    enable = true;
    serverAddress = "192.168.122.1:26232";
  };
}
