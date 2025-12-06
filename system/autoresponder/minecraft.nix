{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-oracle_17
  ];
  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
  users.users.foxcraft = {
    isNormalUser = true; # Definitely not true but okay
    hashedPassword = "!";
    openssh.authorizedKeys.keys = config.users.users.jade.openssh.authorizedKeys.keys ++
      config.users.users.willow.openssh.authorizedKeys.keys;
    linger = true;
  };
}
