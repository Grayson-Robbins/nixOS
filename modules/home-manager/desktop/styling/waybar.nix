{ pkgs, ... }: 

{
  environment.systemPackages = with pkgs; [
    networkmanager
    wpa_supplicant
    power-profiles-daemon
  ];
  
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd.enable = true;


    settings = [{
      layer = "top";
      position = "top";
      tray = { spacing = 10; };
      modules-right = [
        "network"
        "clock"
        "cpu"
        "memory"
        "temperature"
        "pulseaudio"
        "tray"
      ];
      
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
        font = "Monospace 10";
        color = "#ffffff";
      };

      cpu = {
        format = "{usage}%";
        tooltip = true;
        background-color = "#222222";
        foreground-color = "#00ff00";
      };

      memory = { format = "{}%"; };

      network = {
        interval = 1;
        format = "IP: {ip} | {ssid}";
        tooltip = true;
      };

      style = ''
        #waybar {
          font-family: "JetBrains Mono", monospace;
          background: #1e1e1e;
          color: #ffffff;
          padding: 10px;
        }

        #waybar .module {
          padding: 5px;
        }

        #waybar .module:hover {
          background: #333333;
        }
      '';
    }];
  };
}
