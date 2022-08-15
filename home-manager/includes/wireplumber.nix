{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wireplumber;
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
        configuration file.
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

    xdg.configFile.wireplumber.text = mkIf cfg.config.enable ''
      ${cfg.config.extraConfig}
    '';
  };
}
