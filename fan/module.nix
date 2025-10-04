{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fancontrol;

  # Convert NixOS config to TOML format
  configFile = pkgs.writeText "fancontrol.toml" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (profileName: profile:
          let
            curveEntries = lib.concatStringsSep "\n" (
              map
                (point: ''
                  [[${profileName}.curve]]
                  temperature = ${toString point.temperature}
                  speed = ${toString point.speed}
                '')
                profile.curve
            );
            fanEntries = lib.concatStringsSep "\n" (
              map
                (fan: ''
                  [[${profileName}.fan]]
                  hwmon = ${toString fan.hwmon}
                  fan = ${toString fan.fan}
                '')
                profile.fans
            );
          in
          curveEntries + "\n" + fanEntries
        )
        cfg.profiles
    )
  );

in
{
  options.services.fancontrol = {
    enable = mkEnableOption "GPU fan control daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.fancontrol or (throw "fancontrol package not found - ensure it's built in your flake");
      description = "The fancontrol package to use";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "IP address to listen on for temperature reports";
    };

    listenPort = mkOption {
      type = types.port;
      default = 26232;
      description = "Port to listen on for temperature reports";
    };

    logLevel = mkOption {
      type = types.enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "Log level for the fan control daemon";
    };

    profiles = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          fans = mkOption {
            type = types.listOf (types.submodule {
              options = {
                hwmon = mkOption {
                  type = types.ints.u16;
                  description = "Hardware monitor number (e.g., 1 for hwmon1)";
                };
                fan = mkOption {
                  type = types.ints.u16;
                  description = "Fan PWM number (e.g., 3 for pwm3)";
                };
              };
            });
            description = "List of fans controlled by this profile";
          };

          curve = mkOption {
            type = types.listOf (types.submodule {
              options = {
                temperature = mkOption {
                  type = types.number;
                  description = "Temperature threshold in Celsius";
                };
                speed = mkOption {
                  type = types.ints.between 0 255;
                  description = "Fan speed (0-255 PWM value)";
                };
              };
            });
            description = "Temperature curve points for fan control";
          };
        };
      });
      default = { };
      example = {
        nvidia = {
          fans = [
            { hwmon = 1; fan = 3; }
            { hwmon = 1; fan = 5; }
          ];
          curve = [
            { temperature = 29; speed = 0; }
            { temperature = 92; speed = 255; }
          ];
        };
      };
      description = "Fan control profiles mapping profile names to fan configurations";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to run the fancontrol service as";
    };

    group = mkOption {
      type = types.str;
      default = "root";
      description = "Group to run the fancontrol service as";
    };
  };

  config = mkIf cfg.enable {
    # Only create user/group if not running as root
    users.users = mkIf (cfg.user != "root") {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "Fan control daemon user";
      };
    };

    users.groups = mkIf (cfg.group != "root") {
      ${cfg.group} = { };
    };

    # Systemd service definition
    systemd.services.fancontrol = {
      description = "GPU Fan Control Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        # Minimal restrictions for root access to hardware
        PrivateDevices = false; # Need access to hwmon devices
        ProtectKernelTunables = false; # Need to write to hwmon

        # Restart on failure
        Restart = "always";
        RestartSec = "5s";

        # Logging
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "fancontrol";
      };

      script = ''
        exec ${cfg.package}/bin/fan-server \
          --verbosity ${cfg.logLevel} \
          --listen ${cfg.listenAddress} \
          --port ${toString cfg.listenPort} \
          ${configFile}
      '';
    };

    # udev rules not needed when running as root
    services.udev.extraRules = mkIf (cfg.user != "root") ''
      # Allow fancontrol group to access hwmon devices
      SUBSYSTEM=="hwmon", GROUP="${cfg.group}", MODE="0664"
      SUBSYSTEM=="hwmon", KERNEL=="hwmon*", GROUP="${cfg.group}", MODE="0664"
      # Allow access to PWM controls
      SUBSYSTEM=="hwmon", ATTR{pwm*}=="*", GROUP="${cfg.group}", MODE="0664"
      SUBSYSTEM=="hwmon", ATTR{pwm*_enable}=="*", GROUP="${cfg.group}", MODE="0664"
    '';

    # Ensure the service has network access for UDP listening
    networking.firewall.allowedUDPPorts = mkIf (cfg.listenAddress != "127.0.0.1") [ cfg.listenPort ];
  };
}
