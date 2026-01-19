{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fancontrol-client;
in
{
  options.services.fancontrol-client = {
    enable = mkEnableOption "GPU fan control client (temperature reporter)";

    package = mkOption {
      type = types.package;
      default = pkgs.fancontrol or (throw "fancontrol package not found - ensure it's built in your flake");
      description = "The fancontrol package to use";
    };

    serverAddress = mkOption {
      type = types.str;
      example = "192.168.122.1:26232";
      description = "Address of the fan control server (IP:port)";
    };

    interval = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "Seconds between temperature reports";
    };

    logLevel = mkOption {
      type = types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "Log level for the client";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fancontrol-client = {
      description = "GPU Fan Control Client (Temperature Reporter)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "fancontrol-client";
      };

      environment = {
        LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
      };

      script = ''
        exec ${cfg.package}/bin/nvidia-client \
          --verbosity ${cfg.logLevel} \
          --interval ${toString cfg.interval} \
          ${cfg.serverAddress}
      '';
    };
  };
}
