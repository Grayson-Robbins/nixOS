{ config, lib, pkgs, nix-colors, ... }:

{
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 
  home.sessionVariables.EDITOR = "nvim";

  imports = [
    ./homeManagerModules/gtk.nix
    ./homeManagerModules/hyprland.nix
    ./homeManagerModules/packages.nix
    ./homeManagerModules/git.nix
    ./homeManagerModules/nvf.nix
    ./homeManagerModules/yazi.nix
    ./homeManagerModules/stylix.nix
    ./homeManagerModules/qutebrowser.nix
    ./homeManagerModules/tmux.nix
  ];
  
  programs.kitty.enable = true;

  home.stateVersion = "24.05"; # Ensure compatibility
  programs.home-manager.enable = true;
}

