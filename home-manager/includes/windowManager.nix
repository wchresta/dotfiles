{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.monoid.windowManager;

  gruvbox = import ../gruvbox.nix {};

  nerd-fira-code = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };

  useX11 = cfg.compositor == "i3";
  useWayland = !useX11;
  useI3 = cfg.compositor == "i3";
  useHyprland = cfg.compositor == "hyprland";
in {
  imports = [
    # Leads to infinite recursion, not sure why
    # inputs.hyprland.homeManagerModules.default
  ];

  options.monoid.windowManager = {
    enable = mkEnableOption "Manage window manager";

    compositor = mkOption {
      type = types.enum [ "i3" "hyprland" ];
      default = "i3";
      description = ''
        Window manager to use. Also implies whether to use X11 or Wayland.
      '';
    };
  };

  config = mkIf cfg.enable {
    # i3bar needs some fonts
    home.packages = with pkgs; [ nerd-fira-code ];

    xsession.enable = useX11;
    xsession.windowManager.i3 = mkIf useI3 rec {
      enable = true;

      package = pkgs.i3-gaps;

      config = rec {
        modifier = "Mod4";

        terminal = "kitty";

        gaps = {
          outer = 10;
          inner = 3;

          smartBorders = "on";
          smartGaps = true;
        };

        colors = {
          background = gruvbox.dark1;
          focused = {
            border = gruvbox.dark3;
            background = gruvbox.dark1;
            childBorder = gruvbox.dark3;
            indicator = gruvbox.dark3;
            text = gruvbox.light1;
          };
          focusedInactive = {
            border = gruvbox.dark1;
            background = gruvbox.dark1;
            childBorder = gruvbox.dark1;
            indicator = gruvbox.dark1;
            text = gruvbox.light2;
          };
          unfocused = {
            border = gruvbox.dark1;
            background = gruvbox.dark1;
            childBorder = gruvbox.dark2;
            indicator = gruvbox.light2;
            text = gruvbox.light2;
          };

        };

        bars = [
          {
            mode = "dock";
            hiddenState = "hide";
            position = "bottom";
            workspaceButtons = true;
            workspaceNumbers = true;

            statusCommand = "${pkgs.i3status}/bin/i3status";
            trayOutput = "primary";

            fonts = {
              names = [ "Fira Code Regular" ];
              size = 10.0;
            };

            colors = {
              background = gruvbox.dark0;
              statusline = gruvbox.light1;
              separator = gruvbox.dark2;

              focusedWorkspace = { border = gruvbox.neutral_blue; background = gruvbox.neutral_blue; text = gruvbox.light1; };
              activeWorkspace = { border = gruvbox.bright_blue; background = gruvbox.bright_blue; text = gruvbox.light1; };
              inactiveWorkspace = { border = gruvbox.dark2; background = gruvbox.dark2; text = gruvbox.light1; };
              urgentWorkspace = { border = gruvbox.neutral_red; background = gruvbox.neutral_red; text = gruvbox.dark2; };
            };
          }
        ];

        startup = let
          emre-flower = builtins.fetchurl {
            name = "emre-flower.jpg";
            url = "https://unsplash.com/photos/EfyQXFzu8Nw/download";
            sha256 = "1ls6yg13nayjsr6i1dmi1kwhhfyidn0vjri0m076bpfjw85z9a6k";
          };
        in [
          { command = "${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 1920x1080 --pos 0x1080 --output DP-4 --primary --mode 3840x2160 --pos 1920x0";
            notification = false;
          }
          { command = "${pkgs.feh}/bin/feh --bg-fill ${emre-flower}";
            notification = false;
          }
          { command = "${pkgs.xorg.xset}/bin/xset s 720";
            notification = false;
          }
          { command = "${pkgs.xorg.xset}/bin/xset dpms 720 600 720";
            notification = false;
          }
        ];

        keybindings = let
          mod = modifier;

          workspaces = map toString [1 2 3 4 5 6 7 8 9 0];
          mkMoveCmd = (ws: {
              name = "${mod}+${ws}";
              value = "[workspace=${ws}] move workspace to output current, workspace ${ws}";
            });
          myMoves = builtins.listToAttrs (map mkMoveCmd workspaces);
        in lib.mkOptionDefault ({
          "${mod}+x" = "exec kitty";
          "${mod}+d" = ''exec "rofi -show run -modi run,drun,ssh"'';
          "${mod}+f" = "exec firefox";
          "${mod}+t" = "exec steam";
          "${mod}+q" = "kill";
          "${mod}+space" = "fullscreen";
          "${mod}+p" = "exec pavucontrol";

          # Pulse Audio controls
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%"; # increase sound volume
          "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%"; # decrease sound volume
          "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle"; # mute sound
        } // (
          # Only define light-control actions if it exists in pkgs. Otherwise, use real brightnesscontrol
          if pkgs ? light-control then {
            # Hue light control
            "F7" = "exec --no-startup-id ${pkgs.light-control}/bin/light-control bri-down";
            "F8" = "exec --no-startup-id ${pkgs.light-control}/bin/light-control bri-up";
            "XF86MonBrightnessUp" = "exec --no-startup-id ${pkgs.light-control}/bin/light-control bri-up";
            "XF86MonBrightnessDown" = "exec --no-startup-id ${pkgs.light-control}/bin/light-control bri-down";
          } else {
            "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
            "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
          }
        ) // myMoves);
      };
    };

    # Make sure nautilus is used to open directories
    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };

    programs.rofi = {
      enable = true;
      theme = "gruvbox-dark";
    };

    programs.i3status = mkIf useI3 {
      enable = true;
      enableDefault = false;

      general = {
        colors = true;
        color_good = gruvbox.bright_green;
        color_degraded = gruvbox.bright_purple;
        color_bad = gruvbox.bright_red;
        interval = 1;
      };

      modules = {
        "volume master" = {
          position = 1;
          settings = {
            format = "♪: %volume";
            format_muted = "♪: muted (%volume)";
            device = "default";
            mixer = "Master";
            mixer_idx = 0;
          };
        };

        ipv6 = { position = 2; };

        /*
        "wireless _first_" = {
          position = 2;
          settings = {
            format_up = "W: (%quality at %essid) %ip";
            format_down = "W: down";
          };
        };
        */

        "ethernet _first_" = {
          position = 4;
          settings = {
            format_up = "E: %ip (%speed)";
            format_down = "E: down";
          };
        };

        "disk /" = {
          position = 5;
          settings = {
            format = "/ %avail";
            low_threshold = 75;
            threshold_type = "gbytes_avail";
          };
        };

        "disk /boot/" = {
          position = 6;
          settings = {
            format = "/b %avail";
            low_threshold = 20;
            threshold_type = "mbytes_avail";
          };
        };

        "disk /home/monoid/otherhome/" = {
          position = 7;
          settings = { format = "~2 %avail"; };
        };


        load = {
          position = 8;
          settings = { format = "load %1min"; };
        };

        memory = {
          position = 9;
          settings = {
            format = "mem %used / %available";
            threshold_degraded = "1G";
            format_degraded = "MEMORY < %available";
          };
        };

        "tztime local" = {
          position = 10;
          settings = { format = "%Y-%m-%d %H:%M:%S"; };
        };
      };
    };

    systemd.user.services.setxkbmap-custom = mkIf useX11 {
      Unit = {
        Description = "Set up keyboard in X";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "xset r rate 200 90";
      };
    };

    # Can't use this until we figure out
    # infinite recursion when importing the hm module.
    # wayland.windowManager.hyprland = mkIf useHyprland {
    #   enable = true;
    # };
  };
}

