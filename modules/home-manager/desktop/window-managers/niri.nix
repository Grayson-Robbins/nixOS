{ pkgs, config, ... }:

{
  imports = [
    ./niri/binds.nix
  ];

  programs.niri.settings = {
    # Keyboard
    input.keyboard.xkb.layout = "us";

    # Layout
    layout = {
      gaps = 8;
    };

    # Environment
    environment.NIXOS_OZONE_WL = "1";

    # Declare persistent named workspaces
    workspaces = {
      "desktop" = { open-on-output = "DP-1"; };
      "games" = { open-on-output = "DP-1"; };
    };

    # Monitor config
    outputs = {
      "DP-1" = {
        mode = {
          width = 2560;
          height = 1440; 
          refresh = 164.833;
        };

        position = {
          x = 1440;
          y = 640;
        };
      };

      "DP-2" = {
        mode = {
          width = 1440;
          height = 2560; 
          refresh = 144.0;
        };

        transform.rotation = 90;

        position = {
          x = 0;
          y = 0;
        };
      };
    };


    spawn-at-startup = [
      {
        argv = [
          "${pkgs.awww}/bin/awww"
          "init"
        ];
      }
      {
        argv = [
          "${pkgs.awww}/bin/awww"
          "img"
          "${config.home.homeDirectory}/Pictures/Nature_Wallpaper.jpg"
        ];
      }
      {
        argv = [
          "${pkgs.networkmanagerapplet}/bin/nm-applet"
          "--indicator"
        ];
      }
      {
        argv = [
          "${pkgs.copyq}/bin/copyq"
          "--start-server"
        ];
      }
      {
        argv = [
          "${pkgs.mako}/bin/mako"
        ];
      }
      {
        argv = [
          "${pkgs.waybar}/bin/waybar"
        ];
      }
    ];

    # Make Steam games fullscreen and focused when opened
    window-rules = [
      {
        matches = [
          { app-id = "^steam_app_[0-9]+$"; }
        ];

        open-on-workspace = "games";
        open-fullscreen = true;
        open-focused = true;
      }
    ];
  };

  home.packages = with pkgs; [
    fuzzel
    wofi
    kitty
  ];
}

