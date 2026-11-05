{ pkgs, ... }:
{
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 

  imports = [
    ./homeModules/styling/gtk.nix
    ./homeModules/window-managers/hyprland.nix
    ./homeModules/window-managers/niri.nix
    ./homeModules/packages.nix
    ./homeModules/yazi.nix
    ./homeModules/styling/stylix.nix
    ./homeModules/qutebrowser.nix
    ./homeModules/applications/discord.nix
    ./homeModules/applications/mpv.nix
    ./homeModules/applications/odysseus
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

