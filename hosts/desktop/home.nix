{ pkgs, ... }:
{
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 

  imports = [
    ../../modules/home-manager/desktop/styling/gtk.nix
    ../../homeModules/packages.nix
    ../../homeModules/yazi.nix
    #../../modules/home-manager/desktop/styling/stylix.nix
    ../../homeModules/qutebrowser.nix
    ../../homeModules/applications/discord.nix
    ../../homeModules/applications/mpv.nix
    ../../homeModules/applications/odysseus
    ../../homeModules/terminal.nix

    ../../modules/home-manager/desktop/window-managers/niri.nix
  ];

  programs.kitty.enable = true;
  home.packages = with pkgs; [
    xwayland
    wayvnc # Wayland-compatible remote desktop access
    prismlauncher # Open-source minecraft launcher
    mullvad-browser
    tailscale
  ];

  discord.enable = true;

  home.stateVersion = "24.05"; # Ensure compatibility
  programs.home-manager.enable = true;
}

