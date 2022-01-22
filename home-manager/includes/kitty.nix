{ pkgs, ... }:

let
  gruvbox = import ../gruvbox.nix {};
in {
  programs.kitty = {
    enable = true;

    # Use nerdfonts but onlz select FiraCode, otherwise building takes long
    font.package = pkgs.nerdfonts.overrideAttrs (args: args // { fonts = [ "FiraCode" ]; });
    font.name = "Fira Code Regular 12";

    settings = {
      background = gruvbox.dark0;
      foreground = gruvbox.light1;

      selection_background = gruvbox.light1;
      selection_foreground = gruvbox.dark0;

      cursor = gruvbox.light4;
      cursor_text_color = "background";

      active_tab_background = gruvbox.dark0;
      active_tab_foreground = gruvbox.light1;
      active_tab_font_style = "bold";
      inactive_tab_background = gruvbox.dark0;
      inactive_tab_foreground = gruvbox.light4;
      inactive_tab_font_style = "normal";

      # Black
      color0 = gruvbox.dark3;
      color8 = gruvbox.gray_244;

      # Red
      color1 = gruvbox.neutral_red;
      color9 = gruvbox.bright_red;

      # Green
      color2 = gruvbox.neutral_green;
      color10 = gruvbox.bright_green;

      # Yellow
      color3 = gruvbox.neutral_yellow;
      color11 = gruvbox.bright_yellow;

      # Blue
      color4 = gruvbox.neutral_blue;
      color12 = gruvbox.bright_blue;

      # Magenta
      color5 = gruvbox.neutral_purple;
      color13 = gruvbox.bright_purple;

      # Cyan
      color6 = gruvbox.neutral_aqua;
      color14 = gruvbox.bright_aqua;

      # White
      color7 = gruvbox.light1;
      color15 = gruvbox.light1;
    };
  };
}
