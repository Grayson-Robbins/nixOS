
{ pkgs, ... }:

{
  programs.niri.settings = {
    # Keyboard
    input.keyboard.xkb.layout = "us";

    # Layout
    layout = {
      gaps = 8;
    };

    # Environment
    environment.NIXOS_OZONE_WL = "1";

    # Keybindings
    binds = {
      # Applications
      "Mod+Q".action.spawn = "${pkgs.kitty}/bin/kitty";
      "Mod+D".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";
      "Mod+R".action.spawn = [
        "${pkgs.wofi}/bin/wofi"
        "--show" 
        "drun" 
        "--allow-images"
      ];
      # Window management
      "Mod+C".action.close-window = [ ];

      # Niri
      "Mod+O".action.show-hotkey-overlay = [ ];

      # Quit Niri
      "Mod+Shift+E".action.quit = [ ];

      # Focus navigation
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Down".action.focus-window-down = [ ];

      # Workspace navigation
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;

      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
    };
  };

  home.packages = with pkgs; [
    fuzzel
    wofi
    kitty
  ];
}

