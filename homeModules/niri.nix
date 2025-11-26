{ config, lib, pkgs, inputs, ... }:

{
  # Import the Home Manager Niri module from the flake
  #imports = [
  #  inputs.niri-flake.homeModules.niri
  #];

  programs.niri = with pkgs; {
    enable = true;

    #package = pkgs.niri-unstable;

    # Declarative configuration using the niri-flake options
    settings = {
      xwayland-satellite = {
        enable = true;
      };
      prefer-no-csd = true;

      outputs = {
        "DP-1" = {
          scale = 1.25;
        };

        "DP-2" = {
          scale = 1.25;
          position = { # This is what puts the left monitor actually on the left side!
            x = 1440;
            y = 0;
          };
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+Q".action = quit;
        "Mod+T".action = spawn "kitty";
        "Mod+R".action = spawn-sh "wofi --show drun --allow-images";
        "Mod+C".action = close-window;
        "Mod+O".action = toggle-overview; # unstable-only action
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Print".action.screenshot = [];
        "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;

        # Workspace Focus
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        # Column Focus
        "Mod+Shift+Left".action.focus-monitor-left = [];
        "Mod+Shift+Right".action.focus-monitor-right = [];
        "Mod+Left".action.focus-column-left = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+H".action.focus-column-left = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+J".action.focus-window-down = [];

        "Mod+Ctrl+Left".action.move-column-left = [];
        "Mod+Ctrl+Right".action.move-column-right = [];
        "Mod+Ctrl+Up".action.move-window-up = [];
        "Mod+Ctrl+Down".action.move-window-down = [];
        "Mod+Ctrl+H".action.move-column-left = [];
        "Mod+Ctrl+L".action.move-column-right = [];
        "Mod+Ctrl+K".action.move-window-up = [];
        "Mod+Ctrl+J".action.move-window-down = [];
      };

      spawn-at-startup = [
        { command = ["waybar"]; }
        { command = ["mako"]; }
      ];

      #layout = {
      #  border.enable = true;
      #  focusRing.enable = false;
      #  gaps = {
      #    inner = 8;
      #    outer = 16;
      #  };
      #};

      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 16;
      };

      environment = {
        "NIXOS_OZONE_WL" = "1";  # Electron Wayland hint
        "XCURSOR_SIZE" = "16";
        "LIBVA_DRIVER_NAME" = "nvidia";
        "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
        "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
      };
    };

    # Do not set `config` manually — Stylix will inject style data here
    # config = null;
  };

  # Optionally, set up autostart programs (like your Hyprland exec-once)
  home.sessionVariables.NIRI_STARTUP = pkgs.writeShellScript "niri-startup" ''
    ${pkgs.swww}/bin/swww init &
    ${pkgs.swww}/bin/swww img ${config.stylix.image} &
    nm-applet --indicator &
    waybar &
    copyq --start-server &
    ${pkgs.mako}/bin/mako &
  '';
}

