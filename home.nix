{ config, lib, pkgs, nix-colors, inputs, ... }:
let
  vintagestoryPackages = inputs.vintagestory-nix.packages.${pkgs.system};
  in
{
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 
  #home.sessionVariables.EDITOR = "nvim";

  imports = [
    ./homeModules/styling/gtk.nix
    ./homeModules/hyprland.nix
    #./homeModules/niri.nix
    ./homeModules/packages.nix
    ./homeModules/git.nix
    ./homeModules/yazi.nix
    ./homeModules/styling/stylix.nix
    ./homeModules/qutebrowser.nix
    ./homeModules/tmux.nix
    ./homeModules/applications/discord.nix
    ./homeModules/applications/mpv.nix
    inputs.vintagestory-nix.homeModules.default

    ./homeModules/applications/odysseus
  ];
  
  programs.kitty.enable = true;
  home.packages = with pkgs; [
    xwayland
    #niri # Window manager, wayland based
    gotop # Resource monitor TUI
    cbonsai # Nice bonsai tree written in C
    superfile # Fancy file manager
    hledger # Plaintext accounting TUI
    nix-inspect
    prismlauncher # Open-source minecraft launcher
    mullvad-browser
    mullvad-vpn
    #mullvad
    #librewolf # Open-source, privacy-centric Firefox fork
    bat # improved cat utility, provides syntax highlighting and vim-like navigation
    yt-dlp
    tailscale
    vintagestoryPackages.latest # ignores RCs
    vintagestoryPackages.rustique
    vintagestoryPackages.vs-launcher
  ];

  home.stateVersion = "24.05"; # Ensure compatibility
  programs.home-manager.enable = true;

  #programs.vs-launcher = {
  #enable = true;
  #settings.gameVersions = with pkgs; [
  #vintagestoryPackages.v1-22-3
  #];
  #};
}

