{ pkgs, ... }:
{
  imports = [
    ./homeModules/git.nix
    ./homeModules/tmux.nix
  ];

  home.packages = with pkgs; [
    gotop # Resource monitor TUI
    superfile # Fancy file manager
    nix-inspect
    bat # improved cat utility, provides syntax highlighting and vim-like navigation
    yt-dlp
  ];
}
