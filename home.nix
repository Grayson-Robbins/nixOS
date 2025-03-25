{ config, lib, pkgs, nix-colors, inputs, ... }:

{
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 
  #home.sessionVariables.EDITOR = "nvim";

  imports = [
    ./homeManagerModules/gtk.nix
    ./homeManagerModules/hyprland.nix
    ./homeManagerModules/packages.nix
    ./homeManagerModules/git.nix
    ./homeManagerModules/yazi.nix
    ./homeManagerModules/stylix.nix
    ./homeManagerModules/qutebrowser.nix
    ./homeManagerModules/tmux.nix
  ];
  
  programs.kitty.enable = true;
  home.packages = with pkgs; [
    gotop # Resource monitor TUI
    cbonsai # Nice bonsai tree written in C
    superfile # Fancy file manager
    hledger # Plaintext accounting TUI
    nix-inspect
    prismlauncher # Open-source minecraft launcher
  ];
  home.stateVersion = "24.05"; # Ensure compatibility
  programs.home-manager.enable = true;
}

