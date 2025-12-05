{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-oracle
  ];
  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
}
