{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wireplumber;

  match_type = types.submodule {
    options = {
      property = mkOption {
        type = types.str;
        example = "device.name";
        description = mdDoc ''
          The property of the device or node to test.
          Use `wpctl inspect` to find properties and their values.
        '';
      };

      matches = mkOption {
        type = types.str;
        example = "alsa_card.*";
        description = ''
          Pattern to match property against.
          
        '';
      };
    };
  };

  rule_type = types.submodule {
    options = {
      matches = mkOption {
        type = types.listOf (types.listOf (types.listOf str));
        default = [];
        example = literalExpression ''
          [ [ [ "device.name" "matches" "alsa_card.*" ]
              [ "alsa.driver_name" "equals" "snd_hda_intel" ],
            ]
            [ [ "node.name" "matches" "alsa_output.*" ]
            ]
          ]
        '';
        description = ''
          A list of lists of rules. On the first level, the rules are ORed
          together, so any rule match is going to apply the properties.
          On the second level, the rules are merged with AND,
          so they must all match.
          A rule is a list of exactly 3 strings, where the middle element
          is either "equals" or "matching".
        '';
      };
    };
  };
in {
  options.services.wireplumber = {
    enable = mkEnableOption "Multimedia service session manager daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.wireplumber;
      defaultText = literalExpression "pkgs.wireplumber";
      description = mdDoc "The wireplumber derivation to use.";
    };

    pipewireService = mkOption {
      type = types.str;
      default = "pipewire.service";
      description = mdDoc "Systemd pipewire service name. Used to define systemd ordering.";
    };

    config.enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      defaultText = literalExpression "true";
      description = mdDoc ''
        Whether to manage user-level WirePlumber configuration.
        Can be enabled independently of
        <literal>services.wireplumber.enable</literal>
      '';
    };


    config.extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = literalExpression ''
        context.properties = {
          application.name = WirePlumber
          log.level = 2
        }
      '';
      description = ''
        Extra configuration lines to append to the wireplumber
        main configuration file.
      '';
    };

    config.extraLuaConfig = mkOption {
      type = types.lines;
      default = "";
      example = literalExpression ''
        table.insert (alsa_monitor.rules, {
          matches = { .. },
          apply_properties = { .. }
        })
      '';
      description = ''
        Extra lua configuration script that runs after all
        other home-manager managed scripts.
      '';
    };
  };

  config = {
    home.packages = mkIf cfg.enable [ cfg.package ];

    systemd.user.services.wireplumber = mkIf cfg.enable {
      Unit = {
        Description = "Multimedia Service Session Manager";
        After = [ cfg.pipewireService ];
        BindsTo = [ cfg.pipewireService ];
        Conflicts = [ "pipewire-media-session.service" ];
      };

      Service = {
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "simple";
        ExecStart = "${cfg.package}/bin/wireplumber";
        Restart = "on-failure";
        Slice = "session.slice";
        Environment = "GIO_USE_VFS=local";
      };

      Install = {
        WantedBy = [ cfg.pipewireService ];
        Alias = [ "pipewire-session-manager.service" ];
      };
    };

    xdg.configFile = mkIf cfg.config.enable {
      "wireplumber/wireplumber.conf" = {
        text = ''
          ${cfg.config.extraConfig}
        '';
      };

      "wireplumber/config.lua" = {
        text = ''
          ${cfg.config.extraLuaConfig}
        '';
      };
    };
  };
}
