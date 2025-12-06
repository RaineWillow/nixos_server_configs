{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-oracle_17
  ];
  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
  users.users.foxcraft = let anna_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMEP1g9ZzmvP1wMn8xULpW6RsAy0GsoJP9/0nowu9mD annaa@nixos-coronation"; in {
    isNormalUser = true; # Definitely not true but okay
    hashedPassword = "!";
    openssh.authorizedKeys.keys = config.users.users.jade.openssh.authorizedKeys.keys ++
      config.users.users.willow.openssh.authorizedKeys.keys ++ [ anna_key ];
    linger = true;
  };
}
