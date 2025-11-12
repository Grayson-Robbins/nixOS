{ config, lib, pkgs, inputs, ... }: 

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd.enable = true;


    settings = [{
      layer = "top";
      position = "top";
      tray = { spacing = 10; };
      modules-center = [ "hyprland/window" ];
      modules-left = [ "hyprland/workspaces" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "temperature"
        "clock"
        "tray"
      ];
      
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
      };

      cpu = {
        format = "{usage}%";
        tooltip = false;
      };

      memory = { format = "{}%"; };

      #network = {
       # interval = 1;

      #};

    }];
  };
}
